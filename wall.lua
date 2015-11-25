local wall = {
	name = "wall",
	xpos = 0,
	ypos = 0,
	width = 100,
	height = 50
};

function wall:new(o)
	o = o or {}
	setmetatable(o, self);
 	self.__index = self;
  	return o;
end

function wall:printMe(name)
	print(name) -- print the object name
end


function wall:spawn()
	self.shape=display.newRect(self.xPos, self.yPos, self.width, self.height);
	self.shape.pp = self;  -- parent object
	self.shape.name = self.name; -- “wall”
	self.shape:setFillColor (0.3,0.3,0.3);
	return self.shape
end
return wall
