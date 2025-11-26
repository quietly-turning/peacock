-- ------------------------------------------------------
-- the bpm of Katy Perry's Peacock
local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]


-- possible crossfade duration
local crossfades = {
   quarter_note   = (60/bpm),
   eighth_note    = (60/bpm) * 0.5,
   sixteenth_note = (60/bpm) * 0.25,
}

local xfade = crossfades.sixteenth_note

local WideScale, IsEditMode, GetPlayerAF, GenerateSprite = unpack(LoadActor("./helpers.lua"))

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
   { 132.00,    true,       "mrbrownjeremy/CyberPeacock.mp4" },
   { 140.000,   true,       "mrbrownjeremy/Peacuckoo2.mp4" },
   { 148.000,   true,       "Draner/archipelago-peacock.jpg" },
   { 156.000,   true,       "bogo/when they say theyve got that dawg in em.jpg" },
   { 164.000,   true,       "brandon/peacock.jpg" },
   { 172.000,   true,       "catsudawn/pavo-lisa.jpg" },
   { 180.000,   true,       "teejusb/peacock.png" },
   { 188.000,   true,       "placeholder.png" },  -- real bird
   { 196.000,   true,       "Chingching/peacock.jpg"},
   { 204.000,   true,       "placeholder.png" },
   { 212.000,   true,       "placeholder.png" },  -- hey guys
   { 228.000,   true,       "dbk2/oot.mp4"},
   { 248.000,   true,       "dbk2/fight/fight.lua" },
   { 260.000,   true,       "placeholder.png" },
   { 268.000,   true,       "mrbrownjeremy/Peacuckoo3.lua" },
   { 278.000,   true,       "placeholder.png"}
   -- { 278.000,   true,       "credits/credits.lua" },
}

-- ------------------------------------------------------

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
            -- we want to keep some layers visible
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

   -- if the art is a lua file, pass it the WideScale function in case the Lua needs it
   -- add the animation to the main ActorFrame here
   -- and give it a common OnCommand + HideCommand
   if (piece[3]:match(".lua$")) then
      args[#args+1] = LoadActor("../art/"..piece[3], {WideScale})..{
         InitCommand=function(self)
            actors[#actors+1] = self
            self:visible(false)
         end,
         ShowCommand=function(self) self:visible(true) end,
         HideCommand=function(self) self:hibernate(math.huge) end
      }

   -- if the art is a [png, jpg, mp4, mov]
   else
      args[#args+1] = GenerateSprite(piece[3], actors)
   end
end

return Def.ActorFrame(args)