argparse = require "argparse"

import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
--import checkProgram        from  require "tundra.check"
import compile             from  require "tundra.compiler"

argparser = with argparse 'Tundra', 'Tundra Compiler'
  \argument "input", 'Tundra files'

args = argparser\parse!

compile args.input