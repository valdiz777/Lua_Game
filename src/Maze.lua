---------------------------------------------------------------------------------
--
-- Maze.lua
-- Maze object, contains functions to create the maze @Maze:create, prepare it
-- for display or testing @Maze:prepare, and display it on phone @Maze:spawn
---------------------------------------------------------------------------------
require "stack"
local X = display.contentWidth;
local Y = display.contentHeight;
local Xc = display.contentCenterX;
local Yc = display.contentCenterY;

Maze = {

    directions =
    {
      north = { x = 0, y = -1 },
      east = { x = 1, y = 0 },
      south = { x = 0, y = 1 },
      west = { x = -1, y = 0 }
    },

    map = {},
    count = {},

    has_spawned = false,
    tag = "maze",

    rows = 4,
    cols = 4,
    deadend = {},

    sheet_options = {
      frames = {
        {x = 1, y = 1, width = 58, height = 88}, --wall
        {x = 59, y = 2, width = 117, height = 12}, --path
      },
      border = 0,

    },

    sheet_sequence = {
      {name = "passage", frames = {1}},
      {name = "wall", frames = {2}},
    },

    lastKeyPressed = nil,

};

-- Maze Constructor
function Maze:new(maze)

  maze = maze or {};
  setmetatable(maze,self);
  self.__index = self;
  return maze;
end

function Maze:Create(closed)
  -- Actual maze setup
  local width = self.cols;
  local height = self.rows;
  self.map.size = self.rows;
  --print(width, height), enable on tests

  for y = 1, height do
    self.map[y] = {};
    for x = 1, width do
      self.map[y][x] = { east = self:CreateDoor(closed), south = self:CreateDoor(closed)};

      -- Doors are shared  between the cells to avoid out of sync conditions and data duplication
      if x ~= 1 then
        self.map[y][x].west = self.map[y][x - 1].east;
      else
        self.map[y][x].west = self:CreateDoor(closed);
      end

      if y ~= 1 then
        self.map[y][x].north = self.map[y - 1][x].south;
      else
        self.map[y][x].north = self:CreateDoor(closed);
      end
    end
  end

  --[[  Maze generation depends on the random seed, so you will get exactly

      identical maze every time you pass exactly identical seed ]]
  math.randomseed(os.time());
  Maze:Backtracker();
end

function Maze:Prepare(wall, passage)
  wall = wall or "x"
  passage = passage or " "
  local result = ""

  local verticalBorder = ""
  for i = 1, #self.map[1] do
    --check if  wall or passage for our borders
    if (self.map[1][i].north:isClosed()) then
      verticalBorder = verticalBorder .. wall .. wall;
      self.map[1][i].id = "wall";
    else
      verticalBorder = verticalBorder .. wall .. passage;
      self.map[1][i].id = "passage";
    end
  end
  verticalBorder = verticalBorder .. wall;
  result = result .. verticalBorder .. "\n";

  --Check for the rest of the map
  for y, row in ipairs(self.map) do
    local line = row[1].west:isClosed() and wall or passage;
    local underline = wall;
    for x, cell in ipairs(row) do
      if (cell.east:isClosed()) then
        line = line .. " " .. wall;
        self.map[y][x].id = "wall";
      else
        line = line .. " " .. passage;
        self.map[y][x].id = "passage";
      end

      if (cell.south:isClosed()) then
        underline = underline .. wall .. wall;
        self.map[y][x].id = "wall"; 
      else
        underline = underline .. passage .. wall;
        self.map[y][x].id = "passage"; 
      end
    end
    result = result .. line .. "\n" .. underline .. "\n";
  end

  return result
end

function Maze:Spawn(group)
  self.has_spawned = true;

  self.sprite = {sheet = {}};
  self.sprite.sheet = graphics.newImageSheet("images/tree.png", self.sheet_options);
  print("SPAWNING MAZE:");

  self.map.group = display.newGroup();
  self.map.group.anchorY = 0.5;
  self.map.group.anchorX = 0.5;
  self.map.group.anchorChildren = true;

  local size = self.map.size;
  local sr, sc = self.rows, 1;

  for i=1, self.cols do
    if self.map[sr][i].id == "start" then
      sc = i;
      print("start: ("..sr..","..sc..")\n\n");
    end
  end

  local row, col = 0,0;
  local size = self.map.size;
  print(self.map.size)
  for i=1,self.rows do
    for j=1,self.cols do
      self.map[i][j].sprite = display.newSprite(self.sprite.sheet, self.sheet_sequence);
      self.map[i][j].sprite.anchorX = 0.5;
      self.map[i][j].sprite.anchorY = 0.5;
      self.map[i][j].sprite.x = (j-1)*size;
      self.map[i][j].sprite.y = (i-1)*size;
      self.map.group:insert( self.map[i][j].sprite );

      if self.map[i][j].id == "wall" then
        --self.maze[i][j].shape:setFillColor(0.4,0,0.4);
        --[[physics.addBody(self.maze[i][j].shape, "static");]]
        self.map[i][j].sprite:setSequence("wall");
      else
        --self.maze[i][j].shape:setFillColor(1,0.5,0);
        self.map[i][j].sprite:setSequence("path");
      end

    end
  end

  self.map.group.x = Xc - (sc*size) + ((self.cols+1)*size/2);
  self.map.group.y = Yc - (sr*size) + ((self.rows+1)*size/2);

  self.map.loc = {};
  self.map.loc.row = sr;
  self.map.loc.col = sc;

  if group then
    group:insert(self.map.group);
    self.sceneGroup = group;
  end
end

-- This function was designed to be easily replaced by the function generating Legend of Grimrock doors
function Maze:CreateDoor(closed)
  local door = {}
  door._closed = closed and true or false;

  function door:isClosed()
    return self._closed;
  end

  function door:isOpened()
    return not self._closed;
  end

  function door:close()
    self._closed = true;
  end

  function door:open()
    self._closed = false;
  end

  function door:setOpened(opened)
    if opened then
      self:open();
    else
      self:close();
    end
  end
  return door;
end

-- Backtracker algorithm (a variation of the recursive backtracker algorithm made without recursion)
function Maze:Backtracker()
  Maze:ResetDoors(true)

  local stack = Stack:Create()

  local cell = { x = 1, y = 1 }
  while true do
    self.map[cell.y][cell.x].visited = true

    -- Gathering all possible travel direction in a list
    local directions = {}
    for key, value in pairs(self.directions) do
      local newPos = { x = cell.x + value.x, y = cell.y + value.y }
      -- Checking if the targeted cell is in bounds and was not visited previously
      if self.map[newPos.y] and self.map[newPos.y][newPos.x] and not self.map[newPos.y][newPos.x].visited then
        directions[#directions + 1] = { name = key, pos = newPos }
      end
    end

    -- If there are no possible travel directions - backtracking
    if #directions == 0 then
      if #stack > 0 then
        cell = stack:pop()
        --goto countinue only works for 5.2
      else break end -- Stack is empty and there are no possible directions - maze is generated
    else
      -- Choosing a random direction from a list of possible direction and carving
      stack:push(cell)
      local dir = directions[math.random(#directions)]
      self.map[cell.y][cell.x][dir.name]:open()
      cell = dir.pos
    end
    --::countinue:: only works for 5.2
  end

  Maze:ResetVisited()
end

function Maze:ResetDoors(close)
  for y = 1, #self.map do
    self.map[y][#self.map[1]].east:setOpened(not close)

    for i, cell in ipairs(self.map[y]) do
      cell.north:setOpened(not close)
      cell.west:setOpened(not close)
    end
  end

  for i, cell in ipairs(self.map[#self.map]) do
    cell.south:setOpened(not close)
  end
end

function Maze:ResetVisited()
  for y = 1, #self.map do
    for x = 1, #self.map[1] do
      self.map[y][x].visited = nil
    end
  end
end
