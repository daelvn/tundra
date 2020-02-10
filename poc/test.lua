require "core"
local square = function(x)
return _42(x)(x)
end
square(10)
local nursulta = function(x)
return (function() if x == Gaulist then
return 10
elseif x == "bruh" then
return 20
end  end)()
end
print(square(nursulta(15)))