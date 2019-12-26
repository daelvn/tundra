local generate_lpeg = function(x)
return bind(require("lpeg"), function(lpeg)
return lpeg.P(z)
end)
end