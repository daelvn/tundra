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

{:fst, :snd, :trd, :nam, :last, :quote}