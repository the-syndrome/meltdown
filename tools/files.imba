import { writeFile, mkdir } from "fs"

const { NODE_ENV } = process.env
const isPrd = NODE_ENV is "production"

#
# Stringify the input and save it to the path provided.
# @param {string} absolutePath
# @param {object} obj
# @param {function} done
#
export def saveJson absolutePath, obj, done
	const spacing = isPrd ? null : "  "
	const source = JSON.stringify obj, null, spacing
	writeFile absolutePath, source, done


#
# Same as `mkdir -p /path/to/somewhere` or mkdirp npm module.
# @param {string} absolutePath
# @param {function} done
#
export def mkdirp absolutePath, done
	// does it already exist?
	exists absolutePath, do(ex)
		if ex then return done! // skip it, done
		mkdir(absolutePath, { recursive: true }, done);
