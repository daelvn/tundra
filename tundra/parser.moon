-- tundra.parser
-- Parser for Tundra
-- By Pancakeddd
import P, S, R, C, V, Ct, Cp, B, T from require "lpeg"
import tundraError                 from require "tundra.error"
unpack or= table.unpack

defined_errors =
  dot_error:     "unexpected value after '.='"
  expected_expr: "expected expression"
  expected_dot:  "expected atom but got identifier"


throw = (e) -> error "tundra: #{defined_errors[e]}"

w        = S" \t\r\n" ^ 0
space    = S" \t" ^ 1
wstop    = P"\n"
digit    = R"09"
number   = C digit^1
letter   = R"az"+R"AZ"+P"_"
word     = C letter^1
word_nc  = letter^1
dot_word = word * P"."
string   = C P'"' * ((1 - S'"\r\n\f\\') + (P'\\' * 1)) ^ 0 * '"'
comment  = P"--" * (1 - S"\r\n")^0 * wstop

keywords = {
  'do', 'end'
}

checkKeywords = (n, kw) ->
  x = n
  for word in *kw
    x = x - P word
  x

stop     = (e) -> e - wstop

-- Creates AST instance
Node      = (name) -> (...) -> {type: name, unpack {...}}
NodeWith = (name, args) -> (...) -> {type: name, unpack({...}), args}

tundra_parser = P {
  "tundra"
  tundra:        V"body"

  body:          w * (V"statement" + V"expression")^0 / Node "body"
  do:            w * P"do" * w * (V"statement" + V"expression")^0 * w * P"end" / Node "do"

  statement:     V"container" + V"assignment" + V"list" + V"function" + (V"bind" * (V"statement" + V"expression"))

  atom:          w * dot_word / Node "atom"
  number:        w * number   / Node "atom"
  string:        w * string   / NodeWith "atom", true -- string = true
  identifier:    w * (checkKeywords word, keywords)     / Node "ref"

  named:         V"index_atom" + V"index" + V"atom" + V"identifier"
  real_atom:     V"index_atom" + V"index" + V"named" + V"number" + V"string"
  index:         w * C(word_nc * (P"." * word_nc)^1) / Node "ref"
  index_atom:    w * C(word_nc * (P"." * word_nc)^1) * P"." / Node "atom"

  group:         w * P"(" * w * V"expression" * w * P")" * w / Node "group"
  expression:    V"call" + V"group" + V"real_atom" + V"do"
  
  call:          V"named" * space * ((V"named" + V"expression") - wstop)^1 / Node "call"

  assignment:    V"identifier" * w * P"=" * w * V"expression" / Node "assignment"
  bind:          V"identifier" * w * P"<-" * w * V"expression" / Node "bind"
  function:      (V"identifier" * w)^2 * P"=" * w * (V"statement"+V"expression") / Node "function"
  wildcard_num:  (number^0 * P"*") / Node "wildcard_number"
  wildcard_all:  P"**"             / Node "wildcard_all"
  wildcard:      P"*"              / Node "wildcard"
  container:     V"atom" * w * P".=" * w * (V"wildcard_all" + V"wildcard" + V"wildcard_num" + V"list" + V"atom") / Node "container"
  list:          w * P"[" * w * ((V"real_atom")^1 * (w * P"," * w * V"real_atom")^0) * w * P"]" * w / Node "list"
}

matchString = (s) -> 
  ast, _, _ = tundra_parser\match s
  --unless ast
  --  line, col = re.calcline s, errpos
  --  error_message = defined_errors[e] .. " at (#{line}, #{col})"
  --  error "tundra: #{error_message}"
  tundraError "Could not parse program" unless ast
  ast

{ :matchString }