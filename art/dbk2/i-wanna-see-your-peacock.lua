local bitmaptextActor
local cur_index = 1
local fontpath = GAMESTATE:GetCurrentSong():GetSongDir().."art/dbk2/Arial Black/Arial Black 128px.ini"
local zoom_out_applied = false
local rotation_applied = false
local fadeout_applied  = false
local bpm = 140

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

  if zoom_out_applied==false and GAMESTATE:GetSongBeat() > 14 then
    bitmaptextActor:finishtweening():smooth((60/bpm)*3):zoom(0.255):y(240)
    zoom_out_applied = true
  end

  if rotation_applied==false and GAMESTATE:GetSongBeat() > 17.5 then
    bitmaptextActor:finishtweening():smooth((60/bpm)*2):zoom(0.125):rotationz(-90):xy(_screen.cx, _screen.h-20)
    rotation_applied = true
  end

  if GAMESTATE:GetSongBeat() > 24 then
    af:hibernate(math.huge)
  end
end

local af = Def.ActorFrame{
  OnCommand=function(self)
    self:SetUpdateFunction( Update )
  end,

  Def.BitmapText{
    File=fontpath,
    InitCommand=function(self)
      self:align(0,0.5):zoom(0.55):xy(40, 420)
      bitmaptextActor=self
    end,
  }
}

return af