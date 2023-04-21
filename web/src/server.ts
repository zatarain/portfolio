// require('dotenv').config();
let script = 'dev'
let method = 'nextDev'
if (process.env.NODE_ENV == 'production') {
	script = 'start'
	method = 'nextStart'
}
const cli = require(`next/dist/cli/next-${script}`);
cli[method](['-p', process.env.PORT || 5000]);
