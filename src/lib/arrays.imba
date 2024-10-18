import isArray from "lodash/isArray"

export def hasItems arr
	isArray(arr) and arr.length > 0
