fs      = require 'fs'
{exec}  = require 'child_process'
util    = require 'util'
{jsmin} = require 'jsmin'

targetName    = "ajax-chosen"

###
CoffeeScript Options
###
csSrcDir      = "src"
csTargetDir   = "lib"

targetCoffee  = "#{csSrcDir}/build.coffee"
targetJS      = "#{csTargetDir}/#{targetName}.js"
targetMinJS   = "#{csTargetDir}/#{targetName}.min.js"

coffeeOpts    = "-b -j #{targetName}.js -o #{csTargetDir} -c #{targetCoffee}"

coffeeFiles   = [
  "ajax-chosen"
]

###
Event System
###
finishedCallback = {}
finished = (type) ->      
  finishedCallback[type]() if finishedCallback[type]?

finishListener = (type, cb) ->
  finishedCallback[type] = cb
  
notify = (msg) ->
  return if not growl?
  growl.notify msg, {title: "Heello Development", image: "Terminal"}
  
###
Tasks
###
task 'docs', 'Generates documentation for the coffee files', ->
  util.log 'Invoking docco on the CoffeeScript source files'
  
  files = coffeeFiles
  files[i] = "#{csSrcDir}/#{files[i]}.coffee" for i in [0...files.length]

  exec "docco #{files.join(' ')}", (err, stdout, stderr) ->
    util.log err if err
    util.log "Documentation built into docs/ folder."
        
task 'watch', 'Automatically recompile the CoffeeScript files when updated', ->
  util.log "Watching for changes in #{csSrcDir}"
  
  for jsFile in coffeeFiles then do (jsFile) ->
    fs.watchFile "#{csSrcDir}/#{jsFile}.coffee", (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        util.log "#{csSrcDir}/#{jsFile}.coffee updated"
        invoke 'build'
        
task 'build', 'Compile and minify all CoffeeScript source files', ->
  finishListener 'js', -> invoke 'minify'
  invoke 'compile'

task 'compile', 'Compile all CoffeeScript source files', ->
  util.log "Building #{targetJS}"
  contents = []
  remaining = coffeeFiles.length
  
  util.log "Appending #{coffeeFiles.length} files to #{targetCoffee}"
  
  for file, index in coffeeFiles then do (file, index) ->
    fs.readFile "#{csSrcDir}/#{file}.coffee", "utf8", (err, fileContents) ->
      util.log err if err
      
      contents[index] = fileContents
      util.log "[#{index + 1}] #{file}.coffee"
      process() if --remaining is 0
      
  process = ->
    fs.writeFile targetCoffee, contents.join("\n\n"), "utf8", (err) ->
      util.log err if err
      
      exec "coffee #{coffeeOpts}", (err, stdout, stderr) ->
        util.log err if err
        util.log "Compiled #{targetJS}"
        fs.unlink targetCoffee, (err) -> util.log err if err
        finished('js')
        
task 'minify', 'Minify the CoffeeScript files', ->
  util.log "Minifying #{targetJS}"
  fs.readFile targetJS, "utf8", (err, contents) ->
    fs.writeFile targetMinJS, jsmin(contents), "utf8", (err) ->
      util.log err if err
