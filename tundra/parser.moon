import P, S, R, C, V, Ct, B from require 'lpeg'

w = S' \t\r\n' ^ 0
wstop = P'\n'^0
digit = R"09"
number = C digit^1
letter = R"az"+R"AZ"+P"_"
word = C letter^1
dot_word = word * P"."

node = (name) -> -- Creates AST instance
  return (...) -> {type: name, unpack {...}}

tundra_parser = P {
  "tundra"
  tundra: w * V"body"

  body: (V"statement" + V"expression")^0 / node "body"

  statement: V"assignment" + V"native_list"

  atom: w * dot_word / node "atom"
  identifier: w * word / node "ref"
  number: w * number / node "number"

  real_atom:  V"atom" + V"identifier" + V"number"

  group: w * P"(" * w * V"expression" * w * P")" * w / node "group"
  expression: V"function_call" + V"group" + V"real_atom"
  
  function_call: V"identifier" * w * (V"identifier" + V"expression")^1 * wstop / node "call"

  assignment: V"identifier" * w * P"=" * w * V"expression" / node "assignment"
  native_list: w * P'[' * w * ((V"real_atom")^1 * (w * P"," * w * V"real_atom")^0) * w * P']' * w / node "list"
}

match_string = (s) -> tundra_parser\match s

{:match_string}