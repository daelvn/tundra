import inspect     from require "debugkit.inspect"
import matchString from require "tundra.parser"

print inspect matchString([[

  container. .= 20*
  container. .= *
  container. .= **

]])