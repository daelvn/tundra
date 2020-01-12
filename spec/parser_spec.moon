import DEBUG               from  require "tundra.config"
import inspect, log        from (require "tundra.debug") DEBUG
import matchString         from  require "tundra.parser"
import apply, transformers from  require "tundra.transform"
--import checkProgram        from  require "tundra.check"
import compile_s   from  require "tundra.compiler"

describe "Testing the Parser", ->
  describe "function calls", ->
    it "simple call", ->
      assert.truthy compile_s([[
        x 1
        x 1 2 3
        x (z 1)
      ]]) == "x(1)\nx(1, 2, 3)\nx(z(1))"

    it "index call", ->
      assert.truthy compile_s([[
        x/y z
        x/y 10 20 30
        io/write "hello"
      ]]) == 'x.y(z)\nx.y(10, 20, 30)\nio.write("hello")'

    it "constructor call", ->
      print compile_s([[
        c. .= [x, y]

        z = c. 10, 20
      ]])
      assert.truthy compile_s([[
        c. .= [x, y]

        z = c. 10, 20
      ]]) == 'x.y(z)\nx.y(10, 20, 30)\nio.write("hello")'