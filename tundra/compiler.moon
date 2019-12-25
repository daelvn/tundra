-- tundra.compiler
-- Compiles ast to code
-- By Pancakeddd
import fst, snd, trd, nam, quote from require "tundra.utils"

create_args = (t) -> table.concat t, ", "

create_atom = (t) ->
  z = ["#{k} = #{v}" for k, v in pairs t]
  "{#{create_args z}}"

create_function = (args, f, ret=false) ->
  r = do
    if ret
      "return "
    else
      ""
  "function(#{create_args args})\n#{r .. table.concat(f, "\n")}\nend"

set = (left, right, l=true) ->
  loc = do
    if l
      "local "
    else
      ""
  loc .. left .. " = " .. right

unpack_name = (t) ->
  switch nam t
    when "ref", "atom"
      return fst t

create_call = (name, args) ->
  "#{name}(#{create_args args})"

node_compile_functions =
  body: (node) =>
    table.concat((for n in *node
      @ n), "\n")

  assignment: (node, l=true) =>
    left = unpack_name fst node
    right = @ snd node
    set left, right, l

  container: (node, l=true) =>
    contain = unpack_name fst node
    v_contained = snd node
    
    switch nam v_contained
      when "all_wildcard"
        set contain, create_function({'...'}, {create_atom {type: quote(contain), '...'}}, true)
      when "atom"
        un = [unpack_name v for v in *node[2,]]
        set contain, create_function(un, {create_atom {type: quote(contain), table.concat un}}, true)
  
  call: (node) =>
    called = fst node
    called_name = unpack_name called

    switch nam called
      when "atom"
        create_call called_name, [@ v for v in *node[2,]]


  atom: (node) =>
    return fst node if tonumber fst node
    create_atom {type: quote fst node}
      

compileNode = (node) ->
  f = node_compile_functions[nam node]
  return f compileNode, node if f
  error "Could not find compiling function for #{nam node}"

{:compileNode}