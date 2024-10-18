import { readFile, writeFile, mkdir, exists } from "fs"

const { NODE_ENV } = process.env
const isPrd = NODE_ENV is "production"

# stringify the input and save it to the path provided.
export def saveJson absolutePath, obj, done
	const spacing = isPrd ? null : "  "
	const source = JSON.stringify obj, null, spacing
	writeFile absolutePath, source, done

# same as `mkdir -p /path/to/somewhere` or mkdirp npm module.
export def mkdirp absolutePath, done
	// does it already exist?
	exists absolutePath, do(ex)
		if ex then return done! // skip it, done
		mkdir(absolutePath, { recursive: true }, done);

# instead of getting a buffer we get a string
export def readText absolutePath, done
	readFile absolutePath, { encoding: "utf8" }, done