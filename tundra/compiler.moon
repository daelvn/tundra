-- tundra.compiler
-- Compiles ast to code
-- By Pancakeddd
import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import fst, snd, trd, nam, last, quote from require "tundra.utils"

Args = (t) -> table.concat t, ", "

FormatAtomKey = (k, v) ->
  if tonumber k
    v
  else
    "#{k} = #{v}"

Atom = (typ, t) ->
  z = [FormatAtomKey k, v for k, v in pairs t]
  "setmetatable({#{Args z}}, {__type = #{typ}})"

AtomPredicent = (typ, t, a) ->
  z = [FormatAtomKey k, v for k, v in pairs t]
  table.insert z, a
  "setmetatable({#{Args z}}, {__type = #{typ}})"

Function = (args, f, ret=false) ->
  r = do
    if ret
      "return "
    else
      ""
  "function(#{Args args})\n#{r .. table.concat(f, "\n")}\nend"

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

Call = (name, args) ->
  "#{name}(#{Args args})"

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
        set contain, Function({'...'}, {Atom quote(contain), {'...'}}, true)
      when "list"
        z = for i = 1, #v_contained
          if name = unpackName v_contained[i]
            "_#{name .. i}"
          else
            "_#{i}"

        set contain, Function(z, {Atom quote(contain), z}, true)
      when "atom"
        un = [unpackName v for v in *node[2,]]
        set contain, Function(un, {Atom quote(contain), {table.concat un}}, true)
  
  call: (node) =>
    called = fst node
    called_name = unpackName called

    Call called_name, [@ v for v in *node[2,]]

  group: (node) =>
    @ fst node


  atom: (node) =>
    return fst node if tonumber fst node
    return fst node if snd node
    Atom quote(fst node), {}

  function: (node) =>
    name = unpackName fst node
    set name, Function([unpackName v for v in *node[2,#node]], {@(last node)}, true)

  lambda: (node) =>
    Function([unpackName v for v in *node[1]], {@ node[2]}, true)
    
  ref: (node) => fst node

compileNode = (node) ->
  f = node_compile_functions[nam node]
  return f compileNode, node if f
  error "Could not find compiling function for #{nam node}"

compileNodeToFile = (node, filename) ->
  out = compileNode node
  with io.open filename, "w"
    \write out
    \close!

{:compileNode, :compileNodeToFile}