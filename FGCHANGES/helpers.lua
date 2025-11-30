-- ------------------------------------------------------
-- a customized version of the WideScale() helper function provided by SM5's _fallback theme
-- pass this 2 numbers and it will return 1 number
-- AR4_3:  the number to return if the screen aspect ratio is 4:3
-- AR16_9  the number to return if the screen aspect ratio is 16:9
-- the screen aspect ratio is in-between (e.g. 16:10), scale the number returned to be appropriately in-between
-- for an example use, see START_ZOOM in i-wanna-see-your-peacock.lua
local function WideScale(AR4_3, AR16_9)
   local w = 480 * PREFSMAN:GetPreference("DisplayAspectRatio")
   local scaled_num  = scale( w, 640, 854, AR4_3, AR16_9 )
   local low  =  math.min(AR4_3, AR16_9)
   local high =  math.max(AR4_3, AR16_9)
   local clamped_num = clamp(scaled_num, low, high)
   return clamped_num
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

-- music rate chosen by the player(s)
local musicrate = GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()

local function GenerateSprite(path, actors)

   local sprite = LoadActor( ("../art/%s"):format(path) )

   sprite.InitCommand=function(self)
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

return {WideScale, IsEditMode, GetPlayerAF, GenerateSprite}