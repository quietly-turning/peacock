
local zoomVal = 0.45
local beginTime = 0.25
local enterTime = 0.5
local battleDelayTime = 0.7
local battleWindTime = 0.1
local battleAttackTime = 0.3
local battleLagTime = 0.2
local pauseTime = battleDelayTime + battleWindTime + battleAttackTime + battleLagTime
local flyTime = 0.2

----------------------------------------------------------------------------

local actor = Def.ActorFrame{
	InitCommand=function(self) self:visible(false) end,
	AnimateCommand=function(self) self:sleep(beginTime):queuecommand("Reveal") end,
	RevealCommand=function(self) self:visible(true) end
}



actor[#actor+1] = LoadActor("./peacock face left.png")..{
	AnimateCommand=function(self)
		self:zoom(zoomVal):visible(1):CenterY():x(_screen.w*1.1)
		self:sleep(beginTime):linear(enterTime):x(_screen.w*0.6)
		self:sleep(battleDelayTime):decelerate(battleWindTime):x(_screen.w*0.62):addrotationz(-30):decelerate(battleAttackTime):x(_screen.w*0.54):addrotationz(30)
		self:sleep(battleLagTime):linear(.2):x(_screen.w*1.1):y(_screen.h*0.35):addrotationz(-60)
	end
}
actor[#actor+1] = LoadActor("./peacock face right.png")..{
	AnimateCommand=function(self)
		self:zoom(zoomVal):visible(1):CenterY():x(-_screen.w*.1)
		self:sleep(beginTime):linear(enterTime):x(_screen.w*0.4)
		self:sleep(battleDelayTime):decelerate(battleWindTime):x(_screen.w*0.38):addrotationz(30):decelerate(battleAttackTime):x(_screen.w*0.46):addrotationz(-30)
		self:sleep(battleLagTime):linear(flyTime):x(-_screen.w*.1):y(_screen.h*0.35):addrotationz(60)
	end
}
actor[#actor+1] = LoadActor("./lvl 1.png")..{
	AnimateCommand=function(self)
		self:zoom(zoomVal):visible(1):y(_screen.h*0.4):x(_screen.w*1.1)
		self:sleep(beginTime):linear(enterTime):x(_screen.w*0.63)
		self:sleep(pauseTime):linear(flyTime):x(_screen.w*1.1):y(_screen.h*0.25)
	end
}
actor[#actor+1] = LoadActor("./lvl 1.png")..{
    AnimateCommand=function(self)
		self:zoom(zoomVal):visible(1):y(_screen.h*0.4):x(-_screen.w*.1)
		self:sleep(beginTime):linear(enterTime):x(_screen.w*0.37)
		self:sleep(pauseTime):linear(flyTime):x(-_screen.w*.1):y(_screen.h*0.25)
	end
}
actor[#actor+1] = LoadActor("./stats.png")..{
	AnimateCommand=function(self)
		self:zoom(zoomVal):visible(1):y(_screen.h*0.6):x(_screen.w*1.1)
		self:sleep(beginTime):linear(enterTime):x(_screen.w*0.63)
		self:sleep(pauseTime):linear(flyTime):x(_screen.w*1.1):y(_screen.h*0.45)
	end
}
actor[#actor+1] = LoadActor("./stats.png")..{
	AnimateCommand=function(self)
		self:zoom(zoomVal):visible(1):y(_screen.h*0.6):x(-_screen.w*.1)
		self:sleep(beginTime):linear(enterTime):x(_screen.w*0.4)
		self:sleep(pauseTime):linear(flyTime):x(-_screen.w*.1):y(_screen.h*0.45)
	end
}

return actor