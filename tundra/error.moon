-- tundra.error
-- Error reporting for Tundra
-- By daelvn
import style from require "ansikit.style"

tundraError = (msg, code=1) ->
  print style "%{bold red}Tundra $%{reset red} #{msg}"
  error!

{:tundraError}