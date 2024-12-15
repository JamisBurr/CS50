-- ==========================================
-- TALKIES LIBRARY FILE
-- Purpose: Handles NPC dialogues for the game.
-- ==========================================

--  HEADER & LIBRARY INITIALIZATION
local Talkies = require("libraries/talkies")
local Npc = {}

--  GLOBAL VARIABLES & ASSETS
local avatar
local blop
local dialougeExhausted = false

-- Define a global variable for talk sound volume
local talkSoundVolume = 0.2  -- 50% volume

function TalkiesLoad()
    Talkies.font = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", 32)
    Talkies.font:setFallbacks(love.graphics.newFont("assets/fonts/JPfallback.ttf", 32)) -- Add font fallbacks for Japanese characters

    -- Initialize and set volume for talk sound
    Talkies.talkSound = love.audio.newSource("assets/sfx/typeSound.wav", "static")
    Talkies.talkSound:setVolume(talkSoundVolume)

    -- Initialize and set volume for option selection sound
    Talkies.optionOnSelectSound = love.audio.newSource("assets/sfx/optionSelect.wav", "static")
    Talkies.optionOnSelectSound:setVolume(talkSoundVolume)

    -- Initialize and set volume for option switching sound
    Talkies.optionSwitchSound = love.audio.newSource("assets/sfx/optionSwitch.wav", "static")
    Talkies.optionSwitchSound:setVolume(talkSoundVolume)

    math.randomseed(os.time())
end

--  Utility Functions
function shopChatSettings()
  return {
      image = bloodshop,
      talkSound = blop,
      titleColor = {1, 1, 0}
  }
end

-- -------------------------
--  NPC 1: Shop Owner
-- -------------------------
-- Question dialogues for the shop owner
function Npc.shopQuestion()
  Talkies.say(
    "Shop Owner",
    "Kieran! Where have you been?", 
    {
      options = {
        {"Hiding", function() shopReply1() end},
        {"Training", function() shopReply2() end},
        {"Drinking", function() shopReply3() end}
      },
      -- ... any other specific settings ...
      image = shopChatSettings().image,
      talkSound = shopChatSettings().talkSound,
      titleColor = shopChatSettings().titleColor
    }
  )        
end

-- Response for the first option
function shopReply1()
  Talkies.say(
    "Shop Owner", 
    "I can't believe it...",
    {
      image = shopChatSettings().image,
      talkSound = shopChatSettings().talkSound,
      titleColor = shopChatSettings().titleColor
    }
  )
  Npc.shopGoodbye()  
end

 -- Response for the second option
 function shopReply2()
  Talkies.say(
    "Shop Owner", 
    "Have you grown strong enough to dethrone your brother?",
    {
      image = shopChatSettings().image,
      talkSound = shopChatSettings().talkSound,
      titleColor = shopChatSettings().titleColor
    }
  )
  Npc.shopGoodbye()  
end

 -- Response for the third option
 function shopReply3()
  Talkies.say(
    "Shop Owner", 
    "I am not surprised...",
    {
      image = shopChatSettings().image,
      talkSound = shopChatSettings().talkSound,
      titleColor = shopChatSettings().titleColor
    }
  )
  Npc.shopGoodbye()  
end

 -- Farewell dialogues for the shop owner
function Npc.shopGoodbye()
  Talkies.say(
    "Shop Owner", 
    "Here, take the royal family sword, CRIMSONCLAW." ..
    "\nI have been keeping it safe since you vanished." ..
    "\nBest of luck, my prince!", 
    {
      typedNotTalked=false,
      oncomplete=function() 
        acquiredSword()
        swordGameStart()
      end,      
      image = shopChatSettings().image,
      talkSound = shopChatSettings().talkSound,
      titleColor = shopChatSettings().titleColor,      
    }
  )
  Npc.playerSword()
end

-- -------------------------
--  NPC 2: Statue
-- -------------------------
-- Dialogues for the statue
function Npc.statueHello()
  Talkies.say(
    "Kieran", "See ya around!", {
      image=avatar,
      talkSound=blop,
      typedNotTalked=false,
      oncomplete=function() rand() end,
      titleColor = {1, 0, 0},      
    })          
end

-- -------------------------
--  NPC 3: Watcher
-- -------------------------
-- Dialogues for the watcher
function Npc.watcherHello(watcher)  
    local dialogue = ""
    local onCompleteAction

    -- select dialogue based on watcherID
    if watcher.id == "key" then
        dialogue =  "Seeker of the tower's peak," ..
                    "\nThe first step is not for the weak." ..
                    "\nFor barriers stand in your quest," ..
                    "\nThis key will put them to rest."
        onCompleteAction = function()
          acquiredKey()
          keyGameStart()
          Npc.playerKey()
          wDialogueExhausted(watcher)
        end
        
    elseif watcher.id == "dash" then    
        dialogue =  "You've proven your will, brave traveler," ..
                    "\nBut speed is a trait you're yet to master." ..
                    "\nTo cross gaps and evade a foe," ..
                    "\nA burst of speed is what you need to know."
        onCompleteAction = function()
          acquiredDash()    
          dashGameStart()  
          Npc.playerDash()
          wDialogueExhausted(watcher)    
        end
          
    elseif watcher.id == "teleport" then    
        dialogue =  "Journeyer of the winding stair," ..
                    "\nSometimes the path isn't always clear." ..
                    "\nTo leap through space and skip the fray," ..
                    "\nThis power I grant you today."
        onCompleteAction = function()
          acquiredTeleport() 
          teleportGameStart()
          Npc.playerTeleport()
          wDialogueExhausted(watcher)          
        end   

    elseif watcher.id == "deflect" then    
        dialogue =  "In the tower's climb, danger is rife," ..
                    "\nAnd not all threats can be dodged with life." ..
                    "\nTo stand your ground and face the storm," ..
                    "\nThis shield of time will keep you warm."
        onCompleteAction = function()          
          acquiredDeflect()     
          deflectGameStart()
          Npc.playerDeflect()
          wDialogueExhausted(watcher)   
        end

    elseif watcher.id == "dash2" then    
      dialogue =  "Speed once granted, now enhanced anew," ..
                  "\nThe wind's fury, channeled through you." ..
                  "\nDash farther, faster, break through the haze," ..
                  "\nAnd reach the tower's pinnacle in a blaze."
      onCompleteAction = function()
        acquiredDash2()    
        dash2GameStart()
        Npc.playerDash2()
        wDialogueExhausted(watcher)      
      end
        
    elseif watcher.id == "djump" then    
      dialogue =  "Soaring seeker, climbing high," ..
                  "\nTo reach the stars, you must touch the sky." ..
                  "\nLeap once, then leap again," ..
                  "\nWith this aerial grace, you shall ascend."
      onCompleteAction = function()          
        acquiredDJump()     
        djumpGameStart()
        Npc.playerDJump()
        wDialogueExhausted(watcher)
      end    
        
    else
        dialogue = "The Watchers are always watching..."
        onCompleteAction = function()
        end
        
    end

    Talkies.say(
      "Watcher", 
      dialogue, 
      {
          image=avatar,
          talkSound=blop,
          typedNotTalked=false,
          textSpeed="slow",
          oncomplete=onCompleteAction,   
          titleColor = shopChatSettings().titleColor,      
      })          
end

function Npc.playerSword()
  if keyboard then
    Talkies.say(
      "", 
      "You obtained CRIMSONCLAW." ..
      "\nPress 'C' to use the weapon.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  elseif controller then
    Talkies.say(
      "", 
      "You obtained CRIMSONCLAW." ..
      "\nPress 'R1' to use the weapon.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  end
end

function Npc.playerKey()
  if keyboard then
    Talkies.say(
      "", 
      "You obtained the CRIMSON KEY." ..
      "\nPress 'E' to activate gate switches.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  elseif controller then
    Talkies.say(
      "", 
      "You obtained the CRIMSON KEY." ..
      "\nPress 'Y' to activate gate switches.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  end
end

function Npc.playerDash()
  if keyboard then
    Talkies.say(
      "", 
      "You obtained CRIMSON CHARGE." ..
      "\nPress 'R' to perform a swift maneuver forwards.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  elseif controller then
    Talkies.say(
      "", 
      "You obtained CRIMSON CHARGE." ..
      "\nPress 'X' to perform a swift maneuver forwards.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  end
end

function Npc.playerTeleport()
  if keyboard then
    Talkies.say(
      "", 
      "You obtained CRIMSON CONDUIT." ..
      "\nPress 'F' to transverse a CRIMSON CONDUIT.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  elseif controller then
    Talkies.say(
      "", 
      "You obtained CRIMSON CONDUIT." ..
      "\nPress 'Y' to transverse a CRIMSON CONDUIT.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  end
end

function Npc.playerDeflect()
  if keyboard then
    Talkies.say(
      "", 
      "You obtained CRIMSON COUNTER" ..
      "\nPress 'Q' to perform a quick parry with your sword. Successful timing will prevent damage.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  elseif controller then
    Talkies.say(
      "", 
      "You obtained CRIMSON COUNTER" ..
      "\nPress 'B' to perform a quick parry with your sword. Successful timing will prevent damage.", 
      {
        typedNotTalked=false,     
        image = shopChatSettings().image,
        talkSound = shopChatSettings().talkSound,
        titleColor = shopChatSettings().titleColor,      
      }
    )
  end
end

function Npc.playerDash2()
  Talkies.say(
    "", 
    "You obtained CRIMSON CASCADE" ..
    "\nYou feel your speed increase.  You can now run faster, dash further, and jump higher.", 
    {
      typedNotTalked=false,     
      image = shopChatSettings().image,
      talkSound = shopChatSettings().talkSound,
      titleColor = shopChatSettings().titleColor,      
    }
  )
end

function Npc.playerDJump()
  if keyboard then
      Talkies.say(
        "", 
        "You obtained CRIMSON CREST" ..
        "\nPress 'SPACE' twice for a momentary glide, enhancing your reach and agility.", 
        {
          typedNotTalked=false,     
          image = shopChatSettings().image,
          talkSound = shopChatSettings().talkSound,
          titleColor = shopChatSettings().titleColor,      
        }
      )
  elseif controller then
    Talkies.say(
        "", 
        "You obtained CRIMSON CREST" ..
        "\nPress 'A' twice for a momentary glide, enhancing your reach and agility.", 
        {
          typedNotTalked=false,     
          image = shopChatSettings().image,
          talkSound = shopChatSettings().talkSound,
          titleColor = shopChatSettings().titleColor,      
        }
      )
    end
end

--  General Functions
function love.keypressed(key) 
  if key == "return" then Talkies.onAction()
  elseif key == "up" then Talkies.prevOption()
  elseif key == "down" then Talkies.nextOption()
  end
end

function love.gamepadpressed(joystick, button)
  if button == "y" then  -- Assuming 'a' is the action/confirm button on your gamepad
      Talkies.onAction()
  elseif button == "dpup" then  -- Assuming 'dpup' is the D-pad up on your gamepad
      Talkies.prevOption()
  elseif button == "dpdown" then  -- Assuming 'dpdown' is the D-pad down on your gamepad
      Talkies.nextOption()
  end
end

-- Template Functions
-- Here's a template for how to use the main functions:
function moreMessages()
  Talkies.say(
    "Shop Owner",
    "Wow, I can't beleive it!",
    {
      onstart=function() end
    }
  )    
  Npc.shopGoodbye()    
end

return Npc