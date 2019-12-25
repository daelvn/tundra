local P, S, R, C, V, Ct, Cp, B, T
do
  local _obj_0 = require("lpeglabel")
  P, S, R, C, V, Ct, Cp, B, T = _obj_0.P, _obj_0.S, _obj_0.R, _obj_0.C, _obj_0.V, _obj_0.Ct, _obj_0.Cp, _obj_0.B, _obj_0.T
end
local re = require('relabel')
local defined_errors = {
  dot_error = "unexpected value after '.='",
  expected_expr = "expected expression",
  expected_dot = "expected atom but got identifier"
}
local throw
throw = function(e)
  return error("tundra: " .. tostring(defined_errors[e]))
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
  number = w * number / Node("atom"),
  named = V("atom") + V("identifier"),
  real_atom = V("named") + V("number"),
  group = w * P("(") * w * V("expression") * w * P(")") * w / Node("group"),
  expression = V("call") + V("group") + V("real_atom"),
  call = V("named") * space * ((V("named") + V("expression")) - wstop) ^ 1 / Node("call"),
  assignment = V("identifier") * w * P("=") * w * (V("expression") + throw("expected_expr")) / Node("assignment"),
  wildcard_num = (number ^ 0 * P("*")) / Node("wildcard_number"),
  wildcard_all = P("**") / Node("all_wildcard"),
  wildcard = P("*") / Node("wildcard"),
  container = (V("atom") * w * P(".=") + V("identifier") * w * P(".=") * throw("expected_dot")) * w * (V("wildcard_all") + V("wildcard") + V("wildcard_num") + V("list") + V("atom")) / Node("container"),
  list = w * P("[") * w * ((V("real_atom")) ^ 1 * (w * P(",") * w * V("real_atom")) ^ 0) * w * P("]") * w / Node("list")
})
local matchString
matchString = function(s)
  local ast, e, errpos = tundra_parser:match(s)
  if not (ast) then
    local line, col = re.calcline(s, errpos)
    local error_message = defined_errors[e] .. " at (" .. tostring(line) .. ", " .. tostring(col) .. ")"
    error("tundra: " .. tostring(error_message))
  end
  return ast
end
return {
  matchString = matchString
}
