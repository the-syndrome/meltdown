import isNil from "lodash/isNil"
import get from "lodash/get"
import set from "lodash/set"
import dayjs from "dayjs"
import { isNode } from "../../lib/environment"
import { getArticle } from "../../lib/api"
import Error404 from "../_Error404"

const blankArticle = { title: "", body: "" }

export default tag Article
	prop locals
	static def GET req, res, next
		const pathname = req.url.replace /\/$/, ""
		const article = await getArticle { pathname }
		if not isNil(article) and article isnt ""
			set res, "locals.article", article
		else
			res.status = 404
		next!
	get article
		get locals, "article", blankArticle
	<self>
		if article.title is "" and article.body is ""
			<Error404>
		else
			<h1>
				if article.icon
					<thin-icon name=article.icon>
					" "
				article.title
			<div innerHTML=article.body>
			<time> dayjs(created).format("YYYY-MM-DD")
