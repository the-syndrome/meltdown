# workaround
import PocketBase from "../node_modules/pocketbase/dist/pocketbase.cjs.js"
import { isNode } from "../src/lib/environment"

const pocketbaseUrl = isNode ? process.env.POCKETBASE_URL : "/_pb"
const pb = new PocketBase pocketbaseUrl

export default pb