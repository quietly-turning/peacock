local af = Def.ActorFrame{}
af[#af+1] = Def.Quad{
  InitCommand=function(self) self:FullScreen():Center():rainbow():effectclock("beat") end
}

af[#af+1] = LoadActor("./_bn-peacock2.png")..{
  InitCommand=function(self) self:Center() end
}

return af