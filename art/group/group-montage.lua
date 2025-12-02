local beats = {261, 262, 263, 264, 265, 266, 267, 268}
local index = 1
local texture_dimension = 512

local function Update(af, dt)
  if (beats[index]) and GAMESTATE:GetSongBeat() > beats[index] then
    af:playcommand(("ShowFrame%d"):format(index))
    af:queuecommand(("HideFrame%d"):format(index-1))
    index = index + 1
  end
end

local af = Def.ActorFrame{}
af.InitCommand=function(self) self:SetUpdateFunction( Update ) end

local texture1, texture2

af[#af+1] = Def.Quad{
  InitCommand=function(self)
    self:diffuse(0,0,0,1):FullScreen()
  end
}

-- multimedia, harper (i think?)
af[#af+1] = LoadActor("./montage 2x2.jpg")..{
  InitCommand=function(self)
    texture1 = self:GetTexture()
    self:Center():animate(false):setstate(2)

    self:zoomtoheight(_screen.h)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
  end,
  ShowFrame0Command=function(self) self:visible(true) end,
  HideFrame0Command=function(self) self:visible(false) end,
}

-- axlemon, a peacock :)
af[#af+1] = Def.Sprite{
  OnCommand=function(self)
    self:SetTexture(texture1)
    self:Center():animate(false):setstate(0)

    self:zoomtoheight(_screen.h)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
    self:visible(false)
  end,
  ShowFrame1Command=function(self) self:visible(true) end,
  HideFrame1Command=function(self) self:visible(false) end,
}



-- real bird, paul
af[#af+1] = Def.Sprite{
  OnCommand=function(self)
    self:SetTexture(texture1)
    self:xy(_screen.cx, _screen.cy+20):animate(false):setstate(3)

    self:zoomtoheight(_screen.h * 1.8)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
    self:visible(false)
  end,
  ShowFrame2Command=function(self) self:visible(true) end,
  HideFrame2Command=function(self) self:visible(false) end,
}

-- multi-media, Dandelion
af[#af+1] = LoadActor("./montage-2 2x2.jpg")..{
  InitCommand=function(self)
    texture2 = self:GetTexture()
    self:xy(_screen.cx, _screen.cy+140):animate(false):setstate(0)

    self:zoomtoheight(_screen.h*1.5)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
    self:visible(false)
  end,
  ShowFrame3Command=function(self) self:visible(true) end,
  HideFrame3Command=function(self) self:visible(false) end,
}

-- worst seed ever D:
af[#af+1] = Def.Sprite{
  OnCommand=function(self)
    self:SetTexture(texture2)
    self:xy(_screen.cx, _screen.cy-30):animate(false):setstate(1)

    self:zoomtoheight(_screen.h * 1.8)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
    self:visible(false)
  end,
  ShowFrame4Command=function(self) self:visible(true) end,
  HideFrame4Command=function(self) self:visible(false) end,
}

-- 🍉
af[#af+1] = Def.Sprite{
  OnCommand=function(self)
    self:SetTexture(texture2)
    self:Center():animate(false):setstate(2)

    self:zoomtoheight(_screen.h * 1.8)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
    self:visible(false)
  end,
  ShowFrame5Command=function(self) self:visible(true) end,
  HideFrame5Command=function(self) self:visible(false) end,
}

-- CENSORED
af[#af+1] = Def.Sprite{
  OnCommand=function(self)
    self:SetTexture(texture1)
    self:Center():animate(false):setstate(1)

    self:zoomtoheight(_screen.h * 1.8)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
    self:visible(false)
  end,
  ShowFrame6Command=function(self) self:visible(true) end,
  HideFrame6Command=function(self) self:visible(false) end,
}

-- multi-media, yatosokan
af[#af+1] = Def.Sprite{
  OnCommand=function(self)
    self:SetTexture(texture2)
    self:Center():animate(false):setstate(3)

    self:zoomtoheight(_screen.h)
    self:zoomtowidth( texture_dimension * self:GetZoomedHeight()/texture_dimension )
    self:visible(false)
  end,
  ShowFrame7Command=function(self) self:visible(true) end,
  HideFrame7Command=function(self) self:visible(false) end,
}

return af