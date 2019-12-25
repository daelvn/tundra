(DEBUG) ->
  import inspect from require "debugkit.inspect"
  import logger  from require "debugkit.log"
  import style   from require "ansikit.style"

  tundraLgr        = logger.default!
  tundraLgr.name   = "tundra"
  tundraLgr.header = (T) => style "%{bold green}#{@name} %{blue}- %{white}#{T} %{yellow}$ "
  tundraLgr.time   =     => ""
  log              = tundraLgr!

  { :inspect, :log }