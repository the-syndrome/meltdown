# webpack compatibility can cause false positive
export const isNode =
	typeof process isnt "undefined"
	and process.title isnt "browser"
	and process.execPath isnt "browser"
	and process.arch isnt "browser"
	and typeof global isnt "undefined"
	and typeof queueMicrotask isnt "undefined"
	and typeof setImmediate isnt "undefined"
	and typeof clearImmediate isnt "undefined"
	and typeof TextDecoder isnt "undefined"
	and typeof TextEncoder isnt "undefined"
	and typeof WebAssembly isnt "undefined"

###

⚠️ This needs to be more thorough for client side checking.

Until we fix use `not isNode`

###
export const isBrowser =
	typeof navigator isnt "undefined"
	and typeof document isnt "undefined"