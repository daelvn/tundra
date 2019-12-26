import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
import frameFor            from  require "tundra.check"

tee = (x) ->
  log "tee", inspect x
  x

log "Frame", inspect frameFor (apply transformers) matchString [[

Ex.
List.    .= **
x         = List. a. b. c.

]]