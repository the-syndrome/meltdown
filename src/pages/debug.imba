import isNil from "lodash/isNil"
import bytes from "bytes"
import { hasContent } from "../lib/strings"
import summary from "../../.tmp/summary.json"

export default tag DebugPage
	css
		.dim c:cooler5
	<self>
		<table>
			<thead>
				<tr>
					<td> "page"
					<td> "pattern"
					<td> "type"
					<td align="center"> "toc?"
					<td> "size"
			<tbody> for page in summary
				<tr>
					<td> page.pagesRelativePath
					<td>
						if isNil(page.pattern)
							<span.dim> "(none)"
						elif hasContent(page.pattern) and page.pattern.includes(":")
							<div>
								page.pattern
								<span.dim> "(dynamic)"
						elif hasContent(page.pattern)
							<nav-link to=page.pattern> page.pattern
					<td> page.type
					<td align="center">
						if page.hasTable is true
							<thin-icon name="check">
						else
							<thin-icon name="x">
					<td><code> bytes page.size