-- tundra.transformer
-- AST Transformer for Tundra
-- By Pancakeddd, daelvn
import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import FileGenerator       from require 'tundra.core'
import fst, snd, trd, nam, last, quote, buildNode, deep_copy from require "tundra.utils"

protected_names = {
  if: true
  then: true
}

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
        if nam(node) == "bind"
          node.type = "call"
          node[1] = {"bind", type: "ref"}
          node[2] = y
          node[3] = {{x, type: "args"}, @[i+1], type: "lambda"}
        else if @[i+1]
          then_f = deep_copy node
          node.type = "call"
          node[1] = buildNode "ref", {"next"}
          node[2] = then_f
          node[3] = @[i+1]
      @ = unpack @
    return @

  index: =>
    if @type == "ref"
      @[1] = @[1]\gsub "%/", "."
    return @

  call_format: =>
    if @type == "call"
      if @[2] == ":"
        @type = "call_nc"
        c = @[3]
        table.remove @, 2
        @[2] = c
    @


  keyword_change: =>
    if @type == "ref"
      if protected_names[fst(@)]
        @[1] = "_" .. @[1]
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