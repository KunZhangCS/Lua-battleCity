local menu = {
	assets = {
		title = love.graphics.newFont(30),
		menu = love.graphics.newFont(20),
		help = love.graphics.newFont(14),
		select = love.graphics.newImage("player_tank.png")
	},
	items = {
		"New Game",
		"Scoreboard",
		"Settings",
		"Quit"
	},
	selected_item = 1	
}	

function menu:entered()
	-- Reset menu to first item when state entered
	self.selected_item = 1
end

function menu:draw()
	-- Calculate drawable positions
	local window_width, window_height = love.graphics.getDimensions()
	local window_width_center, window_height_center = window_width / 2, window_height / 2
	
	local menu_width, menu_height = 480, 360
	local menu_width_center, menu_height_center = menu_width / 2, menu_height /2 
	
	local menu_x, menu_y = window_width_center - menu_width_center, window_height_center - menu_height_center

	-- Set windwo background
	love.graphics.setBackgroundColor(4 / 255, 169 / 255, 201 / 255)
	
	-- Draw menu background rectangle
	love.graphics.setColor(221 / 255, 221 / 255, 221 / 255)
	love.graphics.rectangle("fill", menu_x, menu_y, menu_width, menu_height)
	
	-- Draw tank let it has the same color with nemu
	love.graphics.draw(self.assets.select, menu_x + 35, (35 * self.selected_item) + menu_y + 53, math.rad(0), 0.3, 0.3)

	-- Draw menu title
	love.graphics.setColor(4 /255, 169 / 255, 201 / 255)
	love.graphics.setFont(self.assets.title)
	love.graphics.print("Battle City 1985", menu_x + 80, menu_y + 20)	
	
	-- Draw help text
	love.graphics.setFont(self.assets.help)
	love.graphics.setColor(230 / 255, 12 / 255, 98 / 255)
	love.graphics.print("Movement: [A] [W] [S] [D] Select: [SPACE] / [ENTER]", menu_x + 80, menu_y + menu_height - 30)

	love.graphics.setFont(self.assets.menu)
	for i, item in ipairs(self.items) do
		local item_x, item_y = menu_x + 80, menu_y + 50
		
		if i == self.selected_item then
			love.graphics.setColor(230 / 255, 12 / 255, 98 / 255)
		else
			love.graphics.setColor(4 / 255, 169 / 255, 201 / 255)
		end
		
		love.graphics.print(item, item_x, 35 * i + item_y)
	end
	-- Can not Draw tank here, other wise its background color will change to red when selected_item == 4
	--love.graphics.draw(self.assets.select, menu_x + 35, (35 * self.selected_item) + menu_y + 53, math.rad(0), 0.3, 0.3)	
end

function menu:keypressed(key)
	if key == "w" or key == "up" then
		self.selected_item = self.selected_item - 1
		
		if self.selected_item < 1 then		
			self.selected_item = #self.items
		end
	end
	
	if key == "s" or key == "down" then
		self.selected_item = self.selected_item + 1
		
		if self.selected_item > #self.items then		
			self.selected_item = 1
		end
	end
	
	if key == "sapce" or key == "return" then
		if self.selected_item == 1 then
			game:change_state("play")
		elseif self.selected_item == 2 then
			game:change_state("scoreboard")
		elseif self.selected_item == 3 then
			game:change_state("settings")
		elseif self.selected_item == 4 then
			love.event.quit(0)
		end
	end
end

return menu