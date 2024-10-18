###

Build SSG - Static Site Generation static snapshot

What does it do?

1. Spider URL (starting with home page)
2. Parse HTML
3. Look for <a href="/some/other/page">
4. Loop to 1 until no new pages can be found
5. Save .ssg

The output is used in ./src/components/NavSearch.imba

###

import "dotenv/config"
import { join } from "path"
import { writeFile } from "fs"
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
import { mkdirp } from "./files"

#
# set false to omit search summary
#
const printSummary = true

const ssgPath = join __dirname, "..", ".ssg"
const pagesUrlMap = {}
const port = process.env.MELTDOWN_PORT
const host = process.env.MELTDOWN_HOST
const rootUrl = "http://{host}:{port}"
const concurrency = 16
let ssgQueue

def ssgPlugin pageUrl
	def ssgPluginInner tree
		const cacheRecord = pagesUrlMap[pageUrl]
		tree.match { tag: "a" }, do({ attrs })
			const href = get attrs, "href"
			if hasContent(href) and href.startsWith("/")
				ssgQueue.push { pathname: href }

def ssgQueueTask { pathname }, done
	if not pathname.startsWith("/") or pathname.startsWith("//")
		# probably external
		return done!
	pathname = pathname..replace(/#.+/, "")
	const pageUrl = urlJoin(rootUrl, pathname)
	if not isNil(pagesUrlMap[pageUrl])
		# skip existing and in-progress pages
		return done!
	const cacheRecord = { pathname }
	def pageError err
		if isNil(err.response) and err.code is 'ECONNREFUSED'
			console.error err
			console.error "hint: we might have the wrong port or server isn't up"
			console.error "port", port
			console.error "rootUrl", rootUrl
			process.exit!
		cacheRecord.status = err.response.status
		pagesUrlMap[pageUrl] = cacheRecord
	def processPageHtml err, res
		if not isNil(err) then return pageError(err)
		cacheRecord.body = res.text
		pagesUrlMap[pageUrl] = cacheRecord
		posthtml!.use(ssgPlugin(pageUrl))
			.process(cacheRecord.body, { sync: true })
		const pageParentPath = join ssgPath, pathname
		const pagePath = join pageParentPath, "index.html"
		mkdirp pageParentPath, do(err)
			if not isNil err
				const { message, stack } = err
				console.error "error creating page parent path", message, stack
				console.error "pathname", pathname
				console.error "pageParentPath", pageParentPath
				return done(err)
			writeFile pagePath, cacheRecord.body, do(err)
				if not isNil err
					const { message, stack } = err
					console.error "error creating static page", message, stack
					console.error "pathname", pathname
					console.error "pageParentPath", pageParentPath
					console.error "pagePath", pagePath
					return done(err)
				done!
	superagent.get(pageUrl).accept("html").end(processPageHtml)

ssgQueue = queue ssgQueueTask, concurrency

ssgQueue.error = do(err)
	const { message, stack } = err
	console.error "ssgQueue error", message, stack

#
# start the spider, if any URL is missed push more here
#
mkdirp ssgPath, do(err)
	if not isNil err
		const { message, stack } = err
		console.error "error creating ssg path", ssgPath, message, stack
		return
	ssgQueue.push { pathname: "/" }
