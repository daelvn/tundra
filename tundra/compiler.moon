-- tundra.compiler
-- Compiles ast to code
-- By Pancakeddd
import fst, snd, trd, nam, quote from require "tundra.utils"

createArgs = (t) -> table.concat t, ", "

createAtom = (t) ->
  z = ["#{k} = #{v}" for k, v in pairs t]
  "{#{createArgs z}}"

createFunction = (args, f, ret=false) ->
  r = do
    if ret
      "return "
    else
      ""
  "function(#{createArgs args})\n#{r .. table.concat(f, "\n")}\nend"

set = (left, right, l=true) ->
  loc = do
    if l
      "local "
    else
      ""
  loc .. left .. " = " .. right

unpackName = (t) ->
  switch nam t
    when "ref", "atom"
      return fst t

createCall = (name, args) ->
  "#{name}(#{createArgs args})"

node_compile_functions =
  body: (node) =>
    table.concat((for n in *node
      @ n), "\n")

  assignment: (node, l=true) =>
    left = unpackName fst node
    right = @ snd node
    set left, right, l

  container: (node, l=true) =>
    contain = unpackName fst node
    v_contained = snd node
    
    switch nam v_contained
      when "all_wildcard"
        set contain, createFunction({'...'}, {createAtom {type: quote(contain), '...'}}, true)
      when "atom"
        un = [unpackName v for v in *node[2,]]
        set contain, createFunction(un, {createAtom {type: quote(contain), table.concat un}}, true)
  
  call: (node) =>
    called = fst node
    called_name = unpackName called

    switch nam called
      when "atom"
        createCall called_name, [@ v for v in *node[2,]]


  atom: (node) =>
    return fst node if tonumber fst node
    createAtom {type: quote fst node}
      

compileNode = (node) ->
  f = node_compile_functions[nam node]
  return f compileNode, node if f
  error "Could not find compiling function for #{nam node}"

{:compileNode}