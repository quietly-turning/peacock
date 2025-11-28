local base_path = GAMESTATE:GetCurrentSong():GetSongDir()

local af = Def.ActorFrame{}

af[#af+1] = LoadActor("./bg.png")..{
  InitCommand=function(self)
    self:Center():setsize(_screen.w, _screen.h)
    self:texcoordvelocity(6,0):customtexturerect(0,0,1,1)
  end
}

af[#af+1] = Def.Quad{
  Name="Flash",
  InitCommand=function(self) self:Center():FullScreen():diffuse(1,0,0,0) end,
  FlashCommand=function(self) self:diffusealpha(1):decelerate(1):diffuse(1,1,1,0) end
}

-- -------------------------------------------------
-- fighter portraits

local w = 480
local c = {1,1,1,1}

-- peacock
af[#af+1] = Def.ActorMultiVertex{
  Name="Peacock-fighter",
  InitCommand=function(self)
    self:LoadTexture(("%sart/dbk2/fight/fighters.png"):format(base_path))
    self:SetDrawState({Mode="DrawMode_Triangles"})
    self:SetVertices({
      {{0,         0, 0}, c, {0,0}},
      {{w,         0, 0}, c, {1,0}},
      {{0, _screen.h, 0}, c, {0,1}}
    })
    self:x(-w)
  end,
  ShowCommand=function(self)
    self:bounceend(0.25):x(-50)
  end
}

-- watermelons
af[#af+1] = Def.ActorMultiVertex{
  Name="Watermelon-fighter",
  InitCommand=function(self)
    self:SetTexture( self:GetParent():GetChild("Peacock-fighter"):GetTexture() )
    self:SetDrawState({Mode="DrawMode_Triangles"})
    self:SetVertices({
      {{_screen.w,           0, 0}, c, {1,0}},
      {{_screen.w,   _screen.h, 0}, c, {1,1}},
      {{_screen.w-w, _screen.h, 0}, c, {0,1}}
    })
    self:x(w)
  end,
  ShowCommand=function(self)
    self:sleep(0.25):bounceend(0.2):x(50)
  end
}
-- -------------------------------------------------
-- fighters trade barbs

-- "I've got the greatest BG art of all time!"
af[#af+1] = LoadActor("./barbs 1x2.png")..{
  Name="Peacock-taunt",
  InitCommand=function(self)
    self:animate(false):setstate(0)
    self:align(0,0):xy(80, 130):zoom(0.5)
    self:cropright(1)
  end,
  ShowCommand=function(self)
    self:sleep(1):smooth(0.2):cropright(0)
  end
}


-- container for there-con-be-only-one and ghost-sprite
local af2 = Def.ActorFrame{
  InitCommand=function(self)
    self:xy(_screen.w-300, _screen.h-130)
  end
}

-- "there can be only one"
af2[#af2+1] = Def.Sprite{
  OnCommand=function(self)
    self:SetTexture( self:GetParent():GetParent():GetChild("Peacock-taunt"):GetTexture() )
    self:animate(false):setstate(1)
    self:zoom(0)
  end,
  ShowCommand=function(self)
    self:sleep(2):accelerate(0.15):zoom(1):smooth(0.15):rotationz(2):accelerate(0.15):rotationz(0):zoom(0.5)
    self:queuecommand("InitiateFlash")
  end,
  InitiateFlashCommand=function(self)
    self:GetParent():GetParent():playcommand("Flash")
  end,
}
-- ghost "there can be only one"
af2[#af2+1] = Def.Sprite{
  Name="Ghost-outline",
  OnCommand=function(self)
    self:SetTexture( self:GetParent():GetParent():GetChild("Peacock-taunt"):GetTexture() )
    self:animate(false):setstate(1)
    self:zoom(0.5)
    self:diffusealpha(0)
  end,
  FlashCommand=function(self)
    self:diffusealpha(0.5):decelerate(1):zoom(0.65):diffusealpha(0)
  end
}

af[#af+1] = af2
-- -------------------------------------------------

af[#af+1] = LoadActor("./fight.png")..{
  InitCommand=function(self)
    self:Center():zoom(0)
  end,
  FlashCommand=function(self)
    self:sleep(1.2):accelerate(0.2):zoom(0.75)
  end
}

-- the rumor come out
af[#af+1] = LoadActor("peacocks-and-melons.png")..{
  InitCommand=function(self)
    self:xy(-300,_screen.cy):zoom(0.6)
  end,
  FlashCommand=function(self)
    self:sleep(2):smooth(0.8):rotationz(720):x(_screen.w+300)
  end
}

return af