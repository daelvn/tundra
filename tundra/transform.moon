-- tundra.transformer
-- AST Transformer for Tundra
-- By Pancakeddd, daelvn
import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import fst, snd, trd, nam, last, quote from require "tundra.utils"

transformers = {
  --removeAsteriskFromWildcard: =>
  --  if @type == "wildcard" then @[1] = nil
  --  return @

  --do_transform: =>
    --if @type == "do"

}

apply = (fnl) -> (node) ->
  -- apply transformations
  for _, fn in pairs fnl do node = fn node
  -- iterate
  for k, elem in pairs node
    if (type elem) == "table"
      node[k] = (apply fnl) elem
  -- return node
  return node

{
  :apply
  :transformers
}