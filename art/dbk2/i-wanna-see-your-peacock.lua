local WideScale = unpack(...)

local bitmaptextActor
local cur_index = 1

local bpm = 140
local musicrate = 1/GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()

local fontpath = GAMESTATE:GetCurrentSong():GetSongDir().."art/dbk2/Arial Black/Arial Black 128px.ini"

local zoom_out_applied = false
local rotation_applied = false
local fadeout_applied  = false
local feathers_tweened = false

local START_ZOOM = WideScale(0.425, 0.585)
local START_X    = 30
local START_Y    = 460

local text = {
  { 1.500, "I       \n        \n       \n\n\n"},
  { 2.000, "I  WAN  \n        \n       \n\n\n"},
  { 2.500, "I  WANNA\n        \n       \n\n\n"},
  { 3.000, "I  WANNA\nSEE     \n       \n\n\n"},
  { 3.500, "I  WANNA\nSEE YOUR\n       \n\n\n"},
  { 4.000, "I  WANNA\nSEE YOUR\nPEA    \n\n\n"},
  { 4.500, "I  WANNA\nSEE YOUR\nPEACOCK\n\n\n"},
  { 5.500, "I  WANNA\nSEE YOUR\nPEACOCK-COCK\n\n\n"},
  { 6.500, "I  WANNA\nSEE YOUR\nPEACOCK-COCK-COCK\n\n\n"},
  { 7.500, "I  WANNA\nSEE YOUR\nPEACOCK-COCK-COCK YOUR PEA\n\n\n"},
  { 8.000, "I  WANNA\nSEE YOUR\nPEACOCK-COCK-COCK YOUR PEACOCK\n\n\n"},
  { 11.500, "I  WANNA\nSEE YOUR\nPEACOCK-COCK-COCK YOUR PEACOCK-COCK\nPEACOCK-COCK-COCK YOUR PEACOCK-COCK\nI WANNA\nSEE YOUR"},
}

local function Update(af, dt)
  if cur_index <= #text and GAMESTATE:GetSongBeat() > text[cur_index][1] then
    -- update text
    bitmaptextActor:settext(text[cur_index][2])
    -- increment index
    cur_index = cur_index + 1
  end

  if zoom_out_applied==false and GAMESTATE:GetSongBeat() > 11 then
    af:finishtweening():smooth(((60/bpm)*3)*musicrate):zoom( WideScale(0.2, 0.255) ):y(240)
    zoom_out_applied = true
  end

  if rotation_applied==false and GAMESTATE:GetSongBeat() > 15 then
    af:finishtweening():smooth(((60/bpm)*2)*musicrate):zoom(WideScale( 0.085,0.09) ):rotationz(-90):xy(_screen.cx, _screen.h-20)
    rotation_applied = true
  end

  if feathers_tweened==false and GAMESTATE:GetSongBeat() > 16 then
    af:playcommand('RevealFeathers')
    feathers_tweened = true
  end
end

-- --------------------------------------

local af = Def.ActorFrame{
  Name="WordArt-peacock",
  OnCommand=function(self)
    self:zoom(START_ZOOM):xy(START_X, START_Y)
    self:SetUpdateFunction( Update )
  end,
}

-- --------------------------------------
-- feathers

local rotations = {-90,-60,-30, 30, 60, 90}
local xOffsets = {800, 500, 200, 200, 500, 800} -- 🥴
local feathersAF = Def.ActorFrame{}

for i=1,6 do
  feathersAF[#feathersAF+1] = Def.BitmapText{
    File=fontpath,
    Text=i<4 and "\n\nPEACOCK\n\n\n" or "\n\n\nPEACOCK\n\n",
    InitCommand=function(self)
      self:align(0,0.5):diffuseleftedge({0, 0.2, 0.8, 1}):diffuserightedge({0,0.8,0.2,1})
      self:visible(false)
    end,
    RevealFeathersCommand=function(self)
      self:visible(true)
      self:decelerate(1.5 * musicrate):rotationz(rotations[i]):zoom(3)
      if xOffsets[i] then
        self:x(self:GetX()+xOffsets[i])
      end
    end
  }
end

af[#af+1] = feathersAF

-- --------------------------------------

af[#af+1] = Def.BitmapText{
  File=fontpath,
  InitCommand=function(self)
    self:align(0,0.5)
    bitmaptextActor=self
  end,
}

return af