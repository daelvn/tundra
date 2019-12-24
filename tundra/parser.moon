import P, S, R, C, V, Ct, B from require "lpeg"

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
  number:        w * number   / Node "number"

  named:         V"atom" + V"identifier"
  real_atom:     V"named" + V"number"

  group:         w * P"(" * w * V"expression" * w * P")" * w / Node "group"
  expression:    V"call" + V"group" + V"real_atom"
  
  call:          V"named" * space * ((V"named" + V"expression") - wstop)^1 / Node "call"

  assignment:    V"identifier" * w * P"=" * w * V"expression" / Node "assignment"
  wildcard:      (number^0 * P"*") / Node "wildcard"
  container:     V"atom" * w * P".=" * w * (V"wildcard" + V"list" + V"atom") / Node "container"
  list:          w * P"[" * w * ((V"real_atom")^1 * (w * P"," * w * V"real_atom")^0) * w * P"]" * w / Node "list"
}

matchString = (s) -> tundra_parser\match s

{ :matchString }