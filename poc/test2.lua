local test = function(x)
return bind(math.sin(x), function(y)
return bind(math.cos(x), function(z)
return then(print(y), print(z))
end)
end)
end