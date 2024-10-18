import "dotenv/config"
import { join } from "path"
import { createServer } from "http"
import { exec } from "child_process"
import { isPrimary, worker } from "cluster"
import isNil from "lodash/isNil"
import isEmpty from "lodash/isEmpty"
import isFunction from "lodash/isFunction"
import isString from "lodash/isString"
import get from "lodash/get"
import find from "lodash/find"
import omit from "lodash/omit"
import restana from "restana"
import sirv from "sirv"
import parallel from "async/parallel"
import index from "./index.html"
import { SiteClient } from "./client"
import routes from "../.tmp/meltdown-routes"
import { toBinary } from "./lib/encoding"
import { hasContent } from "./lib/strings"
import { hasItems } from "./lib/arrays"
import Error404 from "./pages/_Error404"
import Error500 from "./pages/_Error500"

const {
	MELTDOWN_PORT: port = 33765
	MELTDOWN_HOST: host = "127.0.0.1"
	NODE_ENV = "development"
	MELTDOWN_STATE1 = "iNEmQL"
	MELTDOWN_STATE2 = "JW29a4"
	MELTDOWN_SEARCH_INDEX = true
	MELTDOWN_SSG = false
} = process.env
const isPrd = NODE_ENV is "production"
const isDev = NODE_ENV is "development"
const htmlMime = "text/html"
const jsonMime = "application/json"
const textMime = "text/plain"
const contentTypeHtml = { "content-type": htmlMime }
const contentTypeJson = { "content-type": jsonMime }
const contentTypeText = { "content-type": textMime }
const projectPath = process.cwd!

def errorHandler err, req, res
	const { message, stack, status = 500 } = err
	console.error "error rendering page", status, message, stack
	if not res.headersSent
		const accept = get req, "headers.accept", ""
		let headers = {}
		let body = ""
		if accept.includes htmlMime
			const screen = Error500
			headers = contentTypeHtml
			body = renderPage { screen }
		elif accept.includes jsonMime
			headers = contentTypeJson
			body = { error: true }
			if not isPrd then body.message = message
		else
			headers = contentTypeText
			body = "server error {status}"
			if not isPrd then body = "{body}, {message}"
		res.send body, status, headers

const router = restana { errorHandler }
const server = createServer router

if isDev
	const sirvOpts = { dev: true }
	router.use sirv(join(projectPath, "assets"), sirvOpts)
	router.use sirv(join(projectPath, "dist", "public", "assets"), sirvOpts)

# setup state object for SSR/SSG pages
router.use do(req, res, next)
	res.locals = {}
	next!

# routes constructed from ./pages
for { pattern, load, data } in routes
	router.get pattern, do(req, res, next)
		const { default: screen } = await load!
		res.screen = screen
		if isFunction(data)
			res.locals.data = await data!
		next!

const hasSomething = do(val) not isNil(val) and not isEmpty(val)

const quotesPattern = /("|')/g

def dequote txt
	txt.replace quotesPattern, ""

def createKeywords content
	"<meta name=\"keywords\" content=\"{dequote(content)}\">\n"

def createDescription content
	"<meta name=\"description\" content=\"{dequote(content)}\">\n"

export def renderPage { screen, query, params, locals, data }
	# convert these context variables into binary
	let initialState = {}
	if hasSomething(query) then initialState.query = query
	if hasSomething(params) then initialState.params = params
	if hasSomething(locals) then initialState.locals = locals
	initialState = JSON.stringify initialState
	# split the state in two and obfuscate it thus preventing scraping
	const state = toBinary initialState
	const half = state.length > 10 ? Math.floor(state.length / 2) : state.length
	const state1 = state.substring(0, half)
	const state2 = state.substring(half).split("").reverse!.join("")
	# render to html
	let page = ""
	try
		page = <SiteClient screen=screen query=query params=params locals=locals>
	catch err
		const { message, stack } = err
		console.error "error rendering page", message, stack
	page = String page
	let meta = get data, "meta", {}
	const screenTitle = get screen, "title"
	const metaTitle = get meta, "title"
	const localsTitle = get locals, "title"
	const articleTitle = get locals, "article.title"
	const title = screenTitle or metaTitle or localsTitle or articleTitle
	let html = index.body
	if hasContent(title)
		html = html.replace("<title></title>", "<title>{unescape(title)}</title>")
	let headText = ""
	if hasItems(meta.keywords)
		headText +=  createKeywords(meta.keywords.join(","))
	elif hasContent(meta.keywords)
		headText +=  createKeywords(meta.keywords)
	if hasContent(meta.description)
		headText += createDescription(meta.description)
	html = html.replace("<!-- meltdown-replace-head -->", headText)
	const bodyText = """
	{page}
	<template id=\"{MELTDOWN_STATE1}\">{state1}</template>
	<template id=\"{MELTDOWN_STATE2}\">{state2}</template>
	"""
	html = html.replace("<!-- meltdown-replace-body -->", bodyText)
	html

def loadFallback
	const mod = await import("./pages/_Error404")
	mod.default

# some pages provide their own middleware
router.get "*", do(req, res, next)
	const { screen = (await loadFallback!) } = res
	if isFunction(screen.GET)
		screen.GET(req, res, next)
		return
	next!

# finally render it
router.get "*" do(req, res)
	let { screen = (await loadFallback!), locals, status = 200 } = res
	const { query, params } = req
	if res.status is 404
		screen = Error404
	elif res.status >= 500
		screen = Error500
	const { data } = screen
	const html = renderPage { screen, locals, data, query, params }
	res.send html, status, contentTypeHtml

let exitCode = 0

def stop
	if server.listening
		try server.close!
	process.exit exitCode

# spider the site and build a slim index for searching in the interface
def buildSearchIndex done
	const cmd = "npm run search-index"
	exec cmd, do(err, stdout, stderr)
		if not isNil err
			const { message, stack } = err
			console.error "error building search index", cmd, message, stack
			console.error "stdout", stdout
			console.error "stderr", stderr
			exitCode = 1
			return done err
		done!

# spider the site creating static HTML files for pages in .ssg directory
def buildSSG done
	const cmd = "npm run ssg"
	exec cmd, do(err, stdout, stderr)
		if not isNil err
			const { message, stack } = err
			console.error "error building SSG", cmd, message, stack
			console.error "stdout", stdout
			console.error "stderr", stderr
			exitCode = 1
			return done err
		done!

def isTruthy val
	[true, "true", "1"].includes val

# sometimes the port is already bound and this will let you know
def listening err
	if not isNil err
		const { message, stack } = err
		console.error "error binding http server", message, stack
		exitCode = 1
		stop!
	console.log "bound http server http://{host}:{port}"
	let exitAfterStart = false
	const startup = []
	if isTruthy(MELTDOWN_SEARCH_INDEX)
		startup.push buildSearchIndex
	if isTruthy(MELTDOWN_SSG)
		startup.push buildSSG
		exitAfterStart = true
	parallel startup, do(err)
		if not isNil err
			const { message, stack } = err
			console.error "error in startup", message, stack
		if exitAfterStart
			console.warn "shutting down after SSG"
			stop!

server.listen port, host, listening

# give imba the server, it does something with it
imba.serve server
