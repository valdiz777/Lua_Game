local path = {
	name = "path",
	xpos = 0,
	ypos = 0,
	width = 100,
	height = 50
};

function path:new(o)
	o = o or {}
	setmetatable(o, self);
 	self.__index = self;
  	return o;
end

function path:printMe(name)
	print(name) -- print the object name
end


function path:spawn()
	local colorcount = 1
	self.shape=display.newRect(self.xPos, self.yPos, self.width, self.height);
	self.shape.pp = self;  -- parent object
	self.shape.name = self.name; -- “path”
	self.shape:setFillColor (1,0,0);
	return self.shape
end
return path
