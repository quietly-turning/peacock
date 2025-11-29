local af = Def.ActorFrame{}

local walking = true
local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
local sleep_duration = (60/bpm) * 0.5

af[#af+1] = LoadActor("grass.png")..{
  InitCommand=function(self)
    local texture = self:GetTexture()
    local src_h   = texture:GetSourceHeight()
    local txt_h   = texture:GetTextureHeight()

    self:valign(1):xy(_screen.cx,_screen.h + 40):zoomtowidth(_screen.w)
    self:texcoordvelocity(0.22,0):customtexturerect(0,0,src_h/txt_h,src_h/txt_h)
  end,
  DoneWalkingCommand=function(self) self:texcoordvelocity(0,0) end
}

af[#af+1] = LoadActor("./long-legged-fellow.png")..{
  InitCommand=function(self)
    local texture = self:GetTexture()
    local src_w   = texture:GetSourceWidth()
    local zoom = 0.333
    self:rotationy(180):zoom(zoom):valign(1):xy((src_w*0.333)*zoom, _screen.h - 30)
    self:queuecommand("StepLeft")
  end,
  StepLeftCommand=function(self)
    if walking then
      self:sleep(sleep_duration):rotationz(6):queuecommand("StepRight")
    end
  end,
  StepRightCommand=function(self)
    if walking then
      self:sleep(sleep_duration):rotationz(-6):queuecommand("StepLeft")
    end
  end,
  DoneWalkingCommand=function(self)
    self:finishtweening():rotationz(0)
  end
}

af[#af+1] = LoadActor("./speech-bubble 2x1.png")..{
  Name="LLF-speech-bubble",
  InitCommand=function(self) self:visible(false):zoom(0):animate(false):setstate(1) end,
  DoneWalkingCommand=function(self) self:visible(true):sleep(0.3):bounceend(0.3):zoom(0.5) end
}


local walk_time = 2
local af2 = Def.ActorFrame{}
af2.InitCommand=function(self) self:x(400) end
af2.ShowCommand=function(self) self:linear(walk_time):x(-100):queuecommand("StopWalking") end
af2.StopWalkingCommand=function(self)
  walking = false
  self:GetParent():queuecommand("DoneWalking")
end

af2[#af2+1] = LoadActor("./im really good at drawing guys you just want to punch in the face - little stinkers if you will.png")..{
  InitCommand=function(self)
      self:zoom(0.35):valign(1):xy(_screen.w , _screen.h - 110)
  end
}

af2[#af2+1] = LoadActor("../../Lane/cat.png")..{
  InitCommand=function(self)
      self:zoom(0.275):valign(1):xy(_screen.w-150, _screen.h)
  end
}

af[#af+1] = LoadActor("./speech-bubble 2x1.png")..{
  Name="LLF-speech-bubble",
  InitCommand=function(self) self:visible(false):zoom(0):animate(false):setstate(0):rotationy(180) end,
  DoneWalkingCommand=function(self) self:visible(true):sleep(0.3):bounceend(0.3):zoom(0.5) end
}

af[#af+1] = af2

return af