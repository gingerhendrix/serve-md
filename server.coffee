express    = require('express')
serveIndex = require('serve-index')
pagedown   = require('pagedown')
extra      = require('pagedown-extra').Extra
fs         = require('fs')
path       = require('path')
cons       = require('consolidate')

converter = new pagedown.Converter()
extra.init(converter, {highlighter: "highlight"});

hamlc = cons['haml-coffee']

app = express()
app.port = process.env.PORT || 3000
baseDir = process.cwd()

app.use '/', (req, res, next) ->
  if path.extname(req.path) is '.md'

    fs.readFile baseDir + req.path, 'utf8', (err, data) ->
      if err
        next()
      else
        content = converter.makeHtml(data)

        hamlc __dirname + '/templates/default/single.hamlc', { content: content }, (err, data) ->
          if err
            return next(err)
          else
            res.send data
  else
    next()

app.use '/', serveIndex(process.cwd(), 'icons': true)
app.use '/', express.static(process.cwd())

app.use '/templates/default', express.static(__dirname + '/templates/default/assets')

app.listen app.port, ->
 console.log "Listening on port #{app.port}"
