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

-- resolves a reference
resolveReference = (xref) =>
  ref = @references[xref]
  tundraError "Reference '#{xref}' could not be resolved" unless ref
  switch fst ref
    when "ref" then return resolveReference @, @references[snd ref]
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
    when "atom", "wildcard", "wildcard_number", "all_wildcard"
      log "node/", "=> #{node.type} (#{fst node})"
      return {node.type, (fst node), "atom"}
    when "container"
      atom = checkNode @, fst node
      as   = checkNode @, snd node
      tundraError "Expected Atom in container definition" if (fst atom) != "atom"
      log "container/", "=> #{snd atom}. = #{inspect as}"
      @atoms[snd atom] = as
    when "assignment"
      ref  = checkNode @, fst node
      xref = checkNode @, snd node
      tundraError "Expected Ref in assignment LHS" if (fst ref) != "ref"
      log "assignment/", "=> #{snd ref} (#{trd ref}) = #{inspect xref} (#{trd ref})"
      switch trd xref
        when "atom"
          unless @atoms[snd xref]
            @atoms[snd xref]   = {"insitu", (snd xref), "atom"}
          @lookup[snd ref]     = @atoms[snd xref]
          @references[snd ref] = {"atom", @atoms[snd xref], "atom"}
        when "ref"
          @lookup[snd ref]     = resolveReference @, snd xref
          @references[snd ref] = {"ref", @references[snd xref], "ref"}


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