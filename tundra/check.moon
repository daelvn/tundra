-- tundra.check
-- Type checking for Tundra
-- By daelvn
import DEBUG        from  require "tundra.config"
import inspect, log from (require "tundra.debug" ) DEBUG

-- Utils
fst = (t) -> t[1]
snd = (t) -> t[2]
trd = (t) -> t[3]

-- Create a new instance of the language frame
Tundra = ->
  setmetatable {
    atoms:      {}
    references: {}
    lookup:     {} -- type lookup
  }, {}

local checkProgram

-- resolves a reference
resovleReference = (ref) =>
  switch fst ref
    when "ref" then return resovleReference @, @references[snd ref]
    else
      if (trd ref) == "atom" then return @atoms[snd ref]
  error "resolveReference $ reference #{inspect ref} could not be resolved"

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
      error "checkNode $ expected Atom in container definition" if (fst atom) != "atom"
      log "container/", "=> #{snd atom}. = #{inspect as}"
      @atoms[snd atom] = as
    when "assignment"
      ref  = checkNode @, fst node
      xref = checkNode @, snd node
      error "checkNode @ expected ref in assignment LHS" if (fst ref) != "ref"
      log "assignment/", "=> #{snd ref} (#{trd ref}) = #{inspect xref} (#{trd ref})"
      switch trd xref
        when "atom"
          unless @atoms[snd xref]
            @atoms[snd xref]   = {"insitu"}
          @lookup[snd ref]     = @atoms[snd xref]
          @references[snd ref] = @atoms[snd xref]
        when "ref"
          @lookup[snd ref]    = resovleReference @, @references[snd xref]
          @referenes[snd ref] = @references[snd xref]


-- Check an AST
checkProgram = (ast) ->
  @ = Tundra!
  --
  if ast.type != "body"
    error "checkProgram $ AST given is not valid. 'body' tag missing."
  --
  for node in *ast do checkNode @, node
  @

{
  :Tundra
  :checkNode, :checkProgram
}