---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------
local composer = require ("composer")
require "maze"
require "backtracker"
local scene = composer.newScene("scene1")
-- Load scene with same root filename as this file
---------------------------------------------------------------------------------
local nextSceneButton
local labyrinth = {0,0,0,0}

function scene:create( event )
    local sceneGroup = self.view
    maze = Maze:Create(30, 10, true)
	math.randomseed(os.time())
	Maze:Backtracker(maze)
	print(maze:tostring())
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if event.phase == "will" then
        
        --maze:spawn(scene_group);
        --maze:printGrid();
        
        -- Called when the scene is still off screen and is about to move on screen
        local title = self:getObjectByName( "New Game" )
        title.x = display.contentWidth / 2
        title.y = display.contentHeight / 2
        title.size = display.contentWidth / 10
        local goToScene2Btn = self:getObjectByName( "GoToScene2Btn" )
        goToScene2Btn.x = display.contentWidth - 95
        goToScene2Btn.y = display.contentHeight - 35
        local goToScene2Text = self:getObjectByName( "GoToScene2Text" )
        goToScene2Text.x = display.contentWidth - 92
        goToScene2Text.y = display.contentHeight - 35
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy
        nextSceneButton = self:getObjectByName( "GoToScene2Btn" )
        if nextSceneButton then
        	-- touch listener for the button
        	function nextSceneButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "scene2", { effect = "fade", time = 300 } )
        		end
        	end
        	-- add the touch event listener to the button
        	nextSceneButton:addEventListener( "touch", nextSceneButton )
        end
        
    end 
end

local function spawnsmile()
    local smile = display.newImageRect("Button.png", 45, 45);
    smile:setReferencePoint(display.CenterReferencePoint);
    smile.x = math.random(-10, 400);
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
        -- Called when the scene is now off screen
		if nextSceneButton then
			nextSceneButton:removeEventListener( "touch", nextSceneButton )
		end
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
