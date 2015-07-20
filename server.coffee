express    = require('express')
serveIndex = require('serve-index')

app = express()
app.port = process.env.PORT || 3000

app.use '/', serveIndex(process.cwd(), 'icons': true)
app.use '/', express.static(process.cwd())

app.listen app.port, ->
 console.log "Listening on port #{app.port}"
