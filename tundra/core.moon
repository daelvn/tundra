files_to_load = {
  "tundra/libs/core.lua"
}

files_to_load_name = {
  "core.lua"
}

lfs = require "filekit"

clip_name = (x) -> x\gsub "[%\%/][a-zA-Z_0-9]+%.[a-z]+", ""

generate_needed_files = (x) ->
  -- load files
  s = for file in *files_to_load
    f = assert io.open file, "r"
    c = f\read "*all"
    f\close!
    c
  
  for i=1, #s
    with io.open clip_name(x) .. "/" .. files_to_load_name[i], "w"
      \write s[i]
      \close!


{:generate_needed_files}