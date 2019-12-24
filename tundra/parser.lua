local P, S, R, C, V, Ct, B
do
  local _obj_0 = require("lpeg")
  P, S, R, C, V, Ct, B = _obj_0.P, _obj_0.S, _obj_0.R, _obj_0.C, _obj_0.V, _obj_0.Ct, _obj_0.B
end
local w = S(" \t\r\n") ^ 0
local space = S(" \t") ^ 0
local wstop = P("\n")
local digit = R("09")
local number = C(digit ^ 1)
local letter = R("az") + R("AZ") + P("_")
local word = C(letter ^ 1)
local dot_word = word * P(".")
local comment = P("--") * (1 - S("\r\n")) ^ 0 * wstop
local stop
stop = function(e)
  return e - wstop
end
local Node
Node = function(name)
  return function(...)
    return {
      type = name,
      unpack({
        ...
      })
    }
  end
end
local tundra_parser = P({
  "tundra",
  tundra = w * V("body"),
  body = (V("statement") + V("expression")) ^ 0 / Node("body"),
  statement = V("container") + V("assignment") + V("list"),
  atom = w * dot_word / Node("atom"),
  identifier = w * word / Node("ref"),
  number = w * number / Node("number"),
  named = V("atom") + V("identifier"),
  real_atom = V("named") + V("number"),
  group = w * P("(") * w * V("expression") * w * P(")") * w / Node("group"),
  expression = V("call") + V("group") + V("real_atom"),
  call = V("named") * space * ((V("named") + V("expression")) - wstop) ^ 1 / Node("call"),
  assignment = V("identifier") * w * P("=") * w * V("expression") / Node("assignment"),
  wildcard = (number ^ 0 * P("*")) / Node("wildcard"),
  wildcard_all = P("**") / Node("all_wildcard"),
  container = V("atom") * w * P(".=") * w * (V("wildcard_all") + V("wildcard") + V("list") + V("atom")) / Node("container"),
  list = w * P("[") * w * ((V("real_atom")) ^ 1 * (w * P(",") * w * V("real_atom")) ^ 0) * w * P("]") * w / Node("list")
})
local matchString
matchString = function(s)
  return tundra_parser:match(s)
end
return {
  matchString = matchString
}
