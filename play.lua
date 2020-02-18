local play = {
    assets = {
        player_tank = love.graphics.newImage("player_tank.png"),
        player_shell = love.graphics.newImage("player_shell.png"),
        shell = love.audio.newSource("fire.wav", "static"),
        explosion = love.audio.newSource("explosion.wav", "static"),
        bullet = love.graphics.newImage("bullet.png")
    },
    player = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
        degree = 0,
        sx = 0.7,
        sy = 0.7,
        speed = 80
    },
    shells = {},
    shell_timer = 0,
    enemies = {},
    spawn_timer = 0,
    enemy_number = 5,
    explosion_timer = 0,
    bullets = {},
    bullet_timer = 0,
    sound = true,
    difficulty = 2,    
    counter = 0,
    score = 0
}

function play:toggle_sound()
    self.sound = not self.sound
    return self.sound
end

function play:toggle_difficulty()
    self.difficulty = self.difficulty + 1
    if self.difficulty > 3 then
        self.difficulty = 1
    end
    return self.difficulty
end

function play:entered()
    local window_width, window_height = love.graphics.getDimensions()
    self.player.width, self.player.height = self.assets.player_tank:getDimensions()
    
    self.player.x = (window_width - self.player.width) / 2
    self.player.y = (window_height - self.player.height) / 2

    self.shells = {}
    self.enemies = {}
    self.bullets = {}
    self.counter = 0
    self.score = 0
end


function play:draw()
    love.graphics.setBackgroundColor(0 / 255, 0 / 255, 0 / 255)
    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)

    -- Draw player
    love.graphics.draw(self.assets.player_tank, self.player.x, self.player.y, math.rad(self.player.degree),
        self.player.sx, self.player.sy, self.player.width / 2, self.player.height / 2)
    
    -- Draw player shell
    for i, shell in ipairs(self.shells) do
        love.graphics.draw(self.assets.player_shell, shell.x, shell.y, math.rad(shell.degree), 0.7, 0.7)
    end

    -- Draw enemy 
    for i, enemy in ipairs(self.enemies) do
        love.graphics.draw(enemy.tank, enemy.x, enemy.y, math.rad(enemy.degree),
            enemy.sx, enemy.sy, enemy.width / 2, enemy.height / 2)
    end
    
    -- Draw enemy bullet
    for i, bullet in ipairs(self.bullets) do
        love.graphics.draw(self.assets.bullet, bullet.x, bullet.y, math.rad(bullet.degree), 0.7, 0.7)            
    end

    -- Draw score
	love.graphics.setColor(4 /255, 169 / 255, 201 / 255)
	love.graphics.setFont(love.graphics.newFont(24))
	love.graphics.print("Score: " .. self.score, 800, 690)
end

function play:update(dt)
    local window_width, window_height = love.graphics.getDimensions()
    self.spawn_timer = self.spawn_timer + dt
    self.shell_timer = self.shell_timer + dt  
    self.bullet_timer = self.bullet_timer + dt

    -- player
    if love.keyboard.isDown("a", "left") and (self.player.x - self.player.width / 2) > 0 then
        self.player.x = self.player.x - self.player.speed * dt
        self.player.sy = - 0.7
        self.player.degree = 180
    elseif love.keyboard.isDown("w", "up") and (self.player.y  - self.player.height / 2)  > 0 then
        self.player.y = self.player.y - self.player.speed * dt
        self.player.sy = 0.7
        self.player.degree = 270 
    elseif love.keyboard.isDown("s", "down") and (self.player.y + self.player.height / 2) < window_height then
        self.player.y = self.player.y + self.player.speed * dt
        self.player.sy = 0.7
        self.player.degree = 90  
    elseif love.keyboard.isDown("d", "right") and (self.player.x + self.player.width / 2) < window_width then
        self.player.x = self.player.x + self.player.speed * dt
        self.player.sy = 0.7
        self.player.degree = 0
    end

    --player shell
    local shell = {
        x = self.player.x,
        y = self.player.y,
        degree = 0,
        speed = 150
    }
    
    if love.keyboard.isDown("return", "space") and self.shell_timer > 0.5 then
        
        if self.player.degree == 0 then
            shell.degree = 0
            shell.y = self.player.y - 24
        elseif self.player.degree == 90 then
            shell.degree = 90 
            shell.x = self.player.x + 24 
        elseif self.player.degree == 270 then
            shell.degree = 270 
            shell.x = self.player.x - 24
        elseif self.player.degree == 180  then
            shell.degree = 180 
            shell.y = self.player.y - 6 
        end  

        table.insert(self.shells, shell)

        if self.sound then
            self.assets.shell:stop()
            self.assets.shell:play()
        end        

        self.shell_timer = 0
    end

    -- player shell movement
    for i, shell in ipairs(self.shells) do
        if shell.degree == 0 then
            shell.x = shell.x + shell.speed * dt
        elseif shell.degree == 90 then
            shell.y = shell.y + shell.speed * dt
        elseif shell.degree == 270 then
            shell.y = shell.y - shell.speed * dt
        elseif shell.degree == 180 then
            shell.x = shell.x - shell.speed * dt
        end

        -- Remove shell that has left the map
        if shell.x < 0 or shell.x > window_width or shell.y < 0 or shell.y > window_height then
            table.remove(self.shells, i)
        end
    end
    
    --enemy   
    --- use counter instead of table size to avoid size decrease when enemy disappears 
    while self.spawn_timer > 1 and self.counter < self.difficulty * self.enemy_number do
       
        local enemy = {            
            tank = love.graphics.newImage("enemy.png"),
            x = love.math.random(love.graphics.newImage("enemy.png"):getWidth() / 2, window_width - love.graphics.newImage("enemy.png"):getWidth() / 2),
            y = love.graphics.newImage("enemy.png"):getWidth() / 2,
            width = love.graphics.newImage("enemy.png"):getWidth(),
            height = love.graphics.newImage("enemy.png"):getHeight(),
            degree = love.math.random(0, 3) * 90,
            sx = 0.7,
            sy = 0.7,
            speed = 100 + 5 * self.difficulty,
            explosion = false,
            timer = 0,
            bullets = self.bullets
        }

        table.insert(self.enemies, enemy)
        self.counter = self.counter + 1
        
        self.spawn_timer = 0
    end
    
    -- enemy bullet
    if self.bullet_timer > 1.5 then
        for i, enemy in ipairs(self.enemies) do
            local bullet = {
                x = enemy.x,
                y = enemy.y,
                width = love.graphics.newImage("bullet.png"):getWidth(),
                height = love.graphics.newImage("bullet.png"):getHeight(),
                degree = 0,
                speed = 150
            }
        
            --if self.bullet_timer > 0.5 then
                
                if enemy.degree == 0 then
                    bullet.degree = 0
                    bullet.y = enemy.y - 24
                elseif enemy.degree == 90 then
                    bullet.degree = 90 
                    bullet.x = enemy.x + 24 
                elseif enemy.degree == 270 then
                    bullet.degree = 270 
                    bullet.x = enemy.x - 24
                elseif enemy.degree == 180  then
                    bullet.degree = 180 
                    bullet.y = enemy.y - 6 
                end  

                table.insert(self.bullets, bullet)      
        end
        self.bullet_timer = 0    
    end

    --- bullet movement
    for i, bullet in ipairs(self.bullets) do
        if bullet.degree == 0 then
            bullet.x = bullet.x + bullet.speed * dt
        elseif bullet.degree == 90 then
            bullet.y = bullet.y + bullet.speed * dt
        elseif bullet.degree == 270 then
            bullet.y = bullet.y - bullet.speed * dt
        elseif bullet.degree == 180 then
            bullet.x = bullet.x - shell.speed * dt
        end

        -- Remove bullet that has left the map
        if bullet.x < 0 or bullet.x > window_width or bullet.y < 0 or bullet.y > window_height then
            table.remove(self.bullets, i)
        end
    end 
    
    -- enemy movement
    ---  change directions
    ----  1. random 10% chance change after certain time
    for i, enemy in ipairs(self.enemies) do
        -- 10% chance to change direction
       
        enemy.timer = enemy.timer + dt  
          
        if enemy.timer > love.math.random(1, 10) then
            enemy.degree = love.math.random(0, 3) * 90
            enemy.timer = 0
        end
    end

    ----  2. when hits the wall, leave away 1 pixel and change to the other directions
    for i, enemy in ipairs(self.enemies) do
        if (enemy.x + enemy.width / 2) > window_width then
            enemy.x = enemy.x - 1
            enemy.degree = love.math.random(1, 3) * 90
        elseif (enemy.y + enemy.height / 2) > window_height then
            enemy.y = enemy.y - 1
            local degree1 = {0, 180, 270}
            enemy.degree = degree1[love.math.random(1, 3)]
        elseif (enemy.x - enemy.width / 2) < 0 then
            enemy.x = enemy.x + 1
            local degree2 = {0, 90, 270}
            enemy.degree = degree2[love.math.random(1, 3)]
        elseif (enemy.y - enemy.height / 2) < 0 then
            enemy.y = enemy.y + 1
            enemy.degree = love.math.random(0, 2) * 90
        end
    end
            
    ---  check direction and apply movement
    for i, enemy in ipairs(self.enemies) do        
        if enemy.degree == 0 then
            enemy.sy = 0.7 
            enemy.x = enemy.x + enemy.speed * dt                    
        elseif enemy.degree == 90 then
            enemy.sy = 0.7
            enemy.y = enemy.y + enemy.speed * dt
        elseif enemy.degree == 180 then
            enemy.sy = - 0.7
            enemy.x = enemy.x - enemy.speed * dt
        elseif enemy.degree == 270 then
            enemy.sy = 0.7
            enemy.y = enemy.y - enemy.speed * dt 
        end
    end    

    --- check collision between player and bullets
    for i, bullet in ipairs(self.bullets) do        
        local h = bullet.height / 2

        if bullet.x + h > self.player.x - 30 and
                bullet.x - h  < self.player.x + 30 and
                bullet.y + h  > self.player.y - 30  and
                bullet.y - h  < self.player.y + 30 then
                        
            if self.sound then
                self.assets.explosion:stop()
                self.assets.explosion:play()
            end

            game.states.scoreboard:add_score(self.score)
            game:change_state("scoreboard")
        end
    end
    ---check collision between enemy and player's shells
    for i, enemy in ipairs(self.enemies) do
        local h = enemy.height / 2

        for s, shell in ipairs(self.shells) do
            if enemy.x + h > shell.x and
                    enemy.x - h  < shell.x and
                    enemy.y + h  > shell.y and
                    enemy.y - h  < shell.y then

                enemy.tank = love.graphics.newImage("explosion.png")
                enemy.explosion = true
                enemy.degree = 360
                table.remove(self.shells, s)

                

                if self.sound then
                    self.assets.explosion:stop()
                    self.assets.explosion:play()
                end 
            end
        end
        --- remove the enemy after 0.2 second
        if enemy.explosion then
            self.explosion_timer = self.explosion_timer + dt
            if self.explosion_timer > 0.2 then
                table.remove(self.enemies,i)
                self.score = self.score + 100 * self.difficulty               
                self.explosion_timer = 0
            end
        end
        --- return to scoreboard if win
        if self.score == 100 * self.difficulty * self.difficulty * self.enemy_number then
            game.states.scoreboard:add_score(self.score)
            game:change_state("scoreboard")
        end
    end   
end

return play