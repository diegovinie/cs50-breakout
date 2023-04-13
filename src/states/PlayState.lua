--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    -- self.ball = params.ball
    self.balls = { params.ball }
    self.level = params.level
    self.powerups = {}

    self.recoverPoints = 5000

    self.scoreBaseline = 0

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = -math.random(50, 60)

    self.hasLockedBricks = false
    self.timer = 0

    for _, brick in pairs(self.bricks) do
        if brick.locked then
            self.hasLockedBricks = true
        end
    end
end

function PlayState:update(dt)
    if self.hasLockedBricks and not self.paddle.hasKey then
        self.timer = self.timer + dt
        if self.timer >= KEY_SPAWN_DELAY then
            table.insert(self.powerups, Powerup('key', math.random(16, VIRTUAL_WIDTH - 16), 8))

            self.timer = self.timer % KEY_SPAWN_DELAY
        end
    end

    if self.paused then
        if gControl:pressed('buttonA') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif gControl:pressed('buttonA') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for _, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for i, powerup in ipairs(self.powerups) do
        if powerup.inPlay and powerup:collides(self.paddle) then
            powerup.inPlay = false
            powerup:getReward(self)
        end
    end

    for _, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

                -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                if self.paddle.hasKey then
                    brick.locked = false
                end
                if not brick.locked then
                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    if brick.tier == 0 and brick.color == 1 then
                        if brick.hasKey then
                            brick.hasKey = false
                            table.insert(self.powerups, Powerup('key', brick.x, brick.y))
                        elseif self:checkScoreReward(self.score) then
                            table.insert(self.powerups, Powerup(Powerup.getRandomType(), brick.x, brick.y))
                        end
                    end

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = ball,
                            recoverPoints = self.recoverPoints
                        })
                    end
                end

                self:performBouncing(brick, ball)

                -- only allow colliding with one brick, for corners
                break
            end
        end

    end

    -- if ball goes below bounds, revert to serve state and decrease health
    if not self:checkBallsInPlay() then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    for ii, powerup in ipairs(self.powerups) do
        powerup:update(dt)
    end


    if gControl:pressed('quit') then
        love.event.quit()
    end
end

function PlayState:performBouncing(brick, ball)
    --
    -- collision code for bricks
    --
    -- we check to see if the opposite side of our velocity is outside of the brick;
    -- if it is, we trigger a collision on that side. else we're within the X + width of
    -- the brick and should check to see if the top or bottom edge is outside of the brick,
    -- colliding on the top or bottom accordingly
    --

    -- left edge; only check if we're moving right, and offset the check by a couple of pixels
    -- so that flush corner hits register as Y flips, not X flips
    if ball.x + 2 < brick.x and ball.dx > 0 then

        -- flip x velocity and reset position outside of brick
        ball.dx = -ball.dx
        ball.x = brick.x - 8

        -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
        -- so that flush corner hits register as Y flips, not X flips
    elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

        -- flip x velocity and reset position outside of brick
        ball.dx = -ball.dx
        ball.x = brick.x + 32

        -- top edge if no X collisions, always check
    elseif ball.y < brick.y then

        -- flip y velocity and reset position outside of brick
        ball.dy = -ball.dy
        ball.y = brick.y - 8

        -- bottom edge if no X collisions or top collision, last possibility
    else

        -- flip y velocity and reset position outside of brick
        ball.dy = -ball.dy
        ball.y = brick.y + 16
    end

    -- slightly scale the y velocity to speed up the game, capping at +- 150
    if math.abs(ball.dy) < 150 then
        ball.dy = ball.dy * 1.02
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    self.paddle:render()

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

function PlayState:spawnBalls(n)
    local ball

    for i = 1, n do
        ball = Ball(math.random(7))
        ball.x = self.paddle.x + self.paddle.width / 2
        ball.y = self.paddle.y - 16
        ball.dx = math.random(-100, 100)
        ball.dy = -math.random(50, 60)

        table.insert(self.balls, ball)
    end
end

function PlayState:checkBallsInPlay()
    local inPlay = false

    for _, ball in pairs(self.balls) do
        if ball.inPlay then
            if ball.y < VIRTUAL_HEIGHT then
                inPlay = true
            else
                ball.inPlay = false
            end
        end
    end
    return inPlay
end

function PlayState:checkScoreReward(score)
    if self.score >= self.scoreBaseline + SCORE_REWARD_STEP then
        self.scoreBaseline = self.score - self.score % SCORE_REWARD_STEP

        return true
    end

    return false
end
