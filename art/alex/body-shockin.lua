local bounce_applied = false

local function Update(af, dt)
  if bounce_applied==false and GAMESTATE:GetSongBeat() > 60 then
    af:playcommand("Bounce")
    bounce_applied = true
  end
end


local af = Def.ActorFrame{}
af.OnCommand=function(self)   self:SetUpdateFunction( Update ) end
af.ShowCommand=function(self) self:visible(true) end
af.HideCommand=function(self) self:visible(false) end

af[#af+1] = Def.Quad{
  OnCommand=function(self)
    self:diffuse(color("#EFE4B0"))
    self:Center()
    self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
  end,
}

af[#af+1] = LoadActor("./body-shockin.png")..{
  InitCommand=function(self)
    local src_w = self:GetTexture():GetSourceWidth()
    self:Center():zoom(_screen.w/WideScale(src_w*0.75,src_w))
  end,
  BounceCommand=function(self)
    self:thump():effectclock('beatnooffset'):effectperiod(1)
  end
}

af[#af+1] = LoadActor("../coconutbowling/default.lua")..{
  BounceCommand=function(self)
    self:queuecommand("Animate")
  end
}

return af