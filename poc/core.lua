unpack = unpack or table.unpack

bind = function(x)
  return function (y)
    return y(x)
  end
end

next = function(_)
  return function (y)
    return y
  end
end

eq = function (x)
  return function (y)
    return x == y
  end
end

add = function (x)
  return function (y)
    return x + y
  end
end

sub = function (x)
  return function (y)
    return x - y
  end
end

mul = function (x)
  return function (y)
    return x * y
  end
end

div = function (x)
  return function (y)
    return x / y
  end
end

_if = function(e)
  return function (t)
    return function (f)
      if e then
        return t()
      end
      return f()
    end
  end
end

_then = function(e)
  return function (t)
    if e then
      return t()
    end
  end
end

-- Lists

list = function (...)
  return {unpack({...})}
end

idx = function (t)
  return function (i)
    return t[i]
  end
end

fst = function (t)
  return t[1]
end

snd = function (t)
  return t[2]
end

trd = function (t)
  return t[3]
end

map = function (t)
  return function (f)
    local c = {}
    for i = 1, #t do
      c[#c+1] = f(t[i])
    end
    return c
  end
end

-- IO

openfile = function (t)
  return function (r)
    if r == "r" or r == "rb" then
      local f = assert(io.open(t, r))
      local s = f:read("*a")
      f:close()
      return s
    else
      error ("Unexpected reading type '" .. r .. "'")
    end
  end
end