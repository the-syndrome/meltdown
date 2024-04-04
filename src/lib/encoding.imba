
export def toBinary txt
	const codeUnits = new Uint16Array txt.length
	for index in [0 .. (txt.length - 1)]
		codeUnits[index] = txt.charCodeAt index
	btoa(String.fromCharCode(...new Uint8Array(codeUnits.buffer)))

export def fromBinary encoded
	const binary = atob encoded
	const bytes = new Uint8Array binary.length
	for index in [0 .. (bytes.length - 1)]
		bytes[index] = binary.charCodeAt index
	String.fromCharCode(...new Uint16Array(bytes.buffer))
