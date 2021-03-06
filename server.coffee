express    = require('express')
serveIndex = require('serve-index')
pagedown   = require('pagedown')
extra      = require('pagedown-extra').Extra
fs         = require('fs')
path       = require('path')
cons       = require('consolidate')
fm         = require('front-matter')
coffee     = require('coffee-script')

converter = new pagedown.Converter()
extra.init(converter, {highlighter: "highlight"});

converter.hooks.chain "preConversion",  (text) ->
  matches = text.match(/!include\([^)]*\)/g) || []

  for match in matches
    includePath = match.match(/\(([^)]*)\)/)[1]
    #console.log "Include #{match} - #{includePath}"
    try
      data = fs.readFileSync "#{baseDir}/_#{includePath}.latex", 'utf8'
    catch e
      console.log "Error", e

    if data?
      #console.log "Data", data
      text = text.replace match, data

  text

hamlc = cons['haml-coffee']

app = express()
app.port = process.env.PORT || 3000
baseDir = process.argv[2] || '.'
baseDir = path.resolve(process.cwd(), baseDir)

console.log "Serving #{baseDir}"

app.use '/', (req, res, next) ->
  if path.extname(req.path) is '.md'

    fs.readFile baseDir + req.path, 'utf8', (err, data) ->
      if err
        next()
      else
        data = fm(data);

        page = data.attributes
        page.content = converter.makeHtml(data.body)

        hamlc __dirname + '/templates/default/single.hamlc', page, (err, data) ->
          if err
            return next(err)
          else
            res.send data

  else if path.extname(req.path) is '.coffee'
    fs.readFile baseDir + req.path, 'utf8', (err, data) ->
      if err
        next()
      else
        res.send coffee.compile(data)

  else
    next()

app.use '/', serveIndex(baseDir, 'icons': true)
app.use '/', express.static(baseDir)

app.use '/templates/default', express.static(__dirname + '/templates/default/assets')

app.listen app.port, ->
 console.log "Listening on port #{app.port}"
