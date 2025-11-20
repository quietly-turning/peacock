-- redefining this here with a hardcoded SCREEN_WIDTH in case someone is using 5.1's new default theme
-- there's a better way that will work for old themes and new themes alike, but I'm too tired to figure it out right now.
local WideScale = function(AR4_3, AR16_9)
   -- return scale( SCREEN_WIDTH, 640, 854, AR4_3, AR16_9 )
   local w = 480 * PREFSMAN:GetPreference("DisplayAspectRatio")
   return scale( w, 640, 854, AR4_3, AR16_9 )
end

-- ------------------------------------------------------

local musicrate = GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
-- the bpm of Katy Perry's Peacock
local bpm = 140.000
-- crossfade duration
local xfade = (60/bpm) * 0.5

-- ------------------------------------------------------

local actors = {}
local cur_actor = 1
local art_pieces = {
   -- beat     crossfade   path
   { 0.000, true, "dbk2/fight/fight.lua"}
   -- {   0.000,   false,      "dbk2/i-wanna-see-your-peacock.lua" },
   -- {  20.000,   true,       "pung/cool.jpg" },
   -- {  28.000,   true,       "doglover6262/Lucina.jpg" },
   -- {  36.000,   true,       "dandelion21/peacock.jpg" },
   -- {  44.000,   true,       "Mey-Z Daisy/a turkey and a peacock in love.jpg" },
   -- {  52.000,   false,      "alex/jaw-droppin.png" },
   -- {  54.000,   false,      "alex/eye-poppin.png" },
   -- {  56.000,   false,      "alex/head-turnin.png" },
   -- {  58.000,   false,      "alex/body-shockin.png" },
   -- {  62.000,   true,       "catsudawn/pavo-lisa.jpg" },
   -- {  84.000,   true,       "bogo/peacocklef-.png" },
   -- {  92.000,   true,       "silverwolfstar/peacock.jpg" },
   -- { 100.000,   true,       "Mey-Z Daisy/peacock-o-lantern.jpg" },
   -- { 108.000,   true,       "bogo/mimi.jpg" },
   -- { 116.000,   true,       "mrbrownjeremy/Peacuckoo.mov" },
   -- { 124.000,   true,       "Mey-Z Daisy/ascii-peacock.mp4" },
   -- { 136.000,   true,       "catsudawn/peacock/peacock.lua"},
   -- { 144.000,   true,       "dbk2/oot.mp4" },
   -- {  60.000,   true,       "pung/im really good at drawing guys you just want to punch in the face - little stinkers if you will.png" },
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
      if path:match(".mp4$") then
         self:animate(false):loop(false):diffusealpha(1):rate(musicrate)
      end
   end

   sprite.HideCommand=function(self) self:visible(false) end

   return sprite
end

local function Update(af, dt)
   -- SM({GAMESTATE:GetSongBeat(), cur_actor, art_pieces[cur_actor][3]})

   if cur_actor <= #actors and GAMESTATE:GetSongBeat() > art_pieces[cur_actor][1] then
      -- fade in current art
      actors[cur_actor]:visible(true):smooth(art_pieces[cur_actor][2] and xfade or 0):diffusealpha(1)

      -- if current art is a lua file, start it
      if art_pieces[cur_actor][3]:match(".lua$") then actors[cur_actor]:playcommand("Show") end

      -- if current art is a video, play it now
      if art_pieces[cur_actor][3]:match(".mp4$") then actors[cur_actor]:animate(true) end

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

-- ------------------------------------------------------

local args = {
   InitCommand=function(self)
      self:SetUpdateFunction( Update )
   end,
   OnCommand=function(self)
      -- don't fade out the theme's UI in EditMode
      if IsEditMode() then return end

      local screen = SCREENMAN:GetTopScreen()
      local layers = screen:GetChildren()

      if layers.In       then layers.In:visible(false) end

      if layers.PlayerP1 then layers.PlayerP1:z(1) end
      if layers.PlayerP2 then layers.PlayerP2:z(1) end

      for name,layer in pairs(layers) do
         if not (name=="SongBackground" or name=="SongForeground" or name=="PlayerP1" or name=="PlayerP2") then
            layer:smooth(1.5):diffusealpha(0)
         end
      end

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