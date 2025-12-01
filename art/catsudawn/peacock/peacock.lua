local WideScale = unpack(...)
local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
local musicrate = 1/GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()

local af = Def.ActorFrame{}
local texture
local frame_dimension = 512


-- frames 0→6 are used to decorate the left half of the screen
-- frame 7 is the center piece
-- frames 8→13 don't exist as assets, but once the for-loop reaches
-- i > center_point, we can horizontally flip frames to decorate the
-- right half of the screen
local center_point = 7  -- last frame in the 4x2 set

for i=0,13 do
  af[#af+1] = Def.ActorFrame{
    Condition=(i ~= center_point),  -- skip bg-frame7 in this for-loop; it's handled by LoadActor() below

    OnCommand=function(self)
      -- animate each bg piece changing colors by diffuseshift-ing its parent AF
      self:diffuseshift()
          :effectoffset(i*(60/bpm)*musicrate)
          :effectclock("beat")
          :effectcolor1(color("#4573B1"))
          :effectcolor2(color("#E4FFCA"))
    end,

    Def.Sprite{
      OnCommand=function(self)
        self:SetTexture(texture)
        self:animate(false):setstate(i % center_point):SetTextureFiltering(false)
        self:y(_screen.cy)
        self:zoomtoheight(_screen.h + 64)
        self:zoomtowidth( frame_dimension * self:GetZoomedHeight()/frame_dimension )

        self:halign( i >= center_point and 0 or 1 )
        if (i >= center_point) then
          self:rotationy(180):x(_screen.w-6)
        else
          self:x(_screen.cx+80) -- fudging some numbers to make the assets work while animated
        end

        -- animate the bg pieces each growing/shrinking independently
        self:pulse()
        self:effectoffset(i*(60/bpm)*musicrate)
        self:effectclock('beat')
        self:effectmagnitude(1,1.025,0)
      end
    }
  }
end

-- middle piece of bg
af[#af+1] = Def.ActorFrame{
  ShowCommand=function(self)
    self:diffuseshift()
    self:effectoffset((60/bpm) * musicrate)
    self:effectclock("beat")
    self:effectcolor1(color("#4573B1"))
    self:effectcolor2(color("#8EC5CC"))
  end,


  LoadActor("./background 4x2.png")..{
    InitCommand=function(self)
      texture = self:GetTexture()

      self:animate(false):setstate(7):Center():SetTextureFiltering(true)
      self:zoomtoheight(_screen.h)
      self:zoomtowidth( frame_dimension * self:GetZoomedHeight()/frame_dimension )
    end,
    ShowCommand=function(self)
      self:pulse()
      self:effectoffset((60/bpm) * musicrate)
      self:effectclock('beat')
      self:effectmagnitude(1,1.025,0)
    end
  }
}

af[#af+1] = LoadActor("./peacock.png")..{
  InitCommand=function(self)
    self:SetTextureFiltering(false):Center():zoom(300)
  end,
  ShowCommand=function(self)
    local src_w = self:GetTexture():GetSourceWidth()
    self:smooth(0.4):zoom(0.375):queuecommand("Filter")
  end,
  FilterCommand=function(self)
    self:SetTextureFiltering(true)
  end
}

return af