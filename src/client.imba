import "../node_modules/@phosphor-icons/web/src/thin/style.css"
import "./components/nav-link"
import "./components/thin-icon"
import "./components/text-copier"
import NavSearch from "./components/NavSearch"

import isNil from "lodash/isNil"
import isEmpty from "lodash/isEmpty"
import isString from "lodash/isString"
import isObject from "lodash/isObject"
import isFunction from "lodash/isFunction"
import get from "lodash/get"
import qs from "qs"
import routes from "../.tmp/meltdown-routes"
import { fromBinary } from "./lib/encoding"
import { isNode } from "./lib/environment"
import Error404 from "./pages/_Error404"
import Error500 from "./pages/_Error500"
import { hasContent } from "./lib/strings"

const fallbackRoute = { pattern: "*", load: do import("./pages/_Error404") }
let initialScreen
let initialLoaded = false
const MELTDOWN_STATE1 = process.env.MELTDOWN_STATE1
const MELTDOWN_STATE2 = process.env.MELTDOWN_STATE2

if not isNode
	const siteMain = document.querySelector "main"
	if not isNil(siteMain) then initialScreen = siteMain.firstChild

global css @root
	$font-family-ui: sans-serif, -apple-system, "BlinkMacSystemFont", "Segoe UI", roboto, oxygen, ubuntu, cantarell, "Fira Sans", "Droid Sans", "Helvetica Neue"
	$font-family-code: monospace, consolas, monaco, "Andale Mono", "Ubuntu Mono"
	$spacing-xs: 0.1rem
	$spacing-sm: 0.3rem
	$spacing-md: 0.6rem
	$spacing-lg: 1rem
	$color-bg: #FFFFFF
	$color-fg: #111111
	$color-sep: cooler3
	$page-width: 1100px

global css
	html,body p:0;m:0
	body
		bgc:$color-bg
		* ff: $font-family-ui; c: $color-fg
	h1,h2,h3 font-weight:normal;m:0
	.shiki,code,pre
		ff: $font-family-code
		fs: 0.9rem
		* ff: $font-family-code; fs: 0.9rem
	p,td,li
		code,pre
			d:inline-block
			bgc:cooler1
			p:0.1rem 0.2rem
			border-radius:$spacing-xs
			box-shadow: 1px 1px 1px cooler2
	ol, ul
		m: 0
		li margin-bottom: $spacing-md
	table th,td p:0.2rem 0.3rem
	.row, .col d:flex;gap:1rem;align-items:flex-start;justify-content:flex-start
	.row flex-direction:row
	.col flex-direction:column
	.third flex: 0.3
	.half flex: 0.5
	.front-matter-page
		d:flex
		m: auto
		w: $page-width
		.fmp-toc
			flex: 0.25
			flex-direction: column
		.fmp-content
			flex-direction: column
		.fmp-content-with-toc
			flex: 0.75
		.fmp-content-full
			flex: 1

export tag SiteClient
	prop screen = initialScreen
	prop query = {}
	prop params = {}
	prop locals = {}
	NavSearch = null
	#
	# after loading a screen and the data update the browser
	#
	def afterLoadScreen
		const screenTitle = get screen, "title"
		const metaTitle = get screen, "data.meta.title"
		const localsTitle = get locals, "title"
		const articleTitle = get locals, "article.title"
		const title = screenTitle or metaTitle or localsTitle or articleTitle
		if hasContent title
			# browser title
			document.title = window.unescape title
		imba.commit!
		# prevent double loading screens
		initialLoaded = true
	#
	# dynamic load routes, data loading e.g. GET
	#
	def loadScreen route
		try
			const mod = await route.load!
			# prevent double mounting the screen
			if initialLoaded then screen = mod.default
		catch loadScreenErr
			const { message, stack } = loadScreenErr
			console.error "error loading screen", route.pattern, message, stack
			screen = Error500
		if isFunction(screen.GET) and initialLoaded
			# async page
			const req = { url: window.location.pathname, query, params }
			const res = { locals:{} }
			screen.GET req, res, do(err)
				if not isNil err
					const { message, stack } = err
					console.error "error on screen GET", message, stack
				locals = res.locals
				afterLoadScreen!
			return
		# sync page
		afterLoadScreen!
	#
	# route change event from imba router
	#
	def routerChange
		let found = false
		for route in routes
			const match = imba.router.match route.pattern
			if isObject(match)
				params = match
				query = qs.parse window.location.search
				loadScreen route
				found = true
				break
		if not found
			params = {}
			loadScreen fallbackRoute
	#
	# state decode
	#
	def loadState
		const template1 = document.getElementById MELTDOWN_STATE1
		const template2 = document.getElementById MELTDOWN_STATE2
		const state1 = template1.innerHTML
		const state2 = template2.innerHTML.split("").reverse!.join("")
		let state = state1 + state2
		state = fromBinary state
		state = JSON.parse state
		if not isEmpty(state.query) then query = state.query
		if not isEmpty(state.params) then params = state.params
		if not isEmpty(state.locals) then locals = state.locals
	#
	# when the client loads we synchronize state
	#
	def awaken
		loadState!
		router.on "change", routerChange.bind(this)
		routerChange!
	css
		#site-top
			border-bottom: 1px solid $color-sep
			p: $spacing-sm $spacing-md
			d:flex
			#top-left, #top-right d:flex;align-items:center
			#top-right ml: auto
			nav-link mr:$spacing-md;transition:background-color 100ms
			nav-link * td:none;c:cooler6
			nav-link *@hover c:cooler4
		main mt:1rem
		#site-bottom
			mt:3rem
			p:3rem
			border-top: 1px solid $color-sep
			nav-link * c:cooler6
		.icon fs:25px
	<self>
		<#site-top>
			<#top-left>
				<nav-link to="/"><div.icon><thin-icon name="fallout-shelter">
				<nav-link to="/"> "Meltdown"
			<#top-right>
				<nav-link to="/get-started"> "Get Started"
				<nav-link to="/community"> "Community"
				if process.env.MELTDOWN_SEARCH_INDEX is "true"
					<NavSearch>
		<main>
			<{screen} query=query params=params locals=locals>
		<#site-bottom.row>
			<.col.third>
				<nav-link to="/"> "Home"
				<nav-link to="/community"> "Community"
			<.col.third>
				"made by us"
			<.col.third>
				""
