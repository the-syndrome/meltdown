import slug from "slug"
import kebabCase from "lodash/kebabCase"
import isString from "lodash/isString"

# string starts with a date like /2024/09/01
# articlePattern.test("/2024/09/01") is true
export const articlePattern = /^\/\d{4}\/\d{2}\/\d{2}/

###
Create a dash-based string for consistent naming for collections, anchor hashes,
and ids.

Example input -> output

MyFavoriteRestaurants -> my-favorite-restaurants
one----two -> one-two

@method slugify
@param {string} val
@returns {string}
###
export def slugify val
	slug(kebabCase(val.trim()))

export def anchorHash name
	"#" + slugify(name)

export def hasContent val
	isString(val) and val.length > 0

export def randomId type = "rid"
	`{type}-{Math.random().toString().substring(2)}`
