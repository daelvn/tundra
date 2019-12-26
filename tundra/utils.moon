fst   = (t) -> t[1]
snd   = (t) -> t[2]
trd   = (t) -> t[3]
nam   = (t) -> t.type
last  = (t) -> t[#t]
quote = (s) ->
  if s\sub(1, 1) != '"' and s\sub(-1, -1) != '"'
    "\"#{s}\""
  else
    s

buildNode = (t, a) ->
  a.type = t
  a

deep_copy = (t) ->
  y = type t
  copy = nil
  if y == "table"
    copy = {}
    for k, v in next, t, nil
      copy[deep_copy(k)] = deep_copy v
    setmetatable(copy, deep_copy(getmetatable t))
  else
    copy = t
  copy 

{:fst, :snd, :trd, :nam, :last, :quote, :buildNode, :deep_copy}