import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
import compileNodeToFile   from  require "tundra.compiler"

ast = matchString [[ 

  io/write "Hello"

]]

log "ast",              inspect ast

transformed = (apply transformers) ast
log "transformed",      inspect transformed
log "compiled", compileNodeToFile transformed, "poc/test2.lua"