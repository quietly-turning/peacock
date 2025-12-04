local artists = {
  {"alex",           },
  {"Axlemon",        },
  {"bogo",           },
  {"brandon",        },
  {"catsudawn",      },
  {"Chingching",     },
  {"coconutbowling", },
  {"dandelion21",    },
  {"dbk2",           },
  {"doglover6262",   },
  {"Draner",         },
  {"Forn",           },
  {"harper",         },
  {"Mey-Z Daisy",    },
  {"mrbrownjeremy",  },
  {"paul",           },
  {"silverwolfstar", },
  {"teejusb",        },
  {"yatsokan",       },
  {"yume-chan",      }
}

-- table to store which artist-name each player is currently focused on
-- 0 is "alex", 19 is "yume-chan"
local focus = { PlayerNumber_P1=0, PlayerNumber_P2=1 }

-- number of columns in the grid of selectable artist-names
local num_cols   = 3

local col_width  = 190
local row_height = 30

-- lookup table for convenience
local OtherPlayer = { PlayerNumber_P1="PlayerNumber_P2", PlayerNumber_P2="PlayerNumber_P1" }

---------------------------------
-- variables that need file-scope for convenience

-- `artistNames_texture` will get loaded-from-disk via LoadActor() once,
-- then used by other Def.Sprite actors via SetTexture() (i.e. from memory)
local artistNames_texture
-- references to the 2 actorframes that the InputHandler has access to
local af_ref, af2_ref
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
  af_ref:GetChild(artSprite):playcommand("Set")
end


local InputActions = {
   -- decrement by 1, wrap to end if needed
   Left = function(pn)
      focus[pn] = focus[pn] - 1
      if (focus[pn] < 0) then focus[pn]=#artists-1 end
   end,

   -- increment by 1, wrap to start if needed
   Right = function(pn)
      focus[pn] = focus[pn] + 1
      if (focus[pn]>#artists-1) then focus[pn]=0 end
   end,

   -- decrement by num_cols, wrap-and-maintain-column if needed
   Up = function(pn)
      focus[pn] = focus[pn] - num_cols
      if (focus[pn] < 0) then
         if (focus[pn]%num_cols > (#artists-1)%num_cols) then
            focus[pn] = math.floor((#artists-1)/num_cols)*num_cols + focus[pn]
         else
            focus[pn] = math.ceil((#artists-1)/num_cols)*num_cols + focus[pn]
            if (focus[pn]>(#artists-1)) then focus[pn]=math.floor((#artists-1)/num_cols)*num_cols end
         end
      end
   end,

   -- increment by num_cols, wrap-and-maintain-column if needed
   Down = function(pn)
      focus[pn] = focus[pn] + num_cols
      if (focus[pn]>(#artists-1)) then
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

af[#af+1] = LoadActor("./thanks.png")..{
  InitCommand=function(self)
    self:valign(0):xy(_screen.cx, -10):zoom(0.5)
  end
}

local af2 = Def.ActorFrame{}
af2.Name="ArtistsAF"
af2.InitCommand=function(self)
  af2_ref = self
  self:xy(_screen.w*0.25, _screen.h*0.25)
end

af2[#af2+1] = Def.Sprite{
  Name="P1Cursor",
  Condition=GAMESTATE:IsHumanPlayer(PLAYER_1),
  OnCommand=function(self)
    self:SetTexture(artistNames_texture):animate(false):setstate(20)
    self:zoomx(text_zoom * 1.25):zoomy(text_zoom * 1.05)
    self:diffuse(0.4,0.4,1,1)
  end,
  ChangeFocusCommand=function(self)
    local p1_focus = self:GetParent():GetChild(("Artist%d"):format(focus.PlayerNumber_P1))
    self:xy(p1_focus:GetX()-20, p1_focus:GetY())
  end
}

af2[#af2+1] = Def.Sprite{
  Name="P2Cursor",
  Condition=GAMESTATE:IsHumanPlayer(PLAYER_2),
  OnCommand=function(self)
    self:SetTexture(artistNames_texture):animate(false):setstate(21)
    self:zoomx(text_zoom * 1.25):zoomy(text_zoom * 1.05)
    self:diffuse(0.5,1,0.5,0.9)
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
for i=1, #artists-1 do
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

af[#af+1] = LoadActor("./credits-P1 4x5.jpg")..{
  Name="P1Art",
  Condition=GAMESTATE:IsHumanPlayer(PLAYER_1),
  InitCommand=function(self)
    self:animate(0)
    self:valign(1):xy(_screen.cx-120, _screen.h-10):zoom(0.375)
  end,
  OnCommand=function(self)
    self:setstate(focus.PlayerNumber_P1)
  end,
  SetCommand=function(self)
    self:setstate(focus.PlayerNumber_P1)
  end
}

af[#af+1] = LoadActor("./credits-P2 4x5.jpg")..{
  Name="P2Art",
  Condition=GAMESTATE:IsHumanPlayer(PLAYER_2),
  InitCommand=function(self)
    self:animate(0)
    self:valign(1):xy(_screen.cx+120, _screen.h-10):zoom(0.375)
  end,
  OnCommand=function(self)
    self:setstate(focus.PlayerNumber_P2)
  end,
  SetCommand=function(self)
    self:setstate(focus.PlayerNumber_P2)
  end
}

return af