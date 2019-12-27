local argparse = require("argparse")
local DEBUG
DEBUG = require("tundra.config").DEBUG
local inspect, log
do
  local _obj_0 = (require("tundra.debug"))(DEBUG)
  inspect, log = _obj_0.inspect, _obj_0.log
end
local matchString
matchString = require("tundra.parser").matchString
local apply, transformers
do
  local _obj_0 = require("tundra.transform")
  apply, transformers = _obj_0.apply, _obj_0.transformers
end
local compile
compile = require("tundra.compiler").compile
local argparser
do
  local _with_0 = argparse('Tundra', 'Tundra Compiler')
  _with_0:argument("input", 'Tundra files')
  argparser = _with_0
end
local args = argparser:parse()
return compile(args.input)
