require "core"
local x = function(string)
return setmetatable({string}, {__type = "x"})
end
local y = function(_string1, _string2)
return setmetatable({_string1, _string2}, {__type = "y"})
end