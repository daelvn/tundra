-- tundra.check
-- Type checking for Tundra
-- By daelvn
import DEBUG         from  require "tundra.config"
import inspect, log  from (require "tundra.debug" ) DEBUG
import tundraError   from  require "tundra.error"
import fst, snd, trd from  require "tundra.utils"

-- Create a new instance of the language frame
Tundra = ->
  setmetatable {
    atoms:      {}
    references: {}
    lookup:     {} -- type lookup
  }, {}

local checkProgram

-- turns a List node into a string
listToString = (L) ->
  s = "["
  for v in *L
    log "listToString", inspect v
    switch v.type
      when "atom" then s ..= "#{fst v}.,"
      when "ref"  then s ..= "#{fst v},"
  s = s\sub 1, -2
  s .. "]"

-- resolves a reference
resolveReference = (xref) =>
  log "resolveReference (xref)", (xref or "?")
  ref = @references[xref]
  tundraError "Reference '#{xref}' could not be resolved" unless ref
  switch fst ref
    when "ref"
      log "resolveReference (->ref)", inspect ref
      return resolveReference @, snd ref
    else
      if (trd ref) == "atom" then return @atoms[snd ref]
  tundraError "Reference '#{inspect ref}%{red}' could not be resolved"

-- checks the types in any node
checkNode = (node) =>
  log "checkNode", inspect node
  switch node.type
    when "body" then checkProgram node
    when "ref"
      log "ref/", "=> #{fst node}"
      return {node.type, (fst node), "ref"}
    when "list"
      log "list/", "=> #{inspect [v for v in *node]}"
      r = {node.type, (listToString node), "list"}
      for v in *node do table.insert r, checkNode @, v
      r
    when "atom", "wildcard", "wildcard_number", "all_wildcard"
      log "node/", "=> #{node.type} (#{fst node})"
      return {node.type, (fst node), "atom"}
    when "call"
      log "call/", "=> #{fst node} $ #{inspect node}"
      r = {node.type, (fst node), "call"}
      for v in *node[2,] do table.insert r, v
      r
    when "container"
      atom = checkNode @, fst node
      as   = checkNode @, snd node
      tundraError "Expected Atom in container definition" if (fst atom) != "atom"
      log "container/", "=> #{snd atom}. = #{inspect as}"
      @atoms[snd atom] = as
      if (fst as) == "list"
        for elem in *as[4,]
          switch fst elem
            when "atom"
              unless @atoms[snd elem] then @atoms[snd elem] = {"constructor", (snd elem), "atom", }
    when "assignment"
      ref  = checkNode @, fst node
      xref = checkNode @, snd node
      tundraError "Expected Ref in assignment LHS" if (fst ref) != "ref"
      log "assignment/", "=> #{snd ref} (#{trd ref}) = #{inspect xref} (#{trd ref})"
      switch trd xref
        when "atom"
          unless @atoms[snd xref] then @atoms[snd xref] = {"insitu", (snd xref), "atom"}
          @lookup[snd ref]     = @atoms[snd xref]
          @references[snd ref] = {"atom", (snd xref), "atom"}
        when "ref"
          @lookup[snd ref]     = resolveReference @, snd xref
          @references[snd ref] = {"ref", (snd xref), "ref"}
        when "call"
          log "assignment/ (call)", inspect xref
          r = {"call", (fst snd xref), "call"}
          for arg in *xref[4,] do table.insert r, arg
          @references[snd ref] = r

-- Check an AST
checkProgram = (ast) ->
  @ = Tundra!
  --
  if ast.type != "body"
    tundraError "Generated AST is not valid. 'body' tag missing."
  --
  for node in *ast do checkNode @, node
  @

{
  :Tundra
  :checkNode, :checkProgram
}