###

Markdown pages are converted to MDAST data structure.
https://github.com/syntax-tree/mdast

###

import isNil from "lodash/isNil"
import isString from "lodash/isString"
import get from "lodash/get"
import { hasContent } from "../lib/strings"
import { hasItems } from "../lib/arrays"

tag MarkdownBlockquote < blockquote
	prop node = {}
	<self>
		for child in (node.children or [])
			<MarkdownNode node=child>

tag MarkdownCode
	prop node = {}
	css
		position: relative
		margin-bottom: $spacing-lg
		border: 1px solid $color-sep
		border-radius: $spacing-sm
		p: $spacing-md
		text-copier
			position: absolute
			right: $spacing-xs
			top: $spacing-sm
		.shiki-outer * pre m:0;p:0
	<self>
		<text-copier value=node.value>
		if hasContent(node.shiki)
			<.shiki-outer innerHTML=node.shiki>
		else
			<code> node.value

tag MarkdownDefinition < dd
	prop node = {}
	<self id=node.identifier>
		node.label

tag MarkdownDelete
	prop node = {}
	css del td:strikethough
	<self>
		<del>
			for child in (node.children or [])
				<MarkdownNode node=child>

tag MarkdownEmphasis < em
	prop node = {}
	<self>
		for child in (node.children or [])
			<MarkdownNode node=child>

tag MarkdownHeading
	prop node = {}
	css m: $spacing-md 0
	<self>
		const tagName = "h{node.depth}"
		<{tagName} id=node.id>
			for child in (node.children or [])
				<MarkdownNode node=child>

tag MarkdownHtml
	prop node = {}
	<self innerHTML=node.value>

tag MarkdownImage
	prop node = {}
	<self>
		<img src=node.url alt=node.alt title=node.title>

tag MarkdownInlineCode < code
	prop node = {}
	css
		d:inline
	<self>
		node.value

tag MarkdownLink
	prop node = {}
	css d:inline
	<self>
		<a href=node.url title=(hasContent(node.title) ? node.title : undefined)>
			for child in (node.children or [])
				<MarkdownNode node=child>

tag MarkdownList
	prop node = {}
	css
		ul, ol
			margin: 0 0 0 $spacing-lg
			padding: 0
	<self>
		const { ordered } = node
		const tagName = ordered ? "ol" : "ul"
		<{tagName}>
			for listItem in get(node, "children", [])
				<li>
					if listItem.checked is true
						<input type="checkbox" checked>
					elif listItem.checked is false
						<input type="checkbox" checked>
					for child in listItem.children
						<MarkdownNode node=child>

tag MarkdownParagraph
	prop node = {}
	css
		mb: $spacing-lg
		* d:inline;text-wrap:wrap
	<self>
		<p>
			for child in (node.children or [])
				<MarkdownNode node=child>

tag MarkdownRoot
	prop node = {}
	<self>
		for child in (node.children or [])
			<MarkdownNode node=child>

tag MarkdownStrong < strong
	prop node = {}
	<self>
		for child in (node.children or [])
			<MarkdownNode node=child>

tag MarkdownThematicBreak
	prop node = {}
	css
		m: $spacing-lg 0``
		bgc: $color-sep
		h: 1px
		overflow: hidden
	<self>
		<hr>

tag MarkdownTable
	prop node = {}
	css
		table mb: $spacing-lg
	<self>
		<table><tbody>
			for row in get(node, "children", [])
				<tr>
					for cell, column in get(row, "children", [])
						<td align=(hasItems(node.align) and node.align[column])>
							for child in get(cell, "children", [])
								<MarkdownNode node=child inline=true>

tag MarkdownUnknown
	prop node = {}
	css
		border: 1px solid brown
	<self>
		"MarkdownUnknown: {node.type}"

tag MarkdownNode
	prop node = {}
	css d:inline
	<self>
		switch node.type
			when "blockquote"
				<MarkdownBlockquote node=node>
			when "break"
				<br>
			when "code"
				<MarkdownCode node=node>
			when "definition"
				<MarkdownDefinition node=node>
			when "delete"
				<MarkdownDelete node=node>
			when "emphasis"
				<MarkdownEmphasis node=node>
			when "footnoteDefinition"
				<MarkdownDefinition node=node>
			when "footnoteReference"
				<MarkdownDefinition node=node>
			when "heading"
				<MarkdownHeading node=node>
			when "html"
				<MarkdownHtml node=node>
			when "image"
				<MarkdownImage node=node>
			when "imageReference"
				<MarkdownImage node=node>
			when "inlineCode"
				<MarkdownInlineCode node=node>
			when "link"
				<MarkdownLink node=node>
			when "linkReference"
				<MarkdownLink node=node>
			when "list"
				<MarkdownList node=node>
			when "paragraph"
				<MarkdownParagraph node=node>
			when "root"
				<MarkdownRoot node=node>
			when "strong"
				<MarkdownStrong node=node>
			when "text"
				node.value
			when "thematicBreak"
				<MarkdownThematicBreak node=node>
			when "table"
				<MarkdownTable node=node>
			else
				<MarkdownUnknown node=node>

export tag MarkdownToc
	prop table
	<self>
		<MarkdownList node=table>

export default tag MarkdownPage
	prop meta
	prop showToc
	prop table
	prop mdast
	get tocSide
		isString(meta.toc) ? toc : "left"
	<self.front-matter-page>
		if showToc and tocSide is "left"
			<div.fmp-toc>
				<MarkdownToc table=table>
		<.fmp-content .fmp-content-with-toc=showToc .fmp-content-full=(not showToc)>
			<MarkdownNode node=mdast>
		if showToc and tocSide is "right"
			<div.fmp-toc>
				<MarkdownToc table=table>
