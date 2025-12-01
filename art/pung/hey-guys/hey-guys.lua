local WideScale = unpack(...)
local af = Def.ActorFrame{}

local walking = true
local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
local musicrate = 1/GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()

local step_sleep_duration  = (60/bpm) * 0.5 * musicrate
local walk_time = step_sleep_duration*7.9
local text_reveal_duration = 0.3 * musicrate

af[#af+1] = Def.Quad{
  InitCommand=function(self) self:diffuse(0,0,0,1):FullScreen() end
}

af[#af+1] = LoadActor("grass.png")..{
  InitCommand=function(self)
    local texture = self:GetTexture()
    local src_h   = texture:GetSourceHeight()
    local txt_h   = texture:GetTextureHeight()

    self:valign(1):xy(_screen.cx,_screen.h + 40):zoomtowidth(_screen.w)
    self:texcoordvelocity(WideScale(0.325, 0.24) * (1/musicrate), 0)
    self:customtexturerect(0,0,src_h/txt_h,src_h/txt_h)
  end,
  DoneWalkingCommand=function(self)
    self:texcoordvelocity(0,0)
  end
}

af[#af+1] = LoadActor("./long-legged-fellow.png")..{
  InitCommand=function(self)
    local texture = self:GetTexture()
    local src_w   = texture:GetSourceWidth()
    local zoom = 0.3
    self:rotationy(180):zoom(zoom):valign(1):xy((src_w*zoom)*zoom, _screen.h - 30)
    self:queuecommand("StepLeft")
  end,
  StepLeftCommand=function(self)
    if walking then
      self:sleep(step_sleep_duration):rotationz(6):queuecommand("StepRight")
    end
  end,
  StepRightCommand=function(self)
    if walking then
      self:sleep(step_sleep_duration):rotationz(-6):queuecommand("StepLeft")
    end
  end,
  DoneWalkingCommand=function(self)
    self:finishtweening():rotationz(0)
  end
}

-- a long-legged fellow's speech bubble AF
af[#af+1] = Def.ActorFrame{
  Name="LLF-speech-bubble-AF",
  InitCommand=function(self) self:visible(false):zoom(0):xy(200,180) end,
  DoneWalkingCommand=function(self) self:visible(true):sleep(0.3*musicrate):bounceend(0.3*musicrate):zoom(0.275) end,

  LoadActor("./speech-bubbles 1x2.png")..{
    Name="LLF-speech-bubble",
    InitCommand=function(self) self:animate(false):setstate(0) end,
  },
  LoadActor("./dialogue 1x4.png")..{
    Name="LLF-text",
    InitCommand=function(self)
      self:animate(false):setstate(1):cropright(1):y(-20)
    end,
    DoneWalkingCommand=function(self)
      self:sleep(0.6*musicrate):linear(text_reveal_duration):cropright(0):sleep(1.25*musicrate):queuecommand("NextText")
    end,
    NextTextCommand=function(self)
      self:cropright(1):setstate(2):sleep(0.1*musicrate):linear(text_reveal_duration):cropright(0)
    end,
  }
}


-- a little stinker and a cat
af[#af+1] = Def.ActorFrame{
  InitCommand=function(self) self:x(400) end,
  ShowCommand=function(self) self:linear(walk_time):x(-100):queuecommand("StopWalking") end,
  StopWalkingCommand=function(self)
    walking = false
    self:GetParent():queuecommand("DoneWalking")
  end,

  -- a little stinker
  LoadActor("./im really good at drawing guys you just want to punch in the face - little stinkers if you will.png")..{
    InitCommand=function(self)
        self:zoom(0.35):valign(1):xy(_screen.w , _screen.h - 110)
    end
  },

  -- a cat
  LoadActor("../../Lane/cat.png")..{
    InitCommand=function(self)
        self:zoom(0.275):valign(1):xy(_screen.w-150, _screen.h)
    end
  },

  -- cat's speech bubble AF
  Def.ActorFrame{
    Name="cat-speech-bubble-AF",
    InitCommand=function(self)
      self:visible(false):zoom(0.35):xy(_screen.w-220,_screen.h-135)
    end,
    DoneWalkingCommand=function(self)
      self:sleep(1.333*musicrate):queuecommand("Reveal")
    end,
    RevealCommand=function(self) self:visible(true) end,

    -- cat's speech-bubble
    Def.Sprite{
      Name="cat-speech-bubble",
      OnCommand=function(self)
        self:SetTexture( self:GetParent():GetParent():GetParent():GetChild("LLF-speech-bubble-AF"):GetChild("LLF-speech-bubble"):GetTexture() )
        self:animate(false):setstate(1):rotationy(180)
      end,
    },

    -- cat's text
    Def.Sprite{
      Name="cat-text",
      OnCommand=function(self)
        self:SetTexture(self:GetParent():GetParent():GetParent():GetChild("LLF-speech-bubble-AF"):GetChild("LLF-text"):GetTexture())
        self:animate(false):setstate(0):cropright(1):xy(-10,-25):zoom(0.9)
      end,
      DoneWalkingCommand=function(self) self:sleep(0.8*musicrate):linear(text_reveal_duration):cropright(0) end,
    }
  }
}


-- ceiling peacock
af[#af+1] = Def.ActorFrame{
  InitCommand=function(self) self:visible(false):rotationz(180):xy(_screen.cx+100, -300):zoom(0.25) end,
  DoneWalkingCommand=function(self) self:visible(true):sleep(2.5*musicrate):decelerate(1*musicrate):y(100) end,

  LoadActor("../../Lane/peacock.png")..{
    InitCommand=function(self) self:rotationy(180) end,
  },

  Def.ActorFrame{
    InitCommand=function(self) self:xy(400, -400) end,

    -- speech-bubble
    Def.Sprite{
      OnCommand=function(self)
        self:SetTexture(self:GetParent():GetParent():GetParent():GetChild("LLF-speech-bubble-AF"):GetChild("LLF-speech-bubble"):GetTexture())
        self:animate(false):setstate(0)
      end,
    },
    -- text
    Def.Sprite{
      OnCommand=function(self)
        self:SetTexture(self:GetParent():GetParent():GetParent():GetChild("LLF-speech-bubble-AF"):GetChild("LLF-text"):GetTexture())
        self:animate(false):setstate(3):rotationz(-180):y(-10)
      end,
    }
  }
}

return af