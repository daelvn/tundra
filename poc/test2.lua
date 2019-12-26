local test = function(x)
return bind(math.sin(x), function(y)
return print(y)
end)
end