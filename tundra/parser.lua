local P, S, R, C, V, Ct, B
do
  local _obj_0 = require("lpeg")
  P, S, R, C, V, Ct, B = _obj_0.P, _obj_0.S, _obj_0.R, _obj_0.C, _obj_0.V, _obj_0.Ct, _obj_0.B
end
local w = S(" \t\r\n") ^ 0
local wstop = P("\n") ^ 0
local digit = R("09")
local number = C(digit ^ 1)
local letter = R("az") + R("AZ") + P("_")
local word = C(letter ^ 1)
local dot_word = word * P(".")
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
  statement = V("assignment") + V("list"),
  atom = w * dot_word / Node("atom"),
  identifier = w * word / Node("ref"),
  number = w * number / Node("number"),
  real_atom = V("atom") + V("identifier") + V("number"),
  group = w * P("(") * w * V("expression") * w * P(")") * w / Node("group"),
  expression = V("call") + V("group") + V("real_atom"),
  call = V("identifier") * w * ((V("atom") + V("identifier")) + V("expression")) ^ 1 * wstop / Node("call"),
  assignment = V("identifier") * w * P("=") * w * V("expression") / Node("assignment"),
  list = w * P("[") * w * ((V("real_atom")) ^ 1 * (w * P(",") * w * V("real_atom")) ^ 0) * w * P("]") * w / Node("list")
})
local matchString
matchString = function(s)
  return tundra_parser:match(s)
end
return {
  matchString = matchString
}
