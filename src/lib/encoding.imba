###
It's used when serializing the state to a base64 string. It's different from
using only window.atob and window.btoa. Doing it this way preserves the unicode
emoji which we need to do.
###

export def toBinary txt
	const u16a = new Uint16Array txt.length
	for index in [0 .. (txt.length - 1)]
		u16a[index] = txt.charCodeAt index
	const u8a = new Uint8Array u16a.buffer
	let str = ""
	for byte in u8a
		str += String.fromCharCode byte
	btoa str

export def fromBinary encoded
	const binary = atob encoded
	const u8a = new Uint8Array binary.length
	for index in [0 .. (u8a.length - 1)]
		u8a[index] = binary.charCodeAt index
	const u16a = new Uint16Array u8a.buffer
	let str = ""
	for twoByte in u16a
		str += String.fromCharCode twoByte
	str