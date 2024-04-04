import "../node_modules/@phosphor-icons/web/src/thin/style.css"
import "./components/nav-link"
import "./components/nav-button"
import "./components/thin-icon"

import isNil from "lodash/isNil"
import isEmpty from "lodash/isEmpty"
import isObject from "lodash/isObject"
import isFunction from "lodash/isFunction"
import qs from "qs"
import routes from "../.tmp/routes"
import { fromBinary } from "./lib/encoding"
import { isNode } from "./lib/environment"

const fallbackPage = { pattern: "*", load: do import("./pages/posts/[slug].imba") }
let initialScreen
let initialLoaded = false

if not isNode
	const siteMain = document.getElementById "site-main"
	if not isNil(siteMain) then initialScreen = siteMain.firstChild

global css
	body m:0;bgc:rgb(253, 248, 243)
	h1, h2, h3 font-weight:normal
	code,pre bgc:cooler1;p:0.1rem
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
	# dynamic load routes, data loading e.g. GET
	#
	def loadScreen route
		try
			const mod = await route.load()
			screen = mod.default
		catch loadScreenErr
			const { message, stack } = loadScreenErr
			console.error "error loading screen", route.pattern, message, stack
			screen = ServerError500
		if isFunction(screen.GET) and initialLoaded
			const req = { url: window.location.pathname }
			const res = {locals:{}}
			screen.GET req, res, do(err)
				if not isNil err
					const { message, stack } = err
					console.error "error on screen GET", message, stack
					if err.status is 404
						screen = NotFound404
					elif err.status >= 500
						screen = ServerError500
				locals = res.locals
				imba.commit!
		if not initialLoaded then initialLoaded = true
		imba.commit!
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
			loadScreen fallbackPage
	#
	# state decode
	#
	def iNEmQLMasm
		const iNEmQL = document.getElementById "iNEmQL"
		const JW29a4 = document.getElementById "JW29a4"
		const recis1 = iNEmQL.innerHTML
		const recis2 = JW29a4.innerHTML.split("").reverse!.join("")
		let recis = recis1 + recis2
		recis = fromBinary recis
		recis = JSON.parse recis
		if not isEmpty(recis.query) then query = recis.query
		if not isEmpty(recis.params) then params = recis.params
		if not isEmpty(recis.locals) then locals = recis.locals
	#
	# when the client loads we synchronize state
	#
	def awaken
		iNEmQLMasm!
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
			nav-link@hover bgc:rgba(238, 130, 238, 0.16)
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
