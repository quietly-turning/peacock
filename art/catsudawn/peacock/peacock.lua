local WideScale = unpack(...)

local af = Def.ActorFrame{}
af.ShowCommand=function(self) self:visible(true) end
af.HideCommand=function(self) self:hibernate(math.huge) end


for i=1,15 do
  af[#af+1] = Def.ActorFrame{
    OnCommand=function(self)
      self:glowshift()
          :effectoffset((i%4)*(60/140))
          :effectcolor1({0,0,0,0})
          :effectcolor2({0,0,1,0.333})
    end,
    LoadActor(("./%d.png"):format(i))..{
      InitCommand=function(self)
        self:scaletocover(0,0,SCREEN_WIDTH, SCREEN_HEIGHT)
      end,
      OnCommand=function(self)
        self:pulse():effectoffset((i%4)*(60/140))
            :effectmagnitude(1,1.025,0)
            :effectclock('beatnooffset')
      end
    }
  }
end

af[#af+1] = LoadActor("./peacock.png")..{
  InitCommand=function(self)
    self:Center():zoom(0)
  end,
  OnCommand=function(self)
    local src_w = self:GetTexture():GetSourceWidth()
    self:bounceend(0.2):zoom(_screen.w/WideScale(src_w*0.75,src_w))
  end,
}

return af