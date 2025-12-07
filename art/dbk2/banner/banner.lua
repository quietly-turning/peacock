local af = Def.ActorFrame{}
af[#af+1] = Def.Quad{
  InitCommand=function(self) self:FullScreen():Center():rainbow():effectclock("beat") end
}
return af