import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
--import checkProgram        from  require "tundra.check"
import compileNode         from  require "tundra.compiler"

tee = (x) ->
  log "tee", inspect x
  x

ast = (apply transformers) matchString [[

  z = a. b

]]

log "ast",      inspect ast
log "compiled", compileNode ast