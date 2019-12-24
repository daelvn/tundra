local inspect
inspect = require("debugkit.inspect").inspect
local matchString
matchString = require("tundra.parser").matchString
return print(inspect(matchString([[
  atom.
  [a., b.]
  a = b.
  a

  a b. c.
  a (b. c.)

]])))
