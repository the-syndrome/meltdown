# import "../components/Chico"
import get from "lodash/get"
import find from "lodash/find"
import { getTextblocks, getArticles } from "../lib/api"
import Posts from "../components/Posts"

export default tag Home
	prop locals
	static def GET req, res, next
		const textblocks = await getTextblocks!
		res.locals.column1 = find textblocks, { key: "column1" }
		res.locals.column2 = find textblocks, { key: "column2" }
		res.locals.articles = await getArticles!
		next!
	css
		.panel
			min-width:340px
			p:1rem
			bg: linear-gradient(180deg, rgba(0, 0, 0, 0.03) 0%, transparent 30%)
			border-radius:1rem
			mt:1rem
			min-height:300px
		.col > * w:fit-content
	<self>
		<div.row>
			<div.panel.third>
				<div innerHTML=get(locals, "column1.val", "")>
			<div.panel.third>
				<div innerHTML=get(locals, "column2.val", "")>
			<div.panel.third.col>
				<h3> "Updates"
				<Posts[w:100%] articles=get(locals, "articles", [])>
				<h3> "Documentation"
				<nav-link to="/convention-routing"> "Convention routing"
				<nav-link to="/markdown-test"> "Markdown test page"
				<nav-link to="https://imba.io/docs/css" external> "Styling"
