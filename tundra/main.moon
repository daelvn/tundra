import inspect      from require "debugkit.inspect"
import matchString from require "tundra.parser"

print inspect matchString([[

  atom.
  [a., b.]
  a = b.
  a

  a b. c.
  a (b. c.)

]])