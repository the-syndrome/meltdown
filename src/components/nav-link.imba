import isNil from "lodash/isNil"

tag nav-link
	prop to
	prop external = false
	get route
		if external then undefined else to
	get target
		if external then "_blank" else undefined
	css
		d:inline-block
		icon d:inline-block
	<self>
		<a href=to route-to=route target=target>
			<slot>
			if external
				<thin-icon name="arrow-square-out">
