local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
local musicrate = 1/GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
local beat_duration = (60/bpm) * musicrate

local widthScaler = (_screen.w/854) -- accommodate themes with a DisplayWidth larger than 854

local actions_index = 1
local actions = {
  {54, "PopEyes"},
  {56, "TurnHead"},
  {58, "ShockBody"},
  {60, "Bounce"},
  {65, "Exit"}
}

local function Update(af, dt)
  if actions[actions_index] and GAMESTATE:GetSongBeat() > actions[actions_index][1] then
    af:playcommand(actions[actions_index][2])
    actions_index = actions_index + 1
  end
end

-- ------------------------------------------------------

local af = Def.ActorFrame{}
af.InitCommand=function(self) self:SetUpdateFunction( Update ) end

af[#af+1] = Def.Quad{
  OnCommand=function(self)
    self:diffuse(color("#EFE4B0"))
    self:Center():FullScreen()
  end,
  ExitCommand=function(self)
    self:sleep(beat_duration*1.5)
    self:accelerate(beat_duration*0.5):diffuse(color("#74A376"))
  end
}


-- jaw droppin
af[#af+1] = LoadActor("./peacock 2x2.png")..{
  InitCommand=function(self)
    self:animate(false):setstate(0)

    local src_w = self:GetTexture():GetSourceWidth()
    self:zoom((_screen.w/WideScale(src_w*0.75,src_w)) * widthScaler)

    self:align(0.5, 0.5):Center() -- center the texture
  end,
  PopEyesCommand=function(self)
    self:setstate(1)
  end,
  TurnHeadCommand=function(self)
    self:setstate(3)
    self:align(1,1):xy(_screen.w, _screen.h) -- right-justify the texture
  end,
  ShockBodyCommand=function(self)
    self:setstate(2)
    self:align(0.5, 0.5):Center() -- center the texture
  end,
  BounceCommand=function(self)
    self:thump():effectclock('beat'):effectperiod(1)
  end,
  ExitCommand=function(self)
    self:stopeffect()
    self:bouncebegin(beat_duration*2):y(_screen.h * 1.5):zoom( self:GetZoom()*0.1)
  end
}

af[#af+1] = LoadActor("../coconutbowling/default.lua")..{
  BounceCommand=function(self)
    self:queuecommand("Animate")
  end
}

return af