import DEBUG       from require "tundra.config"
import inspect     from (require "tundra.debug") DEBUG
import matchString from require "tundra.parser"

print inspect matchString [[

List. .= **
x      = List. a. b. c.

]]