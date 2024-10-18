
export default tag Home
	prop locals
	static title = "Home"
	css
		max-width: $page-width
		m: auto
		d: block
		box-sizing: border-box
		#intro
			ta: center
			max-width: 300px
			m: auto
			align-items:center
		#features
			border: 1px solid $color-sep
			bw: 1px 0 1px 0
			m: $spacing-lg 0
			p: $spacing-lg 0
			.row, .col, p gap: $spacing-sm;m: $spacing-sm 0
		.panel
			m: $spacing-sm 0
			# p: $spacing-sm
			flex: 1
		#get-started
			border: 2px solid purple9
			border-radius: $spacing-sm
			bgc: purple6
			p: $spacing-md
			m: $spacing-md
			fs: 1.3rem
			ta: center
			* c: purple0;td:none
	<self>
		<.row>
			<#intro.col>
				<img src="/favicon/android-chrome-192x192.png" alt="fallout shelter emoji icon">
				<h2> "Meltdown"
				<h3> "Imba site template"
				<nav-link#get-started to="/get-started"> "Get started"
		<#features>
			<h2> "Features"
			<.row>
				<.col.third>
					<.panel>
						<nav-link to="/features/convention-routing"> "Convention routing"
						<p>
							"Drop markdown, HTML, imba, JS, or TS pages in "
							<code> "./src/pages"
							"and the server will generate a route and connect it's"
							" functionality."
					<.panel>
						<nav-link to="/features/front-matter"> "Front matter"
						<p> "Add meta data to pages with front matter YAML."
					<.panel>
						<nav-link to="/features/components"> "Components"
						<p>
							"""
							A small collection of components for icons and navigation.
							Add yours in
							"""
							<code> "./src/components"
							"."
				<.col.third>
					<.panel>
						<nav-link to="/features/dynamic-data"> "Dynamic data (SSR)"
						<p>
							"Imba, JS, and TS pages can be dynamic, request API data"
							" and render it how you want."
					<.panel>
						<nav-link to="/features/markdown"> "Markdown pages"
						<p>
							"Markdown pages have rich support including table of contents"
							" and syntax highlighting."
					<.panel>
						<nav-link to="/features/html"> "HTML pages"
						<p>
							"HTML pages for when markdown wont get the job done. Table of"
							" contents is provided automatically."
				<.col.third>
					<.panel>
						<nav-link to="/features/ssg">
							"Static Site Generation (SSG)"
						<p>
							"Build however you want, even with dynamic pages, then create a"
							" static snapshot for easy static file publishing."
					<.panel>
						<nav-link to="/features/search"> "Search"
						<p>
							"Search your pages without even needing a third-party service."
					<.panel>
						<nav-link to="https://imba.io/docs/css" external> "Styling"
						<p> "Style it with the imba language styling or CSS."
		<.row>
			<.col.half>
				<h2> "Deploy"
				<nav-link to="/deploy/environment"> "Deploy Environment (.env)"
				<nav-link to="/deploy/combine-static-files"> "Combine Static Files"
				<nav-link to="/deploy/docker"> "Deploy with Docker"
				<nav-link to="/deploy/docker-compose">
					"Deploy with Docker Compose"
				<h3> "Headless CMS"
				<nav-link to="/deploy/with-pocketbase">
					"Deploy with Pocketbase"
				<nav-link to="/deploy/with-directus">
					"Deploy with Directus"
				<nav-link to="/deploy/with-grav">
					"Deploy with Grav"
			<.col.half>
				<h2> "Troubleshooting"
				<nav-link to="/troubleshooting#debug-page">
					<thin-icon name="wrench">
					"Debug page"
				<nav-link to="/troubleshooting#unmemoized-nodes">
					<thin-icon name="bug">
					"Unmemoized nodes"
				<nav-link to="/troubleshooting#server-keeps-restarting">
					<thin-icon name="smiley-nervous">
					"Server keeps restarting"
				<nav-link to="/troubleshooting#unexpected-end-of-file-in-json">
					<thin-icon name="bug">
					"Unexpected end of file in JSON"
				<nav-link to="/troubleshooting#test-for-broken-links">
					<thin-icon name="bug">
					"Test for broken links"
				<nav-link to="/community">
					"Ask community in chat"
				<nav-link to="https://github.com/the-syndrome/meltdown/issues" external>
					"Create issue"
