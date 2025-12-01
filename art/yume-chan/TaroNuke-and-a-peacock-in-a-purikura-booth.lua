local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
  InitCommand=function(self) self:diffuse(0,0,0,1):FullScreen() end
}

af[#af+1] = LoadActor("./TaroNuke-and-a-peacock-in-a-purikura-booth.jpg")..{
  InitCommand=function(self)
    self:xy(_screen.cx, _screen.h):valign(1)
    local src_h = self:GetTexture():GetSourceHeight()
    local src_w = self:GetTexture():GetSourceWidth()
    self:zoomtoheight(_screen.h - 64 )
    self:zoomtowidth( src_w * self:GetZoomedHeight()/src_h )
  end
}

return af