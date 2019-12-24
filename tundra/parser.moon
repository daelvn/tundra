import P, S, R, C, V, Ct, B from require "lpeg"

w        = S" \t\r\n" ^ 0
wstop    = P"\n"^0
digit    = R"09"
number   = C digit^1
letter   = R"az"+R"AZ"+P"_"
word     = C letter^1
dot_word = word * P"."

-- Creates AST instance
Node = (name) -> (...) -> {type: name, unpack {...}}

tundra_parser = P {
  "tundra"
  tundra:        w * V"body"

  body:          (V"statement" + V"expression")^0 / Node "body"

  statement:     V"assignment" + V"list"

  atom:          w * dot_word / Node "atom"
  identifier:    w * word     / Node "ref"
  number:        w * number   / Node "number"

  real_atom:     V"atom" + V"identifier" + V"number"

  group:         w * P"(" * w * V"expression" * w * P")" * w / Node "group"
  expression:    V"call" + V"group" + V"real_atom"
  
  call:          V"identifier" * w * ((V"atom" + V"identifier") + V"expression")^1 * wstop / Node "call"

  assignment:    V"identifier" * w * P"=" * w * V"expression" / Node "assignment"
  list:          w * P"[" * w * ((V"real_atom")^1 * (w * P"," * w * V"real_atom")^0) * w * P"]" * w / Node "list"
}

matchString = (s) -> tundra_parser\match s

{ :matchString }