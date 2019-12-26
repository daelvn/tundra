local human = function(...)
return setmetatable({...}, {__type = "human"})
end