import { join, sep, basename } from "path"
import { writeFile, readFile } from "fs"
import isNil from "lodash/isNil"
import isString from "lodash/isString"
import isArray from "lodash/isArray"
import startCase from "lodash/startCase"
import assign from "lodash/assign"
import parallel from "async/parallel"
import auto from "async/auto"
import fg from "fast-glob"
import frontMatter from "front-matter"

const projectPath = join __dirname, ".."
const pagesPath = join projectPath, "src", "pages"
const tmpPath = join projectPath, ".tmp"
const routesPath = join tmpPath, "routes.imba"
const globOpts = { absolute: true, onlyFiles: true }
const patterns = ["{pagesPath}{sep}**{sep}*.\{imba,js,ts,md\}"]
const scriptExtensions = /\.(imba|js|ts)$/;
const markdownExtension = /\.md$/;
const blank = ""
const readOpts = { encoding: "utf8" }

def toMeta absolutePath
	const pattern = absolutePath
		.replace(pagesPath, blank)
		.replace(scriptExtensions, blank)
		.replace(markdownExtension, blank)
		.replace(/\[/g, ":")
		.replace(/\]/g, blank)
		.replace(/index$/, blank)
	{ absolutePath, pattern }

def addMarkdownMeta route
	const { absolutePath } = route
	const isMd = markdownExtension.test absolutePath
	const tmpPrefix = absolutePath
		.replace("{pagesPath}{sep}", blank)
		.replace(markdownExtension, blank)
		.replaceAll(sep, "-")
	const htmlPath = join tmpPath, "{tmpPrefix}.html"
	const importPath = join tmpPath, "{tmpPrefix}.imba"
	assign route, { tmpPrefix, htmlPath, importPath }

# for example ./pages/_cant-see-me.imba is hidden
const notHidden = do(absolutePath)
	basename(absolutePath).startsWith("_") is false

def toRouteImport { importPath, absolutePath, pattern }
	const loadProp = `\tload: do import("{importPath or absolutePath}")`
	const patternProp = `\tpattern: "{pattern}"`
	"{patternProp}\n{loadProp}"

# convert GFM markdown page to HTML
def markdownToHtml source
	# these have to use dynamic import or else error
	const {unified} = await import "unified"
	const { default: remarkParse } = await import "remark-parse"
	const { default: remarkGfm } = await import "remark-gfm"
	const { default: remarkRehype } = await import "remark-rehype"
	const { default: rehypeRaw } = await import "rehype-raw"
	const { default: rehypeFormat } = await import "rehype-format"
	const { default: rehypeStringify } = await import "rehype-stringify"
	# 1. parse markdown
	# 2. and github-flavored markdown
	# 3. transform to hast (HTML AST)
	# 4. stringify to HTML
	const { value, messages } = await unified()
		.use(remarkParse)
		.use(remarkGfm)
		.use(remarkRehype, { allowDangerousHtml: true })
		.use(rehypeRaw)
		.use(rehypeFormat)
		.use(rehypeStringify)
		.process(source)
	if isArray(messages) and messages.length > 0
		console.warn "markdown parser messages"
		for message in messages
			console.warn message
	value

const isScriptRoute = do({ absolutePath }) scriptExtensions.test(absolutePath)
const isMarkdownRoute = do({ absolutePath }) markdownExtension.test(absolutePath)

const writeMarkdownComponent = do(route) do(done)
	const { tmpPrefix, importPath, htmlPath, absolutePath, pattern } = route
	const compName = startCase(basename(tmpPrefix)).replaceAll(" ", blank)
	def mdSource done
		readFile absolutePath, readOpts, done
	def mdMeta { mdSource }, done
		done null, frontMatter(mdSource)
	def mdHtml { mdMeta }, done
		markdownToHtml(mdMeta.body).then(do(res) done(null, res)).catch(done)
	def mdComp { mdMeta }, done
		const { title } = mdMeta.attributes
		let staticTitle = ""
		if isString(title) and title.length > 0
			staticTitle = `\n\tstatic title = "{escape(title)}"`
		const compSource = """
		import bodyHtml from "{htmlPath}"
		export default tag {compName}{staticTitle}
			<self>
				<div.markdown-page innerHTML=bodyHtml>
		"""
		writeFile importPath, compSource, done
	def write { mdHtml }, done
		writeFile htmlPath, mdHtml, done
	const steps = {
		mdSource
		mdMeta: ["mdSource", mdMeta]
		mdComp: ["mdMeta", mdComp]
		mdHtml: ["mdMeta", mdHtml]
		write: ["mdHtml", write]
	}
	auto steps, done

def buildMarkdownTmp routes
	const steps = routes.map(writeMarkdownComponent)
	parallel steps, do(err)
		if not isNil err
			const { message, stack } = err
			console.error "error writing markdown pages", message, stack

def buildRoutes
	const pages = await fg patterns, globOpts
	const routesMeta = pages.filter(notHidden).map(toMeta)
	const scriptRoutes = routesMeta.filter(isScriptRoute)
	const markdownRoutes = routesMeta.filter(isMarkdownRoute).map(addMarkdownMeta)
	const routesInner = []
		.concat(scriptRoutes)
		.concat(markdownRoutes)
		.map(toRouteImport)
	let routesOuter = `const routes = [\n{routesInner.join("\n\t-\n")}\n]\n`
	routesOuter += "export default routes\n"
	if markdownRoutes.length > 0
		buildMarkdownTmp markdownRoutes
	writeFile routesPath, routesOuter, do(err)
		if not isNil err
			const { message, stack } = err
			console.error "error writing", routesPath, message, stack
			return
		console.log "routes created", routesPath

buildRoutes!.catch do(err)
	const { message, stack } = err
	console.error "error building routes", message, stack
