-- tundra.error
-- Error reporting for Tundra
-- By daelvn
import style             from require "ansikit.style"
import rewrite_traceback from require "moonscript.errors"

tundraTraceback = ->
  text  = rewrite_traceback debug.traceback!, ""
  lines = [line for line in text\gmatch "[^\n]+"]
  final = {}
  for i, line in ipairs lines
    if i <= 2
      table.insert final, style.red "Stack traceback:" if i == 1
      continue
    if line\match"/bin/moon" or line\match"%[C%]"
      continue
    if line\match"tundraTraceback" or line\match"tundraError"
      continue
    line = "     - " .. line
    line = line\gsub "%b''",    style.green  "%1"
    line = line\gsub "%b<>",    style.cyan   "%1"
    line = line\gsub "%(%.%.%..+%.%.%.%)",    style.yellow "%1"
    line = line\gsub "(.+) in (%w+)", style "%{bold magenta}%1%{reset} in %{blue}%2"
    table.insert final, line
  table.concat final, "\n"

tundraError = (msg, code=1) ->
  print style "%{bold red}Tundra $%{reset red} #{msg}"
  print style "%{     red}        %{         } #{tundraTraceback!}"
  error!

{:tundraError}