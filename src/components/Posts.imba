import dayjs from "dayjs"

export default tag Posts
	prop articles
	<self>
		<div.updates>
			for { pathname, title, created } in (articles or [])
				<div.update-item[d:flex;p:0.3rem 0;border-bottom:1px solid silver]>
					<nav-link to=pathname> title
					<time[ml:auto]> dayjs(created).format("YYYY-MM-DD")