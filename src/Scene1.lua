---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------
local composer = require ("composer")
require "maze"
local scene = composer.newScene("scene1")
-- Load scene with same root filename as this file
---------------------------------------------------------------------------------
local X = display.contentWidth;
local Y = display.contentHeight;
local Xc = display.contentCenterX;
local Yc = display.contentCenterY;
local maze;

--[[-------------------------------------]]
--  FUNCTIONS
--[[-------------------------------------]]



--[[--------------------------------------------]]
--  CREATE  |   SHOW    |   HIDE  | DESTROY
--[[--------------------------------------------]]

-- initializes all core components
function scene:Create( event )
  local sceneGroup = self.view;
  maze = Maze:new({rows = 12, cols = 12});
  maze:Create(true);
  maze:Prepare();

  --Load the background
  bg = {};
  bg.drop = display.newRect(Xc,Yc,X,Y);
  bg.drop:setFillColor(0.3,0.3,0.4,0.5);
  bg.drop:toBack();

  sceneGroup:insert(bg.drop);
end

--Starts running everything
function scene:Show( event )
  local sceneGroup = self.view;
  local phase = event.phase;

  if event.phase == "will" then

   maze:Spawn(sceneGroup); --not yet currently working on it
    --not yet player:spawn(scene_group);

    Runtime:addEventListener("key",maze);
    Runtime:addEventListener("tap",maze);
  --not yet Runtime:addEventListener("key",player);

  elseif event.phase == "did" then
  end
end

--turns off timer for button
function scene:Hide(event)

  local sceneGroup = self.view;

  if event.phase == "will" then
  elseif event.phase == "did" then

  end

end

--[[-------------------------------------]]
--  MAIN
--[[-------------------------------------]]


function scene:Destroy( event )
  local sceneGroup = self.view

  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "Create", scene )
scene:addEventListener( "Show", scene )
scene:addEventListener( "Hide", scene )
scene:addEventListener( "Destroy", scene )

---------------------------------------------------------------------------------

return scene
