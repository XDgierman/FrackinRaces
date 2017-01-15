require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
    local bounds = mcontroller.boundBox()
    -- regen default
    self.healingRate = 1.01 / config.getParameter("healTime", 320)
    --food defaults
    hungerMax = { pcall(status.resourceMax, "food") }
    hungerMax = hungerMax[1] and hungerMax[2]
    hungerLevel = status.resource("food")
    baseValue = config.getParameter("healthDown",0)*(status.resourceMax("food"))
    self.tickTime = 1.0
    self.tickTimePenalty = 5.0
    self.tickTimer = self.tickTime 
    self.tickTimerPenalty = self.tickTimePenalty
    script.setUpdateDelta(5)    
end

function getLight()
  local position = mcontroller.position()
  position[1] = math.floor(position[1])
  position[2] = math.floor(position[2])
  local lightLevel = world.lightLevel(position)
  lightLevel = math.floor(lightLevel * 100)
  return lightLevel
end


function daytimeCheck()
	return world.timeOfDay() < 0.5 -- true if daytime
end

function undergroundCheck()
	return world.underground(mcontroller.position()) 
end



  
function update(dt)
  daytime = daytimeCheck()
  underground = undergroundCheck()
  local lightLevel = getLight()

    --food defaults
    hungerMax = { pcall(status.resourceMax, "food") }
    hungerMax = hungerMax[1] and hungerMax[2]
    hungerLevel = status.resource("food")
    baseValue = config.getParameter("healthDown",0)*(status.resourceMax("food"))
    self.tickTimer = self.tickTimer - dt
    self.tickTimerPenalty = self.tickTimerPenalty - dt
    
	-- Night penalties
	  if not daytime then  -- Florans lose HP and Energy when the sun is not out
	
		status.setPersistentEffects("nightpenalty", { 
		{stat = "maxHealth", baseMultiplier = 0.90 },
		{stat = "maxEnergy", baseMultiplier = 0.75 }
		}) 
	       -- when the sun is out, florans lose food
	         if (hungerLevel < hungerMax) and ( self.tickTimerPenalty <= 0 ) then
	           self.tickTimerPenalty = self.tickTimePenalty
		   adjustedHunger = hungerLevel - (hungerLevel * 0.005)
		   status.setResource("food", adjustedHunger)
	         end
	  end

        -- gain energy when well fed
		  if hungerLevel > 95 then
		    status.setPersistentEffects("starvationpower", {{stat = "maxEnergy", baseMultiplier = 1.25}})
		  elseif hungerLevel < 90 then
		    status.setPersistentEffects("starvationpower", {{stat = "maxEnergy", baseMultiplier = 1.20}})
		  elseif hungerLevel < 80 then
		    status.setPersistentEffects("starvationpower", {{stat = "maxEnergy", baseMultiplier = 1.15}}) 
		  elseif hungerLevel < 70 then
		    status.setPersistentEffects("starvationpower", {{stat = "maxEnergy", baseMultiplier = 1.10}})  
		  elseif hungerLevel < 60 then
		    status.setPersistentEffects("starvationpower", {{stat = "maxEnergy", baseMultiplier = 1.05}})      
		  else
		    status.clearPersistentEffects("starvationpower")
		  end	
		  
	-- Daytime Abilities
	if daytime then
	  -- when the sun is out, florans regenerate food    
	       if (hungerLevel < hungerMax) and ( self.tickTimer <= 0 ) then
	         self.tickTimer = self.tickTime
		 adjustedHunger = hungerLevel + (hungerLevel * 0.01)
		 status.setResource("food", adjustedHunger)
	       end		
	   -- When it is sunny and they are well fed, florans regenerate
	  if hungerLevel >= 50  then 
	    if underground and lightLevel < 60 then -- we cant do it well underground
		   self.healingRate = 0
		   status.modifyResourcePercentage("health", self.healingRate * dt)  
	    elseif underground and lightLevel > 60 then -- we cant do it well underground
		   self.healingRate = 1.00005 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 95 then
		   self.healingRate = 1.0009 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 90 then
		   self.healingRate = 1.0008 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 80 then
		   self.healingRate = 1.00075 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 70 then
		   self.healingRate = 1.0007 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 65 then
		   self.healingRate = 1.0006 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 55 then
		   self.healingRate = 1.0005 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 45 then
		   self.healingRate = 1.0003 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 35 then
		   self.healingRate = 1.0002 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    elseif lightLevel > 25 then
		   self.healingRate = 1.0001 / config.getParameter("healTime", 320)
		   status.modifyResourcePercentage("health", self.healingRate * dt)
	    end  
	  end
	  
	  
	  
	  

  
	end



end

function uninit()
  status.clearPersistentEffects("starvationpower")
  status.clearPersistentEffects("nightpenalty")
end






