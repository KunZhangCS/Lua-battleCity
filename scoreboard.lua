local scoreboard = {
	assets ={
		title = love.graphics.newFont(30),
		menu = love.graphics.newFont(20),
		help = love.graphics.getFont(14)
	},
	scoreboard_file = "scores.txt",
	score_limit = 6,
	scores = {}
}

function scoreboard:clear_scores()
	local score_file = love.filesystem.newFile(self.scoreboard_file)
	score_file:open("w")
	score_file:close()
end

function scoreboard:load_scores()
	self.scores = {}
	
	if love.filesystem.getInfo(self.scoreboard_file) then
		for score in love.filesystem.lines(self.scoreboard_file) do
			table.insert(self.scores, tonumber(score))
		end
	else
		table.insert(self.scores, "No score data...")
	end
end

function scoreboard:add_score(score)
	local scores = {}
	
	if love.filesystem.getInfo(self.scoreboard_file) then
		for score in love.filesystem.lines(self.scoreboard_file) do
			table.insert(scores, tonumber(score))
		end
	end
	
	table.insert(scores, score)
	
	table.sort(scores, function(a, b) return a > b end)
	
	while #scores > self.score_limit do
		 table.remove(scores)
	end
	
	local score_file = love.filesystem.newFile(self.scoreboard_file)
	score_file:open("w")
	
	for k, score in pairs(scores) do
		score_file:write(score .. "\n")
	end
	
	score_file:close()
end

function scoreboard:entered()
	self:load_scores()
end

function scoreboard:draw()
	-- Calculate drawable positions
	local window_width, window_height = love.graphics.getDimensions()
	local window_width_center, window_height_center = window_width / 2, window_height / 2
	
	local scoreboard_width, scoreboard_height = 480, 360
	local scoreboard_width_center = scoreboard_width / 2
	local scoreboard_height_center = scoreboard_height / 2
	
	local scoreboard_x = window_width_center - scoreboard_width_center
	local scoreboard_y = window_height_center - scoreboard_height_center
	
	-- Set window background
	love.graphics.setBackgroundColor(4 / 255, 169 / 255, 201 / 255)
	
	-- Draw background rectangle
	love.graphics.setColor(221 / 255, 221 / 255, 221 / 255)
	love.graphics.rectangle("fill", scoreboard_x, scoreboard_y, scoreboard_width, scoreboard_height)
	
	-- Draw title text
	love.graphics.setColor(4 /255, 169 / 255, 201 / 255)
	love.graphics.setFont(self.assets.title)
	love.graphics.print("Scoreboard", scoreboard_x + 80, scoreboard_y + 20)
		
	-- Draw help text
	love.graphics.setFont(self.assets.help)
	love.graphics.setColor(230 / 255, 12 / 255, 98 / 255)
	love.graphics.print("Return to menu: [SPACE] or [ENTER]", scoreboard_x + 80, scoreboard_y + scoreboard_height - 30)
	
	-- Draw menu text
	love.graphics.setFont(self.assets.menu)
	for i, score in ipairs(self.scores) do
		local score_x, score_y = scoreboard_x + 80, scoreboard_y + 50
		
		love.graphics.setColor(4 /255, 169 / 255, 201 / 255)
		love.graphics.print(score, score_x, 35 * i + score_y)
	end
end

function scoreboard:keypressed(key)
	if key == "space" or key == "return" then
		game:change_state("menu")
	end
end

return scoreboard