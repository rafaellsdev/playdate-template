-- Player related code
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd = playdate
local gfx = pd.graphics

local playerStartX = 40
local playerStartY = 120
local playerSpeed = 3
local playerImage = gfx.image.new("images/capybara")
local playerSprite = gfx.sprite.new(playerImage)
playerSprite:setCollideRect(4, 4, 56, 40)
playerSprite:moveTo(playerStartX, playerStartY)
playerSprite:add()

local lastScore = 0
local highScore = playdate.datastore.read("highscore") or 0

local score = 0

-- Game state management
local gameState = "stopped"

-- Obstacle related code
local obstacleSpeed = 5
local obstacleImage = gfx.image.new("images/rock")
local obstacleSprite = gfx.sprite.new(obstacleImage)
obstacleSprite:setCollideRect(0, 0, 48, 48)
obstacleSprite:moveTo(450, 240)
obstacleSprite:add()

function pd.update()
    gfx.sprite.update()

    if gameState == "stopped" then
        if lastScore > highScore then
            highScore = lastScore
            playdate.datastore.write(highScore, "highscore")
            gfx.drawTextAligned("New High Score!", 200, 80, kTextAlignment.center)
        end
        gfx.drawTextAligned("Press A to start", 200, 40, kTextAlignment.center)
        gfx.drawText("Last Score: " .. lastScore, 200, 120)
        gfx.drawText("High Score: " .. highScore, 200, 160)

        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "active"
            score = 0
            playerSprite:moveTo(playerStartX, playerStartY)
            obstacleSprite:moveTo(450, math.random(40, 200))
            obstacleSpeed = 5
        end
    elseif gameState == "active" then
        local crankPosition = pd.getCrankPosition()
        if crankPosition <= 90 or crankPosition >= 270 then
            playerSprite:moveBy(0, -playerSpeed)
        else
            playerSprite:moveBy(0, playerSpeed)
        end

        obstacleSprite:moveBy(-(obstacleSpeed + score / 5), 0)
        if obstacleSprite.x < -40 then
            obstacleSprite:moveTo(450, math.random(40, 200))
            score += 1
        end

        if playerSprite.y > 270 or playerSprite.y < -30 or #playerSprite:overlappingSprites() > 0 then
            lastScore = score
            gameState = "stopped"
        end

        gfx.drawText("Score: " .. score, 10, 10)
    end
end
