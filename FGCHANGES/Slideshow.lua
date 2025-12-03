-- ------------------------------------------------------
-- Slideshow.lua: for when you REALLY want to ensure players see the bg art :)
--
-- author:         quietly-turning
-- GitHub:         https://github.com/quietly-turning/peacock
-- 1st appearance: Watermelon, from UPS5
-- ------------------------------------------------------

-- a table of the art pieces I want to appear in my slideshow
local art_pieces = LoadActor("./bg-art.lua")

-- ------------------------------------------------------
-- the bpm of Katy Perry's Peacock
local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]

-- possible crossfade durations
local crossfades = {
   quarter_note   = (60/bpm),
   eighth_note    = (60/bpm) * 0.5,
   sixteenth_note = (60/bpm) * 0.25,
}

-- the crossfade duration I want to use for Katy Perry's Peacock
local xfade = crossfades.sixteenth_note

-- helper funcs
local WideScale, IsEditMode, GetPlayerAF, GenerateSprite = unpack(LoadActor("./helpers.lua"))

-- ------------------------------------------------------

local actors = {}
local cur_actor = 1

local function Update(af, dt)
   -- every frame, check if it's time to show the next piece of art in the slideshow
   if  (cur_actor <= #actors)                                -- are there still slides remaining, or have we reached the end of the slideshow?
   and (GAMESTATE:GetSongBeat() > art_pieces[cur_actor][1])  -- if the current beat (like 27.425) is greater than the beat specified in the art_pieces table for the next slide
   then
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

-- ------------------------------------------------------

local args = {}
args.InitCommand=function(self)
   self:SetUpdateFunction( Update )
end
args.OnCommand=function(self)
   local screen = SCREENMAN:GetTopScreen()
   local layers = screen:GetChildren()

   -- hide/fade-out UI in Gameplay so players can focus on the lovely art :)
   -- don't fade UI in Edit mode
   if not IsEditMode() then
      if layers.In then layers.In:visible(false) end

      for name,layer in pairs(layers) do
         -- we want to keep some layers visible
         if not (name=="SongBackground" or name=="SongForeground" or name=="PlayerP1" or name=="PlayerP2") then
            layer:smooth(1.5):diffusealpha(0)
         end
      end
   end

   -- specify a z-index of 1 for player notefields so they draw in front of the art
   local p1AF = GetPlayerAF("P1")
   local p2AF = GetPlayerAF("P2")
   if p1AF then p1AF:z(1) end
   if p2AF then p2AF:z(1) end

   self:queuecommand("SetDraw")
end
args.SetDrawCommand=function()
   SCREENMAN:GetTopScreen():SetDrawByZPosition(true)
end


-- dummy keep-alive actor, needed for mod-charts
args[#args+1] = Def.Actor({ InitCommand=function(self) self:sleep(999) end })


for _, piece in ipairs(art_pieces) do

   -- if the art is a lua file, pass it the WideScale function in case the Lua needs it,
   -- add the animation to the main ActorFrame here,
   -- and give the animation a common InitCommand, ShowCommand, and HideCommand
   if (piece[3]:match(".lua$")) then
      args[#args+1] = LoadActor("../art/"..piece[3], {WideScale})..{
         InitCommand=function(self)
            actors[#actors+1] = self
            self:visible(false)
         end,
         ShowCommand=function(self) self:visible(true) end,
         HideCommand=function(self) self:hibernate(math.huge) end
      }

   -- if the art is a [png, jpg, mp4, mov], add a Sprite to the main ActorFrame here
   else
      args[#args+1] = GenerateSprite(piece[3], actors)
   end
end

return Def.ActorFrame(args)