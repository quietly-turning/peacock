local musicrate = GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
local bpm = 140

local function Update(af, dt)

end

local af = Def.ActorFrame{}
af.InitCommand=function(self) self:visible(false):SetUpdateFunction(Update) end
af.ShowCommand=function(self) self:visible(true)  end

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

local offset = 20
local variation = 300

local start_coords = {
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
}

local dest_coords = {
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
  { x=_screen.w + offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=_screen.h + offset },
  { x=-offset, y=_screen.cy + MersenneTwister.Random(-variation, variation) },
  { x=_screen.cx + MersenneTwister.Random(-variation, variation), y=-offset },
}


-- consider switching to update function + lerp() ?

local pps = 600 -- pixels-per-second
local travel_times = {}

for i=1,#start_coords do
  travel_times[i] = (math.sqrt(math.pow(math.abs(start_coords[i].y-dest_coords[i].y), 2) + math.pow(math.abs(start_coords[i].x-dest_coords[i].x), 2)) / pps)

  af[#af+1] = LoadActor("./Peacuckoo 3x1.png")..{
    Name=("Peacuckoo%d"):format(i),
    InitCommand=function(self)
      self:SetTextureFiltering(false):zoom(4.75)
      self:SetAllStateDelays((60/bpm)*0.5)
      self:xy( start_coords[i].x, start_coords[i].y )

      local r = i % 4
      -- peacuckoo sprite asset is natively facing left
      -- we may need to rotatey(180) so it's facing right
      if (r == 1) then
        -- peacuckoos traveling from screen-left → screen-right should face right
        self:rotationy( 180 )

      elseif (r==2 or r==0) then
        -- peacuckoos traveling vertically should face right if their destination-x is greater than their start-x
        if (dest_coords[i].x > start_coords[i].x) then
          self:rotationy(180)
        end
      end
    end,
    ShowCommand=function(self)
      self:hibernate(((60/bpm)*0.5)*i)
      self:linear(travel_times[i])
      self:xy( dest_coords[i].x, dest_coords[i].y )
      self:queuecommand("Done")
    end,
    DoneCommand=function(self)
      self:hibernate(math.huge)
    end
  }
end

-- ------------------------------------------------------

return af