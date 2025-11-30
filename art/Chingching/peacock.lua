local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
  InitCommand=function(self) self:diffuse(1,1,1,1):FullScreen() end
}

af[#af+1] = LoadActor("./peacock.jpg")..{
  InitCommand=function(self)
    self:xy(_screen.cx+50, _screen.cy)
    local src_h = self:GetTexture():GetSourceHeight()
    local src_w = self:GetTexture():GetSourceWidth()
    self:zoomtoheight(_screen.h * 0.8)
    self:zoomtowidth( src_w * self:GetZoomedHeight()/src_h )
  end
}

return af