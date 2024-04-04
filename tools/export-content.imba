import "dotenv/config"
import { equal } from "assert"
import { join } from "path"
import isNil from "lodash/isNil"
import isString from "lodash/isString"
import pick from "lodash/pick"
import pb from "./pocketbase"
import { saveJson } from "./files"

const dataPath = join __dirname, "..", "data"
const { SITE_KEY } = process.env
equal isString(SITE_KEY), true, "SITE_KEY is a string"
let site
let articles
let textblocks

def stop code=0
	process.exit code

def saveTextblocks
	const textblocksPath = join dataPath, "textblocks.json"
	saveJson textblocksPath, textblocks, do(err)
		if not isNil err
			const { message, stack } = err
			console.error "error writing textblocks json", textblocksPath, message, stack
			return
		console.log "textblocks.length", textblocks.length
		console.log "done"

def getTextblocks
	try
		const res = await pb.collection("textblocks")
			.getList(1, 100, {filter:"site = '{site.id}'"})
		textblocks = res.items.map do(item)
			pick item, ["section", "key", "val"]
	catch err
		console.error err
		return
	saveTextblocks!

def saveArticles
	const articlesPath = join dataPath, "articles.json"
	saveJson articlesPath, articles, do(err)
		if not isNil err
			const { message, stack } = err
			console.error "error writing articles json", articlesPath, message, stack
			return
		console.log "articles.length", articles.length
		getTextblocks!

def getArticles
	try
		const res = await pb.collection("articles")
			.getList(1, 100, {filter:"site = '{site.id}'"})
		articles = res.items.map do(item)
			pick item, ["pathname", "title", "icon", "body", "created"]
	catch err
		console.error err
		return
	saveArticles!

def getSite
	try
		site = await pb.collection("sites")
			.getFirstListItem("key = '{SITE_KEY}'")
	catch err
		const { message, stack } = err
		console.error "error getting articles", message, stack
		return stop 1
	console.log site.id, site.key
	getArticles!

getSite!