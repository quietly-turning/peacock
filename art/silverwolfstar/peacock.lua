local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
  InitCommand=function(self) self:diffuse(color("#485331")):FullScreen() end
}

af[#af+1] = LoadActor("./peacock.jpg")..{
  InitCommand=function(self)
    self:Center()
    local src_h = self:GetTexture():GetSourceHeight()
    local src_w = self:GetTexture():GetSourceWidth()
    self:zoomtoheight(_screen.h - 64)
    self:zoomtowidth( src_w * self:GetZoomedHeight()/src_h )
  end
}

return af