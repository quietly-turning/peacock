local WideScale = unpack(...)

local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
  InitCommand=function(self) self:diffuse(color("#E8B5D4")):FullScreen() end
}

af[#af+1] = LoadActor("./peacocklef-.png")..{
  InitCommand=function(self)
    local src_h = self:GetTexture():GetSourceHeight()
    local src_w = self:GetTexture():GetSourceWidth()
    self:Center()
    self:zoomtoheight(_screen.h * 0.666)
    self:zoomtowidth( src_w * self:GetZoomedHeight()/src_h )
  end
}

return af