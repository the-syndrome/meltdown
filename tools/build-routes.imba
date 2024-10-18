###

Build routes

It scans src/pages for files and creates routes in the server to serve them.

Markdown and HTML pages are scanned for meta data and table of contents.

JS and TS pages are connected directly to the route.

###

import { join, sep, basename, extname } from "path"
import { writeFile, readFile } from "fs"
import isNil from "lodash/isNil"
import isString from "lodash/isString"
import isArray from "lodash/isArray"
import isObject from "lodash/isObject"
import startCase from "lodash/startCase"
import assign from "lodash/assign"
import get from "lodash/get"
import compact from "lodash/compact"
import uniq from "lodash/uniq"
import parallel from "async/parallel"
import map from "async/map"
import auto from "async/auto"
import fg from "fast-glob"
import frontMatter from "front-matter"
import { readText, saveJson, mkdirp } from "./files"
import { hasContent, slugify } from "../src/lib/strings"
import { hasItems } from "../src/lib/arrays"

const { NODE_ENV } = process.env
const isPrd = NODE_ENV is "production"
const projectPath = join __dirname, ".."
const pagesPath = join projectPath, "src", "pages"
const tmpPath = join projectPath, ".tmp"
const globOpts = { absolute: true, onlyFiles: true }
const patterns = ["{pagesPath}{sep}**{sep}*.\{imba,js,ts,md,html\}"]
const scriptExtensions = /\.(imba|js|ts)$/;
const markdownExtension = /\.md$/;
const htmlExtension = /\.html$/;
const blank = ""
let pagesCache = []
const shikiTheme = "min-light"
const ignoreLangs = []
const excludePages = [join(pagesPath, "debug.imba")]

# unruly modules
let unified
let unifiedMap
let remarkParse
let remarkSlug
let remarkGfm
let visit
let visitParents
let createHighlighter
let toc
let rehypeParse
let rehypeSlug
let toMdast
let toString

# scan the ./src/pages directory for the files for convention routing
def globPages done
	def globSuccess list
		if isPrd
			list = list.filter do not excludePages.includes($1)
		done null, list
	fg(patterns, globOpts)
		.then(globSuccess)
		.catch(done)

# read the files to text
def readPages { globPages }, done
	map globPages, readText, done

# these wont load regularly and need dynamic import
def loadUnrulyModules
	unified = (await import "unified").unified
	unifiedMap = (await import "unist-util-map").map
	visit = (await import "unist-util-visit").visit
	visitParents = (await import "unist-util-visit-parents").visitParents
	remarkParse = (await import "remark-parse").default
	remarkGfm = (await import "remark-gfm").default
	toc = (await import "mdast-util-toc").toc
	toString = (await import "mdast-util-to-string").toString
	rehypeParse = (await import "rehype-parse").default
	rehypeSlug = (await import "rehype-slug").default
	toHtml = (await import "hast-util-to-html").toHtml
	toMdast = (await import "hast-util-to-mdast").toMdast
	createHighlighter = (await import "shiki").createHighlighter

# create the router pattern like what is used on express or restana
def createPattern absolutePath
	absolutePath
		.replace(pagesPath, blank)
		.replace(scriptExtensions, blank)
		.replace(markdownExtension, blank)
		.replace(htmlExtension, blank)
		.replace(/\[/g, ":")
		.replace(/\]/g, blank)
		.replace(/index$/, blank)

# remove AST position information to save space
def stripAstPositions ast
	unifiedMap ast, do(node)
		delete node.position
		node

# markdown unified/remark pipeline -- add your own plugins
def parseMarkdown body
	const ast = unified!
		.use(remarkParse)
		.use(remarkGfm)
		.parse(body)

	visit ast, "heading", do(node)
		node.id = slugify toString(node)

	stripAstPositions ast

# html unified/rehype pipeline -- add your own plugins
def parseHtml body
	const ast = unified!
		.use(rehypeParse)
		.use(rehypeSlug)
		.parse(body)
	stripAstPositions ast

def buildTableOfContents { meta, mdast }
	let tocNodeCount = 0
	const tocAllowed = get(meta, "toc") isnt false
	let title = get meta, "title"
	const table = toc(mdast).map
	if not isNil(table)
		# guess a good title for the page if we don't have one
		visitParents table, ["text"], do(node)
			if not hasContent title
				title = node.value
			# count how many items in the table of contents
			visitParents table, ["listItem"], do(node) tocNodeCount += 1
	const showToc = tocAllowed and tocNodeCount > 2
	{ title, showToc, table }

def buildPagesCache { globPages, readPages }, done
	pagesCache = for absolutePath, index in globPages
		const raw = readPages[index]
		const isHidden = basename(absolutePath).startsWith("_")
		const isScript = not isHidden and scriptExtensions.test(absolutePath)
		const isMarkdown = markdownExtension.test(absolutePath)
		const isHtml = htmlExtension.test(absolutePath)
		const isFrontMatter = not isHidden and (isMarkdown or isHtml)
		const pattern = isHidden ? null : createPattern(absolutePath)
		const fm = isFrontMatter and frontMatter(raw)
		let meta
		let body
		if isFrontMatter
			meta = fm.attributes
			body = fm.body
		let mdast
		const hast = isHtml ? parseHtml(body) : null
		if isMarkdown
			mdast = parseMarkdown(body)
		elif isHtml
			# HTML pages get an MDAST just for creating the table of contents
			mdast = toMdast hast
		let title
		let showToc
		let table
		if not isNil(mdast)
			const toc = buildTableOfContents { meta, mdast }
			title = toc.title
			showToc = toc.showToc
			table = toc.table
		{
			absolutePath
			raw
			isHidden
			isScript
			isMarkdown
			isHtml
			isFrontMatter
			pattern
			meta
			body
			mdast
			hast
			title
			showToc
			table
		}
	done!

def extractCodeLangs ast
	const langs = []
	unifiedMap ast, do(node)
		if isNil(node)
			return
		elif node.type is "code"
			# markdown
			langs.push node.lang or "text"
		elif node.tagName is "code"
			# html
			const lang1 = get node, "properties.lang"
			const lang2 = get node, "properties.dataLang"
			const lang = lang1 or lang2 or "text"
			langs.push lang
	langs

# generate HTML for the markdown code
def shikiMarkdown { highlighter, mdast }
	const theme = shikiTheme
	unifiedMap mdast, do(node)
		if not isNil(node) and node.type is "code"
			let lang = node.lang
			if isNil(lang) or ignoreLangs.includes(lang)
				lang = "text" # language unknown or in banned list
			try
				node.shiki = highlighter.codeToHtml node.value, { lang, theme }
			catch err
				const { message, stack } = err
				console.error "error creating markdown shiki", message, stack
		node

# generate a HAST for the HTML <code>
def shikiHtml { highlighter, hast }
	const theme = shikiTheme
	unifiedMap hast, do(node)
		if not isNil(node) and node.tagName is "code"
			const lang1 = get node, "properties.lang"
			const lang2 = get node, "properties.dataLang"
			let lang = lang1 or lang2
			if hasContent(lang) and hasItems(node.children)
				try
					const root = highlighter.codeToHast node.children[0].value, { lang, theme }
					node = root.children[0]
				catch err
					const { message, stack } = err
					console.error "error creating html shiki", message, stack
		node

def syntaxHighlighting {}
	let langs = []
	for { isMarkdown, isHtml, mdast, hast } in pagesCache
		if isMarkdown and not isNil(mdast)
			langs = langs.concat extractCodeLangs(mdast)
		elif isHtml and not isNil(hast)
			langs = langs.concat extractCodeLangs(hast)
	langs = compact(uniq(langs))
	if not hasItems(langs)
		# no syntax highlighting needed
		return
	const themes = [shikiTheme]
	let highlighter
	let iterations = 0
	while highlighter is undefined or langs.length is 0 or iterations > 50
		iterations += 1
		try
			highlighter = await createHighlighter { themes, langs }
		catch err
			const { message, stack } = err
			const parsed = /Language `(.+)` is not included in this bundle/.exec(message)
			if hasItems(parsed) and hasContent(parsed[1])
				const lang = parsed[1]
				ignoreLangs.push lang
				console.warn "⚠️ shiki could not use language:", lang
				langs = langs.filter do $1 isnt lang
			else
				console.error "error trying to create shiki", message, stack
				break
	if isNil(highlighter) then return # cannot highlight
	pagesCache = pagesCache.map do(page)
		const { isMarkdown, isHtml, mdast, hast } = page
		if isMarkdown and not isNil(mdast)
			page.mdast = shikiMarkdown { highlighter, mdast }
		elif isHtml and not isNil(hast)
			page.hast = shikiHtml { highlighter, hast }
		page

def createTmpName absolutePath
	absolutePath
		.replace("{pagesPath}{sep}", blank)
		.replace(markdownExtension, blank)
		.replace(htmlExtension, blank)
		.replaceAll(sep, "-")

def createStaticTitle title
	let staticTitle = ""
	if isString(title) and title.length > 0
		staticTitle = `\n\tstatic title = "{escape(title)}"`
	staticTitle

def writeMarkdownTmps _, done
	const steps = []
	for page in pagesCache.filter(do(item) item.isMarkdown)
		const { absolutePath, meta, title, showToc, table, mdast } = page
		const tmpName = createTmpName absolutePath
		const dataFile = "./{tmpName}.json"
		const dataPath = join tmpPath, dataFile
		const data = { meta, table, showToc, mdast }
		steps.push do(done) saveJson dataPath, data, done
		const imbaFile = "./{tmpName}.imba"
		const imbaPath = join tmpPath, imbaFile
		const compName = startCase(basename(tmpName)).replaceAll(" ", blank)
		const staticTitle = createStaticTitle title
		const compSource = """
		import MarkdownPage from "../src/components/MarkdownPage"
		import data from "{dataFile}"
		export default tag {compName}{staticTitle}
			static data = data
			<self>
				<MarkdownPage
					meta=data.meta
					showToc=data.showToc
					table=data.table
					mdast=data.mdast
				>
		"""
		steps.push do(done) writeFile imbaPath, compSource, done
	if not hasItems(steps) then return done!
	parallel steps, done

def writeHtmlTmps _, done
	const steps = []
	for page in pagesCache.filter(do(item) item.isHtml)
		const { absolutePath, meta, title, table, hast } = page
		const tmpName = createTmpName absolutePath
		const dataFile = "./{tmpName}.json"
		const dataPath = join tmpPath, dataFile
		const data = { meta, title, table }
		steps.push do(done) saveJson dataPath, data, done
		const htmlFile = "./{tmpName}.html"
		const htmlPath = join tmpPath, htmlFile
		const html = toHtml hast
		steps.push do(done) writeFile htmlPath, html, done
		const imbaFile = "./{tmpName}.imba"
		const imbaPath = join tmpPath, imbaFile
		const compName = startCase(basename(tmpName)).replaceAll(" ", blank)
		const staticTitle = createStaticTitle title
		const compSource = """
		import HtmlPage from "../src/components/HtmlPage"
		import data from "{dataFile}"
		import html from "{htmlFile}"
		export default tag {compName}{staticTitle}
			static data = data
			<self>
				<HtmlPage meta=data.meta table=data.table html=html>
		"""
		steps.push do(done) writeFile imbaPath, compSource, done
	if not hasItems(steps) then return done!
	parallel steps, done

def toPagesRelative absolutePath
	absolutePath.replace(pagesPath, "../src/pages")

def writeRoutesImba _, done
	const routesInner = for page in pagesCache.filter(do not $1.isHidden)
		const { absolutePath, pattern, isScript, isMarkdown, isHtml } = page
		const tmpName = createTmpName absolutePath
		const importPath = if isScript
			toPagesRelative(absolutePath)
		else
			"./{tmpName}.imba"
		"""
		\tpattern: "{pattern}"
		\tload: do import("{importPath}")
		"""
	const routes =  """
	const routes = [\n{routesInner.join("\n\t-\n")}\n]
	export default routes
	"""
	const routesPath = join tmpPath, "meltdown-routes.imba"
	writeFile routesPath, routes, done

def writeDebugSummary _, done
	const summary = for page, index in pagesCache
		const {
			absolutePath
			raw
			pattern
			isHidden
			isScript
			isMarkdown
			isHtml
			isFrontMatter
			title
			table
		} = page
		const pagesRelativePath = absolutePath.replace("{pagesPath}/", "")
		const type = if isHidden
			"hidden"
		elif isScript
			"script"
		elif isMarkdown
			"markdown"
		elif isHtml
			"html"
		else
			"unknown"
		const hasTable = isFrontMatter and not isNil(table)
		const size = Buffer.from(raw).length
		{ pagesRelativePath, pattern, type, hasTable, size }
	const summaryPath = join tmpPath, "summary.json"
	saveJson summaryPath, summary, done

def tmpExists done
	mkdirp tmpPath, done

const steps = {
	globPages
	loadUnrulyModules
	tmpExists
	readPages: ["tmpExists", "globPages", readPages]
	buildPagesCache: ["readPages", "loadUnrulyModules", buildPagesCache]
	syntaxHighlighting: ["buildPagesCache", syntaxHighlighting]
	writeMarkdownTmps: ["syntaxHighlighting", writeMarkdownTmps]
	writeHtmlTmps: ["syntaxHighlighting", writeHtmlTmps]
	writeRoutesImba: ["syntaxHighlighting", writeRoutesImba]
	writeDebugSummary: ["syntaxHighlighting", writeDebugSummary]
}

auto steps, do(err)
	if not isNil err
		const { message, stack } = err
		console.error "error building routes", message, stack
		return
	console.log "generated routes"
	process.exit!

