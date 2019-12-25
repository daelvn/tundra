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
space    = S" \t" ^ 0
wstop    = P"\n"
digit    = R"09"
number   = C digit^1
letter   = R"az"+R"AZ"+P"_"
word     = C letter^1
dot_word = word * P"."
comment  = P"--" * (1 - S"\r\n")^0 * wstop

stop     = (e) -> e - wstop

-- Creates AST instance
Node = (name) -> (...) -> {type: name, unpack {...}}

tundra_parser = P {
  "tundra"
  tundra:        w * V"body"

  body:          (V"statement" + V"expression")^0 / Node "body"

  statement:     V"container" + V"assignment" + V"list"

  atom:          w * dot_word / Node "atom"
  identifier:    w * word     / Node "ref"
  number:        w * number   / Node "atom"

  named:         V"atom" + V"identifier"
  real_atom:     V"named" + V"number"

  group:         w * P"(" * w * V"expression" * w * P")" * w / Node "group"
  expression:    V"call" + V"group" + V"real_atom"
  
  call:          V"named" * space * ((V"named" + V"expression") - wstop)^1 / Node "call"

  assignment:    V"identifier" * w * P"=" * w * (V"expression") / Node "assignment"
  wildcard_num:  (number^0 * P"*") / Node "wildcard_number"
  wildcard_all:  P"**"             / Node "all_wildcard"
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