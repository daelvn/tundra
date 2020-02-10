-- tundra.parser
-- Parser for Tundra
-- By Pancakeddd
import P, S, R, C, V, Ct, Cmt, Cp, B, T from require "lpeg"
import tundraError                 from require "tundra.error"
unpack or= table.unpack

defined_errors =
  dot_error:          "unexpected value after '.='"
  expected_expr:      "expected expression"
  expected_dot:       "expected atom but got identifier"
  expected_end:       "expected end to terminate block"
  expected_end_paren: "expected ')' to end paren group"


throw = (e) -> error "tundra: #{defined_errors[e]}"

w        = S" \t\r\n" ^ 0
space    = S" \t" ^ 1
wstop    = P"\n" * w
digit    = R"09"
number   = C digit^1
letter   = R"az"+R"AZ"+P"_"
word     = C letter^1
word_nc  = letter^1
dot_word = word * P"."
string   = C P'"' * ((1 - S'"\r\n\f\\') + (P'\\' * 1)) ^ 0 * '"'
comment  = P"--" * (1 - S"\r\n")^0 * wstop
anything = C ((P(1) - S" \t\r\n") - P":")^1

keywords = {
  "do", "if", "end", "then", "with", "and"
}

checkKeywords = (n, kw) ->
  x = n
  for word in *kw
    x = x - P word
  x

-- Creates AST instance
Node      = (name) -> (...) -> {type: name, unpack {...}}
NodeWith = (name, args) -> (...) -> {type: name, unpack({...}), args}

throw = (err) ->
  Cmt "", ->
    error defined_errors[err]

throw_s = (s) ->
  Cmt "", ->
    error s

need = (s, p) ->
  (throw(s) - p) + p

no_stop = (p) ->
  (p - wstop)

check_simple = (s) ->
  P(s) + throw_s "expected '#{s}'"

tundra_parser = P {
  "tundra"
  tundra:        V"body"

  end:           need("expected_end", P"end")

  body:          w * (V"statement" + V"expression")^0 / Node "body"
  do:            w * P"do" * w * (V"statement" + V"expression")^0 * w * V"end" / Node "do"
  lambda:        (w * P[[\]] * V"named" * w * P"->" * w * (V"statement" + V"expression") / Node "lambda") +
                 (P"->" * w * (V"statement" + V"expression") / Node "lambda_simple")

  statement:     V"container" + V"function" + V"function_simple" + V"assignment" + V"if" + V"case" + (V"bind" * (V"statement" + V"expression"))

  number:        w * number   / Node "atom"
  string:        w * string   / NodeWith "atom", true -- string = true
  identifier:    w * (checkKeywords word, keywords)     / Node "ref"

  named:          V"index" + V"identifier"
  real_atom:     V"named" + V"number" + V"string"
  index:         w * C(word_nc * (P"/" * word_nc)^1) / Node "ref"
  anything:      w * anything / Node "anything_ref"

  group:         w * P"(" * w * V"expression_wo" * w * need("expected_end_paren", P")") / Node "group"
  expression:    V"call" + V"group" + V"real_atom" + V"do" + V"lambda"
  expression_wo: V"call_no_check" + V"group" + V"real_atom" + V"do" + V"lambda"
  
  call_no_check: w * V"anything" * ((C(P":"))^-1) * space * (V"named" + V"expression")^1 / Node "call"
  call:          w * V"named" * ((C(P":"))^-1) * space * ((V"named" + V"expression") - wstop)^1 / Node "call"


  with_and:      w * V"identifier" * w * P"and" * w * V"with_body" / Node "and"
  with_body:     V"with_and" + V"named"
  with:          P"with" * w * V"with_body"^1
  type_definition: w * P"|" * w * V"identifier" * w * V("with")^-1 / Node "type_def"

  container:     V"named" * w * P".=" * w * need("dot_error", V"type_definition"^1) / Node "container"

  if:            w * P"if" * w * V"expression" * w * V"body" * w * V"end" / Node "if"
  case_body:     w * P"|" * w * ((P"_" / Node "else") + V"expression") * w * P"then" * w * V"expression" / Node "match"
  case:          w * P"case" * w * V"expression" * w * (V"case_body"^0) * w * V"end" / Node "case"
  assignment:    w * V"named" * w * P"=" * w * V"expression" / Node "assignment"
  bind:          w * V"identifier" * w * P"<-" * w * V"expression" / Node "bind"
  function:      w * V"anything" * space * (V"real_atom" - wstop)^1 * w * P"=" * w * (V"statement"+V"expression") / Node "function"
  function_simple:  V"named" * w * P"=" * w * V"do" / Node "function"
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