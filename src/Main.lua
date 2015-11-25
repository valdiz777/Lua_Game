---------------------------------------------------------------------------------
--
-- Main.lua
--
---------------------------------------------------------------------------------
--Enable Tests here
local Maze_TEST = true

if Maze_TEST then --Maze test enabled, still on the works
  require "maze"
  local maze;
  maze = Maze:new({rows = 12, cols = 12});
  maze:Create(true);
  print("......Loading Maze Test .....")
  print(Maze:Prepare())

else --No Tests selected, load usual module

  -- hide the status bar
  --display.setStatusBar( display.HiddenStatusBar )

  -- require the composer library
  local composer = require "composer"
  local options =
    {
      effect ="fade",
      time = 400,
    }
  -- load scene1
  composer.gotoScene( "Scene1" )
  local currScene = composer.getSceneName( "current" )
  composer.gotoScene(currScene)

  -- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)
end
