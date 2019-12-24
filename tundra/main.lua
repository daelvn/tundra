local inspect
inspect = require("debugkit.inspect").inspect
local matchString
matchString = require("tundra.parser").matchString
return print(inspect(matchString([[
  container. .= 20*
  container. .= *
  container. .= **
  z. container.

]])))
