import superagent from "superagent"
import urlJoin from "url-join"
import { isNode } from "../lib/environment"

# example how to connect to self on server and to a path on browser
const apiUrl = isNode ? "http://127.0.0.1:{process.env.PORT}" : "/"

export def getArticle { pathname }
	const articlesUrl = urlJoin apiUrl, "/articles"
	const { body } = await superagent.get(articlesUrl)
		.query({ pathname })
		.accept("json")
	body

export def getArticles
	const articlesUrl = urlJoin apiUrl, "/articles"
	const { body: articles } = await superagent.get(articlesUrl).accept("json")
	articles

export def getTextblocks
	const textblocksUrl = urlJoin apiUrl, "/textblocks"
	const { body } = await superagent.get(textblocksUrl).accept("json")
	body
