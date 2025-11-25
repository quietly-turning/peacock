-- redefining this here with a hardcoded SCREEN_WIDTH in case someone is using 5.1's new default theme
-- there's a better way that will work for old themes and new themes alike, but I'm too tired to figure it out right now.
local WideScale = function(AR4_3, AR16_9)
   -- return scale( SCREEN_WIDTH, 640, 854, AR4_3, AR16_9 )
   local w = 480 * PREFSMAN:GetPreference("DisplayAspectRatio")
   return scale( w, 640, 854, AR4_3, AR16_9 )
end

-- ------------------------------------------------------
-- the bpm of Katy Perry's Peacock
local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
-- music rate chosen by the player(s)
local musicrate = GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()

-- possible crossfade duration
local crossfades = {
   quarter_note   = (60/bpm),
   eighth_note    = (60/bpm) * 0.5,
   sixteenth_note = (60/bpm) * 0.25,
}

--
local xfade = crossfades.sixteenth_note

-- ------------------------------------------------------

local actors = {}
local cur_actor = 1
local art_pieces = {
   --  beat     crossfade   path
   {   0.000,   false,      "dbk2/i-wanna-see-your-peacock.lua" },
   {  20.000,   false,      "pung/cool.jpg" },
   {  28.000,   true,       "doglover6262/Lucina.jpg" },
   {  36.000,   true,       "dandelion21/peacock.jpg" },
   {  44.000,   true,       "Mey-Z Daisy/a turkey and a peacock in love.jpg" },
   {  52.000,   false,      "alex/peacock.lua" },
   {  68.000,   true,       "catsudawn/peacock/peacock.lua"},
   {  84.000,   true,       "bogo/peacocklef-.png" },
   {  92.000,   true,       "silverwolfstar/peacock.jpg" },
   { 100.000,   true,       "Mey-Z Daisy/peacock-o-lantern.jpg" },
   { 108.000,   true,       "bogo/mimi.jpg" },
   { 116.000,   true,       "mrbrownjeremy/Peacuckoo.mov" },
   { 124.000,   true,       "Mey-Z Daisy/ascii-peacock.mp4" },
   { 140.000,   true,       "mrbrownjeremy/Peacuckoo2.mp4" },
   { 148.000,   true,       "Draner/archipelago-peacock.jpg" },
   { 156.000,   true,       "bogo/when they say theyve got that dawg in em.jpg" },
   { 164.000,   true,       "brandon/peacock.jpg" },
   { 172.000,   true,       "catsudawn/pavo-lisa.jpg" },
   { 180.000,   true,       "teejusb/peacock.png" },
   { 188.000,   true,       "placeholder.png" },  -- real bird
   { 196.000,   true,       "Chingching/peacock.jpg"},
   { 204.000,   true,       "placeholder.png" },  -- cyber peacock
   { 212.000,   true,       "placeholder.png" },  -- hey guys
   { 228.000,   true,       "dbk2/oot.mp4"},
   { 248.000,   true,       "dbk2/fight/fight.lua" },
   { 260.000,   true,       "placeholder.png" },
   { 268.000,   true,       "mrbrownjeremy/Peacuckoo3.lua" },
   { 278.000,   true,       "placeholder.png"}
   -- { 278.000,   true,       "credits/credits.lua" },
}

-- ------------------------------------------------------

local function GenerateSprite(path)

   local sprite = LoadActor( ("../art/%s"):format(path) )

   sprite.OnCommand=function(self)
      -- add reference to this scene to convenience table
      actors[#actors+1] = self

      -- don't draw and set alpha of 0 on each sprite to being
      self:visible(false):diffusealpha(0)

      -- zoom each sprite based on the width of the original png/jpg/mp4
      -- so that it fits perfectly in 16:9 and crop the sides in 4:3
      local src_w = self:GetTexture():GetSourceWidth()
      self:Center():zoom(_screen.w/WideScale(src_w*0.75,src_w))

      -- if it is a video, don't start playing it immediately, and don't loop playback
      if path:match(".mp4$") or path:match(".mov$") then
         self:animate(false):loop(false):diffusealpha(1):rate(musicrate)

         -- don't try to filter-blur pixel animations
         if path:match("mrbrownjeremy") then
            self:SetTextureFiltering(false)
         end
      end
   end

   sprite.HideCommand=function(self) self:hibernate(math.huge) end

   return sprite
end

local function Update(af, dt)
   if cur_actor <= #actors and GAMESTATE:GetSongBeat() > art_pieces[cur_actor][1] then
      -- fade in current art
      actors[cur_actor]:visible(true):smooth(art_pieces[cur_actor][2] and xfade or 0):diffusealpha(1)

      -- if current art is a lua file, start it
      if art_pieces[cur_actor][3]:match(".lua$") then actors[cur_actor]:playcommand("Show") end

      -- if current art is a video, play it now
      if art_pieces[cur_actor][3]:match(".mp4$") or art_pieces[cur_actor][3]:match(".mov$") then actors[cur_actor]:animate(true) end

      -- fade out prev art
      if (cur_actor-1 > 0) then actors[cur_actor-1]:sleep(xfade):queuecommand("Hide") end
      -- increment index
      cur_actor = cur_actor + 1
   end
end

local function IsEditMode()
   local screen = SCREENMAN:GetTopScreen()
   if not screen then
      SCREENMAN:SystemMessage("IsEditMode() check failed to run because there is no Screen yet.\nYou should call this function from an OnCommand instead of an InitCommand so that it's more helpful.")
      return nil
   end

   return (THEME:GetMetric(screen:GetName(), "Class") == "ScreenEdit")
end


local function GetPlayerAF(pn)
   local screen = SCREENMAN:GetTopScreen()
   if not screen then return false end

   local playerAF = nil

   -- Get the player ActorFrame on ScreenGameplay
   -- It's a direct child of the screen and named "PlayerP1" for P1
   -- and "PlayerP2" for P2.
   -- This naming convention is hardcoded in the SM5 engine.
   --
   -- ScreenEdit does not name its player ActorFrame, but we can still find it.

   -- find the player ActorFrame in edit + practice mode
   if (THEME:GetMetric(screen:GetName(), "Class") == "ScreenEdit") then
      local notefields = {}
      -- loop through all nameless children of `screen`
      -- and find the one that contains the NoteField
      -- which is thankfully still named "NoteField"
      for _,nameless_child in ipairs(screen:GetChild("")) do
         if nameless_child:GetChild("NoteField") then
            notefields[#notefields+1] = nameless_child
         end
      end

      -- needed for practice mode
      -- If there is only one side joined always return the first one.
      if #notefields == 1 then
         playerAF = notefields[1]
      -- If there are two sides joined, return the one that matches the player number.
      else
         playerAF = notefields[PlayerNumber:Reverse()["PlayerNumber_"..pn]+1]
      end

   -- find the player ActorFrame in gameplay
   else
      local player_af = screen:GetChild("Player"..pn)
      if player_af then
         playerAF = player_af
      end
   end

   return playerAF
end

-- ------------------------------------------------------

local args = {
   InitCommand=function(self)
      self:SetUpdateFunction( Update )
   end,
   OnCommand=function(self)
      local screen = SCREENMAN:GetTopScreen()
      local layers = screen:GetChildren()

      -- hide/fade-out UI in Gameplay so players can focus on the lovely art :)
      -- don't fade UI in Edit mode
      if not IsEditMode() then
         if layers.In then layers.In:visible(false) end

         for name,layer in pairs(layers) do
            if not (name=="SongBackground" or name=="SongForeground" or name=="PlayerP1" or name=="PlayerP2") then
               layer:smooth(1.5):diffusealpha(0)
            end
         end
      end


      local p1AF = GetPlayerAF("P1")
      local p2AF = GetPlayerAF("P2")
      if p1AF then p1AF:z(1) end
      if p2AF then p2AF:z(1) end

      self:queuecommand("SetDraw")
   end,
   SetDrawCommand=function()
      SCREENMAN:GetTopScreen():SetDrawByZPosition(true)
   end,
}

args[#args+1] = Def.Actor({ InitCommand=function(self) self:sleep(999) end })

for _, piece in ipairs(art_pieces) do

   if (piece[3]:match(".lua$")) then
      args[#args+1] = LoadActor("../art/"..piece[3], {WideScale})..{
         OnCommand=function(self)
            actors[#actors+1] = self
            self:visible(false)
         end
      }
   else
      args[#args+1] = GenerateSprite(piece[3])
   end
end

return Def.ActorFrame(args)