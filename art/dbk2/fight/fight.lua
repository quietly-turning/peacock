local af = Def.ActorFrame{}
af.ShowCommand=function(self) self:visible(true) end
af.HideCommand=function(self) self:hibernate(math.huge) end

af[#af+1] = LoadActor("./bg.png")..{
  InitCommand=function(self)
    self:Center():setsize(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:texcoordvelocity(6,0):customtexturerect(0,0,1,1)
  end
}

af[#af+1] = LoadActor("./peacock.png")..{
  InitCommand=function(self)
    self:Center():setsize(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:cropbottom(1)
  end,
  ShowCommand=function(self)
    self:smooth(0.2):cropbottom(0)
  end
}
af[#af+1] = LoadActor("./watermelon.png")..{
  InitCommand=function(self)
    self:Center():setsize(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:croptop(1)
  end,
  ShowCommand=function(self)
    self:sleep(0.3):smooth(0.2):croptop(0)
  end
}

af[#af+1] = LoadActor("./peacock-taunt.png")..{
  InitCommand=function(self)
    self:Center():setsize(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:cropright(1)
  end,
  ShowCommand=function(self)
    self:sleep(1):smooth(0.5):cropright(0)
  end
}

af[#af+1] = LoadActor("./watermelon-taunt.png")..{
  InitCommand=function(self)
    self:Center():setsize(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:cropleft(1)
  end,
  ShowCommand=function(self)
    self:sleep(3):smooth(0.5):cropleft(0)
  end
}

af[#af+1] = LoadActor("./fight.png")..{
  InitCommand=function(self)
    self:Center():setsize(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:cropbottom(1)
  end,
  ShowCommand=function(self)
    self:sleep(4):smooth(0.666):cropbottom(0)
    self:sleep(1):accelerate(1):glow({1,0,0,1})
  end
}

return af