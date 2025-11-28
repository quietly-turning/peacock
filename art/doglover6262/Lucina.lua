local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
  InitCommand=function(self)
    self:diffusetopedge(color("#460008")):diffusebottomedge(0,0,0,1):FullScreen()
  end
}

af[#af+1] = LoadActor("./Lucina.png")..{
  InitCommand=function(self)
    self:Center()
    local src_h = self:GetTexture():GetSourceHeight()
    local src_w = self:GetTexture():GetSourceWidth()
    self:zoomtoheight(_screen.h - 32)
    self:zoomtowidth( src_w * self:GetZoomedHeight()/src_h )
  end
}

return af