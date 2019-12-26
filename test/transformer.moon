import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
import compileNodeToFile   from  require "tundra.compiler"

ast = matchString [[ 

  test x = do
    y <- math.sin x
    print y
  end

]]

log "ast",              inspect ast

transformed = (apply transformers) ast
log "transformed",      inspect transformed
log "compiled", compileNodeToFile transformed, "poc/test2.lua"