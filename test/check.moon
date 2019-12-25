import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
import checkProgram        from  require "tundra.check"

tee = (x) ->
  log "tee", inspect x
  x

log "Frame", inspect checkProgram (apply transformers) matchString [[

Boolean. .= [True., False.]
List.    .= **

]]