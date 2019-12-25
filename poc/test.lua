local bowl = function(...)
return {1 = ..., type = "bowl"}
end
local grape_bowl = bowl({type = "grape"}, {type = "grape"}, {type = "grape"})