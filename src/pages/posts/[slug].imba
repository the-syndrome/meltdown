import isNil from "lodash/isNil"
import get from "lodash/get"
import set from "lodash/set"
import dayjs from "dayjs"
import { isNode } from "../../lib/environment"
import { getArticle } from "../../lib/api"

const blankArticle = { title: "", body: "" }

export default tag Article
	prop locals
	static def GET req, res, next
		const pathname = req.url.replace /\/$/, ""
		const article = await getArticle { pathname }
		if not isNil article
			set res, "locals.article", article
			if not isNode then document.title = window.unescape(article.title)
		next!
	get article
		get locals, "article", blankArticle
	<self>
		<div>
			<h1>
				if article.icon
					<thin-icon name="fallout-shelter">
					" "
				article.title
			<div innerHTML=article.body>
			<time> dayjs(created).format("YYYY-MM-DD")
