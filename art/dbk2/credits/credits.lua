local artists = {
  {"alex"},
  {"Axlemon"},
  {"bogo"},
  {"brandon"},
  {"catsudawn"},
  {"Chingching"},
  {"coconutbowling"},
  {"dandelion21"},
  {"dbk2"},
  {"doglover6262"},
  {"Draner"},
  {"Forn"},
  {"harper"},
  {"Mey-Z Daisy"},
  {"mrbrownjeremy"},
  {"paul"},
  {"silverwolfstar"},
  {"teejusb"},
  {"yatsokan"},
  {"yume-chan"}
}

local focus = { PlayerNumber_P1=0, PlayerNumber_P2=1 }
local texture, af_ref
local base_path = GAMESTATE:GetCurrentSong():GetSongDir()
local num_cols = 4
local padding = 24

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

  af_ref:playcommand("LoseFocus")
  InputActions[event.button](event.PlayerNumber)

  local childName = ("Artist%d"):format(focus[event.PlayerNumber])
  local cmdName   = ("%sFocus"):format(ToEnumShortString(event.PlayerNumber))
  af_ref:GetChild(childName):playcommand(cmdName)
end


-- ------------------------------------------------------

local text_zoom = 0.333

local af = Def.ActorFrame{}
af.InitCommand=function(self)
  af_ref = self
  self:xy(200,130)
end
af.OnCommand=function(self)
  self:GetChild("Artist0"):playcommand("P1Focus")
  self:GetChild("Artist1"):playcommand("P2Focus")
end
af.ShowCommand=function(self)
  SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
end

af[#af+1] = LoadActor("./thanks.png")..{
  InitCommand=function(self) self:xy(_screen.cx-200, -60):zoom(0.5) end
}

af[#af+1] = LoadActor("./artists 2x10")..{
  Name="Artist0",
  InitCommand=function(self)
    self:animate(false):setstate(0):xy(0, 0):zoom(text_zoom)
    texture = self:GetTexture()
  end,
  P1FocusCommand=function(self)
    self:diffuse(1,0,0,1)
  end,
  P2FocusCommand=function(self)
    self:diffuse(0,0,1,1)
  end,
  LoseFocusCommand=function(self)
    self:diffuse(1,1,1,1)
  end
}

for i=1, #artists-1 do
  af[#af+1] = Def.Sprite{
    Name=("Artist%d"):format(i),
    InitCommand=function(self)
      self:SetTexture(texture):animate(false):setstate(i):zoom(text_zoom)
      self:xy((i%num_cols)*164, (math.floor(i/num_cols))*30 )
    end,
    P1FocusCommand=function(self)
      self:diffuse(1,0,0,1)
    end,
    P2FocusCommand=function(self)
      self:diffuse(0,0,1,1)
    end,
    LoseFocusCommand=function(self)
      self:diffuse(1,1,1,1)
    end
  }
end

return af