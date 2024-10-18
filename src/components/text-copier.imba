import isNil from "lodash/isNil"

tag text-copier
	prop value
	failed = false
	copied = false
	resetTimer = null
	def resetTimers
		if not isNil(resetTimer) then clearTimeout(resetTimer)
		resetTimer = null
	def copy
		resetTimers!
		try
			# imba hack: you can't access navigator straight. unless you use
			# window.navigator it is an error.
			await window.navigator.clipboard.writeText value
			copied = true
		catch err
			const { message, stack } = err
			console.error "error copying with navigator.clipboard", message, stack
			failed = true
		if not copied then failed = true
		const reset = do
			copied = false
			failed = false
			imba.commit!
		resetTimer = setTimeout reset, 3000
	css
		cursor:pointer
		position: relative
		.failed * color:red
		.copied * color:green
	<self.row.vcentered>
		<div
			.outer
			.failed=failed
			.copied=copied
			title=(copied ? "copied" : "copy")
			@click=copy
		>
			if failed
				<thin-icon name="smiley-sad">
			elif copied
				<thin-icon name="check">
			else
				<thin-icon name="copy">
