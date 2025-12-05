 -- 0: TacoRat
 -- 1: Axlemon
 -- 2: bogo
 -- 3: brandon
 -- 4: catsudawn
 -- 5: Chingching
 -- 6: coconutbowli
 -- 7: dandelion21
 -- 8: dbk2
 -- 9: doglover6262
 --10: Draner
 --11: Forn
 --12: harper
 --13: Mey-Z Daisy
 --14: mrbrownjeremy
 --15: Paul
 --16: Silverwolfstar
 --17: teejusb
 --18: yatsokan
 --19: YUME★CHAN

local num_artists = 20

-- table to store which artist-name each player is currently focused on
-- 0 is TacoRat, 19 is YUME★CHAN
local focus = { PlayerNumber_P1=0, PlayerNumber_P2=1 }

local playercolor = {
  --                 r    g    b    a
  PlayerNumber_P1={0.4, 0.4, 1.0, 1.0},
  PlayerNumber_P2={0.5, 1.0, 0.5, 0.9}
}

-- number of columns in the grid of selectable artist-names
local num_cols   = 3

local col_width  = 190
local row_height = 30

-- lookup table for convenience
local OtherPlayer = { PlayerNumber_P1="PlayerNumber_P2", PlayerNumber_P2="PlayerNumber_P1" }

local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
local musicrate = 1/GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()

---------------------------------
-- variables that need file-scope for convenience

-- `artistNames_texture` will get loaded-from-disk via LoadActor() once,
-- then used by other Def.Sprite actors via SetTexture() (i.e. from memory)
local artistNames_texture

-- references to the 2 actorframes that the InputHandler has access to
local af_ref, af2_ref

-- accommodate themes with a DisplayWidth larger than 854
local widthScaler = (_screen.w/854)
---------------------------------

local function UpdateGridFocus(pn)
  -- -------------------------------------------------------
  -- update text and cursor actors for player with input event
  local childText   = ("Artist%d"):format(focus[pn])
  local cursorName  = ("%sCursor"):format(ToEnumShortString(pn))
  af2_ref:GetChild(childText):playcommand("Focus")
  af2_ref:GetChild(cursorName):playcommand("ChangeFocus")

  -- -------------------------------------------------------
  -- update text and cursor actors for other player
  if GAMESTATE:IsHumanPlayer(OtherPlayer[pn]) then
    local otherText   = ("Artist%d"):format(focus[OtherPlayer[pn]])
    local otherCursor = ("%sCursor"):format(ToEnumShortString(OtherPlayer[pn]))
    af2_ref:GetChild(otherText):playcommand("Focus")
    af2_ref:GetChild(otherCursor):playcommand("ChangeFocus")
  end

  -- -------------------------------------------------------
  -- update small-scale art sprite for player with input event
  local artSprite = ("%sArt"):format(ToEnumShortString(pn))
  af_ref:GetChild("SelectedArtists"):GetChild(artSprite):playcommand("Set")
  -- update label for small-scale art sprite
  local focusLabel = ("%sFocusArtistName"):format(ToEnumShortString(pn))
  af_ref:GetChild("SelectedArtists"):GetChild(focusLabel):playcommand("Set")
end


local InputActions = {
   -- decrement by 1, wrap to end if needed
   Left = function(pn)
      focus[pn] = focus[pn] - 1
      if (focus[pn] < 0) then focus[pn]=num_artists-1 end
   end,

   -- increment by 1, wrap to start if needed
   Right = function(pn)
      focus[pn] = focus[pn] + 1
      if (focus[pn]>num_artists-1) then focus[pn]=0 end
   end,

   -- decrement by num_cols, wrap-and-maintain-column if needed
   Up = function(pn)
      focus[pn] = focus[pn] - num_cols
      if (focus[pn] < 0) then
         if (focus[pn]%num_cols > (num_artists-1)%num_cols) then
            focus[pn] = math.floor((num_artists-1)/num_cols)*num_cols + focus[pn]
         else
            focus[pn] = math.ceil((num_artists-1)/num_cols)*num_cols + focus[pn]
            if (focus[pn]>(num_artists-1)) then focus[pn]=math.floor((num_artists-1)/num_cols)*num_cols end
         end
      end
   end,

   -- increment by num_cols, wrap-and-maintain-column if needed
   Down = function(pn)
      focus[pn] = focus[pn] + num_cols
      if (focus[pn]>(num_artists-1)) then
         focus[pn] = focus[pn]%num_cols
         if (focus[pn] < 0) then focus[pn]=num_cols end
      end
   end
}

local function InputHandler(event)
  if event.type ~= "InputEventType_FirstPress" then return end
  if not InputActions[event.button]            then return end
  if not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then return end

  -- cause all artist names to lose focus
  af2_ref:playcommand("LoseFocus")

  -- update cursor index for player that generated input event
  InputActions[event.button](event.PlayerNumber)

  UpdateGridFocus(event.PlayerNumber)
end

-- ------------------------------------------------------------------------
local _, IsEditMode, GetPlayerAF = unpack(LoadActor("../../../FGCHANGES/helpers.lua"))
local text_zoom = 0.3

local af = Def.ActorFrame{}
af.InitCommand=function(self) af_ref = self end
af.OnCommand=function(self)
  for player in ivalues(GAMESTATE:GetHumanPlayers()) do
    UpdateGridFocus(player)
  end
end
af.ShowCommand=function(self)
  SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)

  for player in ivalues(GAMESTATE:GetHumanPlayers()) do
    -- hide the receptor arrows with "Dark"
    GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Song"):Dark(1,2)

    -- hide the player combo by hiding the player ActorFrames
    if not IsEditMode() then
      local playerAF = GetPlayerAF(ToEnumShortString(player))
      playerAF:hibernate(math.huge)
    end
  end
end

-- simple bg
af[#af+1] = Def.Quad{
  InitCommand=function(self) self:Center():FullScreen():diffuse(0,0,0,0) end,
  ShowCommand=function(self) self:accelerate(((60/bpm)*2)*musicrate):diffusealpha(1) end
}

-- ------------------------------------------------------------------------

local af3 = Def.ActorFrame{}
af3.Name="SelectedArtists"
af3.InitCommand=function(self) self:diffusealpha(0):x(_screen.cx):zoom(widthScaler) end
af3.ShowCommand=function(self)
  self:accelerate(((60/bpm)*2)*musicrate):diffusealpha(1)
end

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
  local pn = ToEnumShortString(player)

  -- sprite showing small-scale art by selected artist
  af3[#af3+1] = LoadActor(("./credits-%s 4x5.jpg"):format(pn))..{
    Name=("%sArt"):format(pn),
    InitCommand=function(self)
      self:animate(0)
      self:valign(0):xy(120 * (player==PLAYER_1 and -1 or 1), 15):zoom(0.375)
    end,
    OnCommand=function(self)
      self:setstate(focus[player])
    end,
    SetCommand=function(self)
      self:setstate(focus[player])
    end
  }

  -- artist name label
  af3[#af3+1] = Def.Sprite{
    Name=("%sFocusArtistName"):format(pn),
    InitCommand=function(self)
      self:zoom(text_zoom)
      self:animate(false)
      self:xy(120 * (player==PLAYER_1 and -1 or 1), 185)
      self:diffuse(playercolor[player])
    end,
    OnCommand=function(self)
      self:SetTexture(artistNames_texture):setstate(focus.PlayerNumber_P1)
    end,
    SetCommand=function(self)
      self:setstate(focus.PlayerNumber_P1)
    end,
  }
end

af[#af+1] = af3

-- ------------------------------------------------------------------------
-- "thanks to these artists"

af[#af+1] = LoadActor("./thanks.png")..{
  InitCommand=function(self)
    self:valign(0):xy(_screen.cx, 190*widthScaler):zoom(0.45 * widthScaler):diffusealpha(0)
  end,
  ShowCommand=function(self) self:accelerate(((60/bpm)*2)*musicrate):diffusealpha(1) end
}

-- ------------------------------------------------------------------------
-- grid of artist names

local af2 = Def.ActorFrame{}
af2.Name="ArtistsAF"
af2.InitCommand=function(self)
  af2_ref = self
  self:zoom(0.9*widthScaler)
  self:xy((_screen.w*0.5) - (col_width * self:GetZoom()), 300*widthScaler)
  self:diffusealpha(0)
end
af2.ShowCommand=function(self) self:accelerate(((60/bpm)*2)*musicrate):diffusealpha(1) end

-- P1 cursor
af2[#af2+1] = Def.Sprite{
  Name="P1Cursor",
  Condition=GAMESTATE:IsHumanPlayer(PLAYER_1),
  OnCommand=function(self)
    self:SetTexture(artistNames_texture):animate(false):setstate(20)
    self:zoomx(text_zoom * 1.25):zoomy(text_zoom * 1.05)
    self:diffuse(playercolor.PlayerNumber_P1)
  end,
  ChangeFocusCommand=function(self)
    local p1_focus = self:GetParent():GetChild(("Artist%d"):format(focus.PlayerNumber_P1))
    self:xy(p1_focus:GetX()-20, p1_focus:GetY())
  end
}

-- P2 cursor
af2[#af2+1] = Def.Sprite{
  Name="P2Cursor",
  Condition=GAMESTATE:IsHumanPlayer(PLAYER_2),
  OnCommand=function(self)
    self:SetTexture(artistNames_texture):animate(false):setstate(21)
    self:zoomx(text_zoom * 1.25):zoomy(text_zoom * 1.05)
    self:diffuse(playercolor.PlayerNumber_P2)
  end,
  ChangeFocusCommand=function(self)
    local p2_focus = self:GetParent():GetChild(("Artist%d"):format(focus.PlayerNumber_P2))
    self:xy(p2_focus:GetX()+20, p2_focus:GetY())
  end
}

-- 1st artist in the list, used to load the texture of all artist names
af2[#af2+1] = LoadActor("./artists 2x11")..{
  Name="Artist0",
  InitCommand=function(self)
    self:animate(false):setstate(0):xy(0, 0):zoom(text_zoom)
    artistNames_texture = self:GetTexture()
  end,
  FocusCommand=function(self)
    self:diffuse(0,0,0,1)
  end,
  LoseFocusCommand=function(self)
    self:diffuse(1,1,1,1)
  end
}

-- all other artists added in for-loop, re-using the already-loaded texture from 1st artist
for i=1, num_artists-1 do
  af2[#af2+1] = Def.Sprite{
    Name=("Artist%d"):format(i),
    InitCommand=function(self)
      self:SetTexture(artistNames_texture):animate(false):setstate(i):zoom(text_zoom)
      self:xy((i%num_cols) * col_width, (math.floor(i/num_cols)) * row_height)
    end,
    FocusCommand=function(self)
      self:diffuse(0,0,0,1)
    end,
    LoseFocusCommand=function(self)
      self:diffuse(1,1,1,1)
    end
  }
end

af[#af+1] = af2

-- ------------------------------------------------------------------------


return af