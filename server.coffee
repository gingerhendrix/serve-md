express    = require('express')
serveIndex = require('serve-index')
pagedown   = require('pagedown')
fs         = require('fs')
path       = require('path')

converter = new pagedown.Converter()

app = express()
app.port = process.env.PORT || 3000
baseDir = process.cwd()

app.use '/', (req, res, next) ->
  console.log "My Middleware", req.path
  if path.extname(req.path) is '.md'
    fs.readFile baseDir + req.path, 'utf8', (err, data) ->
      if err
        next()
      else
       res.send converter.makeHtml(data)
   else
     next()

app.use '/', serveIndex(process.cwd(), 'icons': true)
app.use '/', express.static(process.cwd())

app.listen app.port, ->
 console.log "Listening on port #{app.port}"
