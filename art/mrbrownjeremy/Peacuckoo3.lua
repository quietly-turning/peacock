local musicrate = GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
local bpm = 140

local af = Def.ActorFrame{}

af[#af+1] = LoadActor("Peacuckoo3.mov")..{
  InitCommand=function(self)
    self:SetTextureFiltering(false)
    local src_w = self:GetTexture():GetSourceWidth()
    self:Center():zoom(_screen.w/WideScale(src_w*0.75,src_w))
    self:animate(false):loop(true):rate(musicrate)
  end,
  ShowCommand=function(self)
    self:animate(true)
  end
}

-- ------------------------------------------------------

local start_coords, dest_coords, travel_times = {}, {}, {}

local num_peacuckoos = 32
local pps       = 600    -- pixels-per-second we want peacuckoos traveling across the screen
local offset    = 20     -- how many pixels offscreen does a peacuckoo need to not-be-seen?
local variation = 300    -- how many pixels-away-from-center do we want peacuckoos starting-from and going-towards?

local function SomewhereOffScreenLeft()
  return { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) }
end

local function SomewhereOffScreenTop()
  return { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset }
end

local function SomewhereOffScreenRight()
  return { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) }
end

local function SomewhereOffScreenBottom()
  return { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset }
end

local function GetStartCoords(i)
  if (i%4==1) then return SomewhereOffScreenLeft()   end
  if (i%4==2) then return SomewhereOffScreenTop()    end
  if (i%4==3) then return SomewhereOffScreenRight()  end
  if (i%4==0) then return SomewhereOffScreenBottom() end
end

local function GetDestCoords(i)
  if (i%4==1) then return SomewhereOffScreenRight()  end
  if (i%4==2) then return SomewhereOffScreenBottom() end
  if (i%4==3) then return SomewhereOffScreenLeft()   end
  if (i%4==0) then return SomewhereOffScreenTop()    end
end

local function GetHypotenuseLength(i)
  local a = math.abs(start_coords[i].y - dest_coords[i].y)
  local b = math.abs(start_coords[i].x - dest_coords[i].x)
  return math.sqrt(math.pow(a,2) + math.pow(b,2))
end

-- add peacuckoos that tween across the screen in the following order
-- left→right, top→bottom, right→left, bottom→top, left→right, top→bottom, etc...
for i=1,num_peacuckoos do
  start_coords[i] = GetStartCoords(i)
  dest_coords[i]  = GetDestCoords(i)
  travel_times[i] = GetHypotenuseLength(i) / pps   -- divide hypotenuse length by pps to get tween time

  af[#af+1] = LoadActor("./Peacuckoo 3x1.png")..{
    Name=("Peacuckoo%d"):format(i),
    InitCommand=function(self)
      self:SetTextureFiltering(false):zoom(4.75)
      self:SetAllStateDelays((60/bpm)*0.5)
      self:xy( start_coords[i].x, start_coords[i].y )

      -- which cycle of the for-loop are we in?
      local r = i % 4

      -- peacuckoo sprite asset is natively facing left
      -- we may need to rotatey(180) so it's facing right
      -- peacuckoos traveling from screen-left → screen-right should face right
      -- peacuckoos traveling vertically should face right if their destination-x is greater than their start-x
      if (r == 1)
      or ((r==2 or r==0) and (dest_coords[i].x > start_coords[i].x)) then
        self:rotationy( 180 )
      end
    end,
    ShowCommand=function(self)
      self:hibernate(((60/bpm) * 0.333)*i)           -- wait this peacuckoo for a little while so they don't all appear on-screen simultaneously
      self:linear( travel_times[i] )                 -- apply a time tween appropriate for the hypotenuse length
      self:xy( dest_coords[i].x, dest_coords[i].y )  -- tween the peacuckoo to their destination xy coordinates
      self:queuecommand("Done")                      -- once they're off-screen, queue a command to cut them out of the render
    end,
    DoneCommand=function(self)
      self:hibernate(math.huge)
    end
  }
end

-- ------------------------------------------------------

return af