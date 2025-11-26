local texture
local eye_poppin, head_turnin, body_shockin = false, false, false

local bounce_applied = false
local exit_applied   = false

local function Update(af, dt)
  if eye_poppin==false and GAMESTATE:GetSongBeat() > 54 then
    af:playcommand("PopEyes")
    eye_poppin = true
  end

  if head_turnin==false and GAMESTATE:GetSongBeat() > 56 then
    af:playcommand("TurnHead")
    head_turnin = true
  end

  if body_shockin==false and GAMESTATE:GetSongBeat() > 58 then
    af:playcommand("ShockBody")
    body_shockin = true
  end

  if bounce_applied==false and GAMESTATE:GetSongBeat() > 60 then
    af:playcommand("Bounce")
    bounce_applied = true
  end

  if exit_applied==false and GAMESTATE:GetSongBeat() > 65 then
    af:playcommand("Exit")
    exit_applied = true
  end
end


local af = Def.ActorFrame{}
af.InitCommand=function(self)   self:SetUpdateFunction( Update ) end

af[#af+1] = Def.Quad{
  OnCommand=function(self)
    self:diffuse(color("#EFE4B0"))
    self:Center():FullScreen()
  end,
}


-- jaw droppin
af[#af+1] = LoadActor("./peacock 2x2.png")..{
  InitCommand=function(self)
    self:animate(false):setstate(0):Center()
    local src_w = self:GetTexture():GetSourceWidth()
    self:Center():zoom(_screen.w/WideScale(src_w*0.75,src_w))
    texture = self:GetTexture()
    self:GetParent():queuecommand("SetTexture")
  end,
  PopEyesCommand=function(self)
      self:hibernate(math.huge)
  end,
}

-- eye poppin
af[#af+1] = Def.Sprite{
  SetTextureCommand=function(self)
    self:SetTexture(texture)
    self:animate(false):setstate(1):Center():visible(false)
    local src_w = self:GetTexture():GetSourceWidth()
    self:Center():zoom(_screen.w/WideScale(src_w*0.75,src_w))
  end,
  PopEyesCommand=function(self)
    self:visible(true)
  end,
  TurnHeadCommand=function(self)
    self:hibernate(math.huge)
  end,
}

-- head turnin
af[#af+1] = Def.Sprite{
  InitCommand=function(self)  end,
  SetTextureCommand=function(self)
    self:SetTexture(texture)
    self:animate(false):setstate(3):Center():visible(false)
    local src_w = self:GetTexture():GetSourceWidth()
    self:zoom(_screen.w/WideScale(src_w*0.75,src_w))
    self:align(1,1):xy(_screen.w, _screen.h)
  end,
  TurnHeadCommand=function(self)
    self:visible(true)
  end,
  ShockBodyCommand=function(self)
    self:hibernate(math.huge)
  end,
}

-- body shockin
af[#af+1] = Def.Sprite{
  SetTextureCommand=function(self)
    self:SetTexture(texture)
    self:animate(false):setstate(2):Center():visible(false)
    local src_w = self:GetTexture():GetSourceWidth()
    self:Center():zoom(_screen.w/WideScale(src_w*0.75,src_w))
  end,
  ShockBodyCommand=function(self)
    self:visible(true)
  end,
  BounceCommand=function(self)
    self:thump():effectclock('beat'):effectperiod(1)
  end,
  ExitCommand=function(self)
    self:bouncebegin(1):y(_screen.h * 1.5):zoom( self:GetZoom()*0.1)
  end
}

af[#af+1] = LoadActor("../coconutbowling/default.lua")..{
  BounceCommand=function(self)
    self:queuecommand("Animate")
  end
}

return af