###

Build search index

It's meant to mimic what Algolia search does but without having to add any
third party services. It will work fine for small to medium sites. Huge sites
might need to customize and optimize.

1. Spider URL (starting with home page)
2. Parse HTML
3. Look for <a href="/some/other/page">
4. Loop to 1 until no new pages can be found
5. Save .cache/search-index.json

The output is used in ./src/components/NavSearch.imba

###

if process.env.MELTDOWN_SEARCH_INDEX isnt "true"
	process.exit!

import "dotenv/config"
import { join } from "path"
import isNil from "lodash/isNil"
import isObject from "lodash/isObject"
import get from "lodash/get"
import debounce from "lodash/debounce"
import pick from "lodash/pick"
import urlJoin from "url-join"
import superagent from "superagent"
import posthtml from "posthtml"
import queue from "async/queue"
import { hasContent } from "../src/lib/strings"
import { hasItems } from "../src/lib/arrays"
import { saveJson } from "./files"

#
# set false to omit search summary
#
const printSummary = true

const searchOutputPath = join __dirname, "..", "assets"
const pagesUrlMap = {}
const port = process.env.MELTDOWN_PORT
const host = process.env.MELTDOWN_HOST
const rootUrl = "http://{host}:{port}"
const concurrency = 16
const commentStart = "<!--"
const commentEnd = "-->"
const spacesPattern = /^\s+$/
const doctype = "<!DOCTYPE"
const searchKeys = ["pathname", "title", "text"]
let spiderQueue

def saveSearchIndex
	const pages = Object.entries(pagesUrlMap)
		.map(do([_, item]) item)
	const successPages = pages
		.filter(do({ status }) status >= 200 and status <= 299)
	const failPages = pages
		.filter(do({ status }) status >= 200 and status <= 299)
	const searchIndexPath = join searchOutputPath, "search-index.json"
	const searchIndex = successPages.map do pick($1, searchKeys)
	saveJson searchIndexPath, searchIndex, do(err)
		if not isNil err
			const { message, stack } = err
			console.error "error saving search index", searchIndexPath, message, stack
			process.exit 1
		else
			console.log "done saving search index"
		if printSummary
			console.log "--- success pages (status: 200-299) ---"
			for { pathname, title, text } in successPages
				console.log pathname, title, text.substring(0, 50), "..."
			console.log "--- fail pages (status: not 200 range) ---"
			for { status, pathname, title, text } in failPages
				console.log status, pathname, title, text.substring(0, 50), "..."
		process.exit!

const save = debounce saveSearchIndex, 1000

def searchableString node
	hasContent(node)
	and not node.startsWith(commentStart)
	and not node.endsWith(commentEnd)
	and not node.startsWith(doctype)
	and not spacesPattern.test(node)

def spiderPlugin pageUrl
	def spiderPluginInner tree
		const cacheRecord = pagesUrlMap[pageUrl]
		let text = []
		tree.match { tag: "title" }, do({ content })
			if hasItems(content)
				cacheRecord.title = content.join(" ")
		tree.match { tag: "a" }, do({ attrs })
			const href = get attrs, "href"
			if hasContent(href) and href.startsWith("/")
				spiderQueue.push { pathname: href }
		tree.walk do(node)
			const htmlTag = get(node, "tag")
			const id = get(node, "attrs.id")
			if htmlTag is "head"
				# <head> skipped
				return null
			elif id is "site-top" or id is "site-bottom"
				# top and bottom nav omitted
				return null
			elif isObject(node) and node.tag is "template"
				# state templates omitted
				return null
			elif searchableString(node)
				text.push(node.trim!)
			node
		text = text.join " "
		# remove multiple spaces
		text = text.replace(/\s{2,}/g, " ").trim!
		const pathname = pageUrl.replace(rootUrl, "")
		cacheRecord.text = text
		cacheRecord.pathname = pathname
		pagesUrlMap[pageUrl] = cacheRecord
		save!

def spiderQueueTask { pathname }, done
	if not pathname.startsWith("/") or pathname.startsWith("//")
		# probably external
		return done!
	pathname = pathname..replace(/#.+/, "")
	const pageUrl = urlJoin(rootUrl, pathname)
	if not isNil(pagesUrlMap[pageUrl])
		# skip existing and in-progress pages
		return done!
	const cacheRecord = {}
	def saveCache
		pagesUrlMap[pageUrl] = cacheRecord
		done!
	def pageError err
		if isNil(err.response) and err.code is 'ECONNREFUSED'
			console.error err
			console.error "hint: we might have the wrong port or server isn't up"
			console.error "port", port
			console.error "rootUrl", rootUrl
			process.exit!
		cacheRecord.status = err.response.status
		saveCache!
	def processPageHtml err, res
		if not isNil(err) then return pageError(err)
		cacheRecord.status = res.status
		cacheRecord.body = res.text
		saveCache!
		posthtml!.use(spiderPlugin(pageUrl))
			.process(cacheRecord.body, { sync: true })
	superagent.get(pageUrl).accept("html").end(processPageHtml)

spiderQueue = queue spiderQueueTask, concurrency

spiderQueue.error = do(err)
	const { message, stack } = err
	console.error "spiderQueue error", message, stack

#
# start the spider, if any URL is missed push more here
#
spiderQueue.push { pathname: "/" }
