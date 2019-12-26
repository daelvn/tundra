-- tundra.transformer
-- AST Transformer for Tundra
-- By Pancakeddd, daelvn
import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import fst, snd, trd, nam, last, quote, buildNode, deep_copy from require "tundra.utils"


transformers = {
  removeAsteriskFromWildcard: =>
    if @type == "wildcard" then @[1] = nil
    return @

  do_transform: =>
    if @type == "do"
      for i = 1, #@
        node = @[i]
        x = node[1]
        y = node[2]
        print inspect(@[i+1]), nam @[i]
        if nam(node) == "bind"
          node.type = "call"
          node[1] = {"bind", type: "ref"}
          node[2] = y
          node[3] = {{x, type: "args"}, @[i+1], type: "lambda"}
        else if @[i+1]
          
          then_f = deep_copy node
          node.type = "call"
          node[1] = buildNode "ref", {"then"}
          node[2] = then_f
          node[3] = @[i+1]
          print inspect node
      @ = unpack @
    return @

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