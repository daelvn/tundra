import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
--import checkProgram        from  require "tundra.check"
import compileNodeToFile   from  require "tundra.compiler"

tee = (x) ->
  log "tee", inspect x
  x

ast = (apply transformers) matchString [[

  if (eq b true.) (print "hey") (print "nope")

]]

log "ast",      inspect ast
log "compiled", compileNodeToFile ast, "poc/test.lua"