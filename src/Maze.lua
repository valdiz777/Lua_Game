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
  wall = wall or "#"
  passage = passage or " "
  local result = ""

  local verticalBorder = ""
  for i = 1, #self.map[1] do
    --check if  wall or passage for our borders
    local truthVal = (self.map[1][i].north:isClosed()) and wall or passage;
    if (truthVal == wall) then
      verticalBorder = verticalBorder .. wall .. wall;
      self.map[1][i].id = "wall";
    end
    if (truthVal == passage) then
      verticalBorder = verticalBorder .. wall .. passage;
      self.map[1][i].id = "passage";
    end
  end

  verticalBorder = verticalBorder .. wall
  result = result .. verticalBorder .. "\n"

  for y, row in ipairs(self.map) do
    local line = row[1].west:isClosed() and wall or passage;
    local underline = wall;
    local truthVal = line;
    local truthVal2 = underline;
    for x, cell in ipairs(row) do
      truthVal = (cell.east:isClosed())  and wall or passage;
      if (truthVal == wall) then
        line = line .. " " .. wall;
      --self.map_id[1][i] = "wall"; Still working on this
      end
      if (truthVal == passage) then
        line = line .. " " .. passage;
      --self.map_id[1][i] = "passage"; Still working on this
      end

      truthVal = (cell.south:isClosed())  and wall or passage;
      if (truthVal == wall) then
        underline = line .. " " .. wall;
      end

      if (truthVal == passage) then
        underline = line .. " " .. passage;
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

  self.maze.group = display.newGroup();
  self.maze.group.anchorY = 0.5;
  self.maze.group.anchorX = 0.5;
  self.maze.group.anchorChildren = true;

  local size = self.maze.size;
  local sr, sc = self.maze.row.count, 1;

  for i=1, Maze.maze.col.count do
    if Maze.maze[sr][i].id == "start" then
      sc = i;
      print("start: ("..sr..","..sc..")\n\n");
    end
  end

  local row, col = 0,0;
  for i=1,self.maze.row.count do
    for j=1,self.maze.col.count do
      self.maze[i][j].sprite = display.newSprite(self.sprite.sheet, self.sheet_sequence);
      self.maze[i][j].sprite.anchorX = 0.5;
      self.maze[i][j].sprite.anchorY = 0.5;
      self.maze[i][j].sprite.x = (j-1)*size;
      self.maze[i][j].sprite.y = (i-1)*size;
      self.maze.group:insert( self.maze[i][j].sprite );

      if Maze.maze[i][j].id == "wall" then
        --self.maze[i][j].shape:setFillColor(0.4,0,0.4);
        --[[physics.addBody(self.maze[i][j].shape, "static");]]
        Maze.maze[i][j].sprite:setSequence("wall");
      else
        --self.maze[i][j].shape:setFillColor(1,0.5,0);
        Maze.maze[i][j].sprite:setSequence("path");
      end

    end
  end

  self.map.group.x = Xc - (sc*size) + ((self.map.col.count+1)*size/2);
  self.map.group.y = Yc - (sr*size) + ((self.map.row.count+1)*size/2);

  self.map.loc = {};
  self.map.loc.row = sr;
  self.map.loc.col = sc;

  if group then
    group:insert(Maze.map.group);
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
