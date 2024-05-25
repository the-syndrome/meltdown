import "../node_modules/@phosphor-icons/web/src/thin/style.css"
import "./components/nav-link"
import "./components/nav-button"
import "./components/thin-icon"

import isNil from "lodash/isNil"
import isEmpty from "lodash/isEmpty"
import isString from "lodash/isString"
import isObject from "lodash/isObject"
import isFunction from "lodash/isFunction"
import get from "lodash/get"
import qs from "qs"
import routes from "../.tmp/routes"
import { fromBinary } from "./lib/encoding"
import { isNode } from "./lib/environment"
import Error404 from "./pages/_Error404"
import Error500 from "./pages/_Error500"

const fallbackRoute = { pattern: "*", load: do import("./pages/posts/[slug].imba") }
let initialScreen
let initialLoaded = false
const MELTDOWN_STATE1 = process.env.MELTDOWN_STATE1
const MELTDOWN_STATE2 = process.env.MELTDOWN_STATE2

if not isNode
	const siteMain = document.getElementById "site-main"
	if not isNil(siteMain) then initialScreen = siteMain.firstChild

global css
	html,body p:0;m:0
	body bgc:rgb(253, 248, 243)
	h1,h2,h3 font-weight:normal;m:0
	p,td,li
		code,pre d:inline-block;bgc:cooler1;p:0.1rem 0.2rem;ff:monospace
	.shiki ff:monospace
	table th,td p:0.2rem 0.3rem
	.row, .col d:flex;gap:1rem
	.row flex-direction:row
	.col flex-direction:column
	.third flex: 0.3

export tag SiteClient
	prop screen = initialScreen
	prop query = {}
	prop params = {}
	prop locals = {}
	#
	# after loading a screen and the data update the browser
	#
	def afterLoadScreen
		const title = screen.title or locals.title or get(locals, "article.title")
		if isString(title)
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
			screen = mod.default
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
			# https://angrytools.com/gradient/
			bg: linear-gradient(90deg, rgba(238, 130, 238, 0.1) 0%, rgba(0, 209, 255, 0.15) 100%)
			border-bottom: 1px solid  rgba(0, 209, 255, 0.15)
			pl: 0.6rem
			#top-inner d:flex;align-items:center
			nav-link p:0.6rem;transition:background-color 100ms
			nav-link * td:none;c:cooler6
			nav-link *@hover c:cooler4
		#site-main, #top-inner, #site-bottom max-width: 1100px;m:auto
		#site-main mt:1rem
		#site-bottom
			mt:3rem
			p:3rem
			border-top: 1px solid  rgba(0, 209, 255, 0.15)
			nav-link * c:cooler6
		.icon fs:25px
	<self>
		<div#site-top>
			<div#top-inner>
				<nav-link to="/"><div.icon><thin-icon name="fallout-shelter">
				<nav-link to="/"> "Home"
				<nav-link to="/community"> "Community"
		<div$main#site-main>
			<{screen} query=query params=params locals=locals>
		<div#site-bottom.row>
			<div.col.third>
				<nav-link to="/"> "Home"
				<nav-link to="/community"> "Community"
			<div.col.third>
				"©️ your name 2024"
			<div.col.third>
				""
