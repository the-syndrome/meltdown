import { getArticles } from "../../lib/api"
import Posts from "../../components/Posts"

export default tag PostsList
	prop locals
	static def GET req, res, next
		res.locals.articles = await getArticles!
		next!
	<self>
		<h1> "Posts"
		<Posts articles=(locals.articles or [])>