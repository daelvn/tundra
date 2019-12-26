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

-- compiles the frame for a node
frameForNode = (node) =>
  log "frameForNode", inspect node
  switch node.type
    when "body" then checkProgram node
    when "ref"
      log "ref/", "=> #{fst node}"
      return {node.type, (fst node), "ref"}
    when "list"
      log "list/", "=> #{inspect [v for v in *node]}"
      r = {node.type, (listToString node), "list"}
      for v in *node do table.insert r, frameForNode @, v
      r
    when "atom", "wildcard", "wildcard_number", "wildcard_all"
      log "node/", "=> #{node.type} (#{fst node})"
      @atoms[fst node] = {node.type, (fst node), "atom"} if "atom" == node.type
      return {node.type, (fst node), "atom"}
    when "call"
      log "call/", "=> #{fst node} $ #{inspect node}"
      r = {node.type, (fst node), "call"}
      for v in *node[2,] do table.insert r, v
      log "call/ (callee)", inspect fst node 
      switch (fst node).type
        when "atom" then r[1] = "call_atom"
        when "ref"  then r[1] = "call_ref"
        when "call" then r[1] = "call_call"
      return r
    when "container"
      atom = frameForNode @, fst node
      as   = frameForNode @, snd node
      tundraError "Expected Atom in container definition" if (fst atom) != "atom"
      log "container/", "=> #{snd atom}. = #{inspect as}"
      @atoms[snd atom] = as
      if (fst as) == "list"
        for elem in *as[4,]
          switch fst elem
            when "atom"
              unless @atoms[snd elem] then @atoms[snd elem] = {"constructor", (snd elem), "atom", atom}
            --when "ref"
              --@lookup[snd elem]
      return true
    when "assignment"
      ref  = frameForNode @, fst node
      xref = frameForNode @, snd node
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
          r = {(fst xref), (fst snd xref), "call"}
          for arg in *xref[4,] do table.insert r, arg
          @references[snd ref] = r
      return true

-- returns the frame for an AST
frameFor = (ast) ->
  @ = Tundra!
  --
  if ast.type != "body"
    tundraError "Generated AST is not valid. 'body' tag missing."
  --
  for node in *ast do frameForNode @, node
  @

-- Checks the types of a program
checkProgram = (ast) ->
  @ = frameFor ast
  --
  for name, ref in pairs @references
    switch trd ref
      when "atom"
        tundraError "Atom '#{snd ref}' referenced in '#{name}' does not exist." unless @atoms[snd ref]
      when "ref"
        tundraError "Reference '#{snd ref}' referenced in '#{name}' does not resolve." unless @lookup[snd ref]
      when "call_atom"
        atom = @atoms[snd ref]
        tundraError "Atom '#{snd ref}' called in '#{name}' does not exist" unless atom
        args = for arg in *ref[4,] do arg
        switch fst atom
          when "wildcard"
            tundraError "Atom '#{snd ref}' called with more than one reference" if #args > 1
          when "wildcard_number"
            n = snd atom
            tundraError "Atom '#{snd ref}' called with more than #{n} reference(s)" if #args > n
          when "wildcard_all"
            log "this is fine"
          when "atom", "insitu", "constructor"
            tundraError "Atom '#{snd ref}' cannot be called"
      when "call_ref"
        tundraError "Functions not yet implemented!"
      when "call_call"
        tundraError "Functions not yet implemented!"
{
  :Tundra
  :frameForNode, :frameFor
}