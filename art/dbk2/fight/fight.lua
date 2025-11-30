local WideScale = unpack(...)
local base_path = GAMESTATE:GetCurrentSong():GetSongDir()
local musicrate = 1/GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()

local actions = {
  {253.735, "Flash"},
  {256, "ShowFightText"},
  {258, "WhyNotBoth"   },
}
local actions_index = 1

local function Update(af, dt)
  if (actions_index <= #actions) and (GAMESTATE:GetSongBeat() > actions[actions_index][1]) then
    af:playcommand(actions[actions_index][2])
    actions_index = actions_index + 1
  end
end

local af = Def.ActorFrame{}
af.OnCommand=function(self)
  self:SetUpdateFunction( Update )
end

af[#af+1] = LoadActor("./bg.png")..{
  InitCommand=function(self)
    self:Center():setsize(_screen.w, _screen.h)
    self:texcoordvelocity(6,0):customtexturerect(0,0,1,1)
  end
}

af[#af+1] = Def.Quad{
  Name="Flash",
  InitCommand=function(self) self:Center():FullScreen():diffuse(1,0,0,0) end,
  FlashCommand=function(self) self:diffusealpha(1):decelerate(1*musicrate):diffuse(1,1,1,0) end
}

-- -------------------------------------------------
-- fighter portraits

local w = 400
local c = {1,1,1,1}
local fighter_zoom = 0.9

-- peacock
af[#af+1] = Def.ActorMultiVertex{
  Name="Peacock-fighter",
  InitCommand=function(self)
    self:LoadTexture(("%sart/dbk2/fight/fighters.png"):format(base_path))
    self:SetDrawState({Mode="DrawMode_Triangles"})
    self:SetVertices({
      {{0, _screen.h-w, 0}, c, {1,0}},
      {{0, _screen.h,   0}, c, {0,0}},
      {{w, _screen.h,   0}, c, {0,1}}
    })
    self:x(-w):zoom(fighter_zoom)
    self:y((_screen.h * (1/fighter_zoom)) - _screen.h)
  end,
  ShowCommand=function(self)
    self:bounceend(0.25*musicrate):x(0)
  end
}

-- watermelons
af[#af+1] = Def.ActorMultiVertex{
  Name="Watermelon-fighter",
  InitCommand=function(self)
    self:SetTexture( self:GetParent():GetChild("Peacock-fighter"):GetTexture() )
    self:SetDrawState({Mode="DrawMode_Triangles"})
    self:SetVertices({
      {{_screen.w,   _screen.h-w, 0}, c, {1,0}},
      {{_screen.w,   _screen.h, 0}, c, {1,1}},
      {{_screen.w-w, _screen.h, 0}, c, {0,1}}
    })
    self:x(w * 1/fighter_zoom):zoom(fighter_zoom)
    self:y((_screen.h * (1/fighter_zoom)) - _screen.h)
  end,
  ShowCommand=function(self)
    self:sleep(0.25*musicrate)
    self:bounceend(0.2*musicrate):x(_screen.w*(1/fighter_zoom) - _screen.w)
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
    self:sleep(1*musicrate):smooth(0.2*musicrate):cropright(0)
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
    self:sleep(2*musicrate):accelerate(0.15*musicrate):zoom(1):smooth(0.15*musicrate):rotationz(2):accelerate(0.15*musicrate):rotationz(0):zoom(0.5)
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
    self:diffusealpha(0.5):decelerate(1*musicrate):zoom(0.65):diffusealpha(0)
  end
}

af[#af+1] = af2
-- -------------------------------------------------

af[#af+1] = LoadActor("./fight.png")..{
  InitCommand=function(self)
    self:Center():zoom(0)
  end,
  ShowFightTextCommand=function(self)
    self:accelerate(0.2*musicrate):zoom(WideScale(0.5,0.75))
  end
}

-- the rumor come out
af[#af+1] = LoadActor("peacocks-and-melons.png")..{
  InitCommand=function(self)
    self:xy(-300,_screen.cy):zoom(0.6)
  end,
  WhyNotBothCommand=function(self)
    self:smooth(0.8*musicrate):rotationz(720):x(_screen.w+300)
  end
}

return af