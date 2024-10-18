const fuseOpts = {
	includeScore: true
	includeMatches: true
	findAllMatches: true
	useExtendedSearch: true
	keys: ["title", "text", "pathname"]
}

export default tag NavSearch
	open = false
	query = ""
	selectedIndex = 0
	data = null
	pages = null
	debounce = null
	goSearch = null
	fuse = null
	loaded = false
	results = []
	def loadSearchIndex
		if loaded then return
		const { default: Fuse } = await import "fuse.js"
		const { default: debounce } = await import "lodash/debounce"
		const pagesRes = await window.fetch("/search-index.json", {
			headers: { Accept: "application/json" }
		})
		pages = await pagesRes.json!
		goSearch = debounce computeResults, 200
		fuse = new Fuse(pages, fuseOpts)
		loaded = true
	def toggleResults val
		open = (typeof val is "boolean") ? val : !open
		loadSearchIndex!
	def computeResults
		selectedIndex = 0
		results = fuse.search query
		imba.commit!
	def reset
		$queryText.blur!
		open = false
		query = ""
		results = []
		imba.commit!
		true
	def queryKeyDown evt
		const { keyCode } = evt
		if keyCode is 27 # Esc
			open = false
			return
		elif keyCode is 13 and results.length > 0
			# Enter
			imba.router.go results[selectedIndex].item.pathname
			reset!
		elif keyCode is 38
			# Up
			if selectedIndex > 0
				selectedIndex -= 1
		elif keyCode is 40
			# Down
			if selectedIndex < results.length - 1
				selectedIndex += 1
		elif query.length > 0 and typeof goSearch is "function"
			goSearch!
	def querySearch evt
		if query is ""
			# user clicked little "x" to clear in the input[type=search]
			results = []
			imba.commit!
	def queryBlur evt
		# it has to be deferred to allow clicking elements in the list
		setTimeout reset.bind(this), 50
	def currentlyViewing pathname
		# prevent trying to read window on server
		if not isNode and window.location.pathname is pathname
	css
		position: relative
		border: 2px solid transparent
		border-radius: $spacing-sm
		bgc: purple0
		p: $spacing-xs $spacing-sm
		width:100px
		height: 19px
		transition: all 80ms
		display: flex
		z-index: 1000
		&:hover
			border-color: purple9
			bgc: purple1
		&.open
			width: 300px
		.layer
			position: absolute
			top: 0
			right: 0
			bottom: 0
			left: 0
		#search-mask
			margin-top: 2px
		#search-textbox
			input
				border:none
				outline:none
				width: 100%
				bgc: transparent
		#search-results
			border: 1px solid $color-sep
			bgc: $color-bg
			position: absolute
			top: 35px
			right: 1px
			w: 0
			h: 0
			opacity: 0
			transition: all 80ms
			p: $spacing-sm
			d:flex
			flex-direction: column
			box-shadow: 3px 3px 3px $color-sep
			&.open
				opacity: 1
				w: 300px
				h: auto
		.search-result-item
			d: flex
			flex: 1
			p: $spacing-sm
			d: block
			w: 97%
			align-items: center
			justify-content: center
			* td:none
			.here, .here * c:gray6;fs:0.8rem
			&.selected
				bgc: purple9
				.title c: purple0
				.here, .here * c:gray3
		#search-help
			margin-top: $spacing-md
			span fs:0.8rem
		#no-results p:$spacing-md;ta:center
	<self.open=open>
		<div#search-mask.layer .open=open>
			if query is ""
				<thin-icon name="magnifying-glass">
				<span> "Search"
		<div#search-textbox.layer>
			<input$queryText
				type="search"
				bind=query
				@focus=toggleResults(true)
				@blur=queryBlur
				@keydown=queryKeyDown
				@search=querySearch
			>
		<#search-results .open=open>
			if results.length is 0
				<div#no-results> "No results"
			for { item }, index in results
				<nav-link.search-result-item
					to=item.pathname
					.selected=(selectedIndex is index)
					@click=reset
				>
					<.title>
						item.title
					if currentlyViewing(item.pathname)
						<span.here>
							<thin-icon name="map-pin-simple">
							"(You are here)"
						if query.length is 0 and results.length is 0
			<#search-help.row>
				<div.row>
					<thin-icon name="key-return">
					<span> "Enter to navigate"
				<div.row>
					<thin-icon name="arrow-up">
					<thin-icon name="arrow-down">
					<span> "Up and Down keys select"

