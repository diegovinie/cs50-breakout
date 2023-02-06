


Powerup = Class{}

function Powerup:init(type, x, y)
    self.type = type
    self.x = x
    self.y = y
    self.width = 16
    self.height = 16
    self.inPlay = true
end

function Powerup:collides(target)
    if self.x + self.width < target.x or self.x > target.x + target.width then
        return false
    end

    if self.y + self. height < target.y or self.y > target.y + target.height then
        return false
    end

    return true
end

function Powerup:getReward(game)
    if self.type == 'heart' then
        game.health = math.min(3, game.health + 1)
    elseif self.type == 'grow' then
        game.paddle.size = math.min(4, game.paddle.size + 1)
    elseif self.type == 'shrink' then
        game.paddle.size = math.max(2, game.paddle.size - 1)
    elseif self.type == 'key' then
        game.paddle.hasKey = true
    elseif self.type == 'multiple' then
        game:spawnBalls(2)
    else
        print('type ' .. self.type .. ' not recognized')
    end
end

function Powerup:update(dt)
    self.dx = 0
    self.dy = 20

    if not self.inPlay then return end

    if self.y > VIRTUAL_HEIGHT then self.inPlay = false end

    self.x = self.x + dt * self.dx
    self.y = self.y + dt * self.dy
end

function Powerup:render()
    if self.inPlay then
        love.graphics.draw(gTextures.main, gFrames.powerups[self.type], self.x, self.y);
    end
end

Powerup.typeFreq = {
    ['heart'] = 1,
    ['multiple'] = 3,
    ['grow'] = 2,
    ['shrink'] = 1
}

-- Return a random Powerup type based on the frequency described in Powerup.typeFreq
function Powerup.getRandomType()
    local options = {}

    for type, freq in pairs(Powerup.typeFreq) do
        for i = 1, freq do
            table.insert(options, type)
        end
    end

    local index = math.random(#options)

    return options[index]
end
