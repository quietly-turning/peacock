local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
  InitCommand=function(self) self:diffuse(1,1,1,1):FullScreen() end
}

af[#af+1] = LoadActor("./when they say theyve got that dawg in em.jpg")..{
  InitCommand=function(self)
    self:Center()
    local src_h = self:GetTexture():GetSourceHeight()
    local src_w = self:GetTexture():GetSourceWidth()
    self:zoomtoheight(_screen.h)
    self:zoomtowidth( src_w * self:GetZoomedHeight()/src_h )
  end
}

return af