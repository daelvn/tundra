import DEBUG       from require "tundra.config"
import inspect     from (require "tundra.debug") DEBUG
import matchString from require "tundra.parser"

print inspect matchString [[

ctr. .= number.
x = ctr. 10

]]