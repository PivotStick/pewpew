-- title:  game title
-- author: game developer
-- desc:   short description
-- script: moon

wrect = (ox, oy, w, h, c) ->
	{ :x, :y } = Camera.toWorldCoordinates ox, oy
	rect x, y, w, h, c

wrectb = (ox, oy, w, h, c) ->
	{ :x, :y } = Camera.toWorldCoordinates ox, oy
	rectb x, y, w, h, c

wprint = (text, ox = 0, oy = 0, c) ->
	{ :x, :y } = Camera.toWorldCoordinates ox, oy
	print text, x, y, c

--
getters = (cls, getters) ->
	cls.__base.__index = (key) =>
		if getter = getters[key]
			getter @
		else
			cls.__base[key]

setters = (cls, setters) ->
	cls.__base.__newindex = (key, val) =>
		if setter = setters[key]
			setter @, val
		else
			rawset @, key, val
--

export class Vector
	new: (x, y) =>
		@x = x
		@y = y

	__add: (rhs) => Vector @x + rhs.x, @y + rhs.y
	__sub: (rhs) => Vector @x - rhs.x, @y - rhs.y
	__mul: (val) => Vector @x * val, @y * val
	__div: (val) => Vector @x / val, @y / val
	__tostring: => "{ x=#{@x}, y=#{@y} }"
--

export class Camera
	@position = Vector 0, 0
	@target = Vector 0, 0

	@moveTo = (x, y) ->
		@target.x = x
		@target.y = y

	@toWorldCoordinates = (x, y) ->
		{ x:cx, y:cy } = @position
		Vector x - cx, y - cy

	@update = ->
		@position += (@target - @position) * 0.1
--

WIDTH = 240
HEIGHT = 136

MENU = 1
GAME = 2

export TIC = ->
	cls 0

	Camera.update!

	Game.chooseState!

--
class Modal
	new: (x = WIDTH / 2, y = HEIGHT / 2, w, h) =>
		@pos = Vector x - w / 2, y - h / 2
		@off = Vector 0, 0

		@width = w
		@height = h

		@fields = {}
		@padding = 6
		@selected = 1

	getters @,
		x: => @pos.x - @off.x
		y: => @pos.y - @off.y

	addField: (text, onConfirm) =>
		table.insert @fields, {
			text: text,
			ox: 0,
			oy: 0,
			onConfirm: onConfirm
		}
		return @

	listen: =>

		if btnp(0) or btnp(1)
			unless #@fields > 1 then return
			sfx 0, 46, 60
			if btnp 0 then @selected -= 1
			if btnp 1 then @selected += 1

		if @selected < 1 then @selected = #@fields
		if @selected > #@fields then @selected = 1

		if keyp 50
			{ :onConfirm } = @fields[@selected]
			if onConfirm
				sfx 0, 90
				onConfirm!
			else
				sfx 0, 4

	draw: =>
		rect @x, @y, @width, @height, 0
		rectb @x, @y, @width, @height, 13

		for i, field in ipairs @fields
			isSelected = @selected == i
			ox = isSelected and 5 or 0
			oy = 0

			field.ox += (ox - field.ox) * 0.1
			field.oy += (oy - field.oy) * 0.1

			x = @x + @padding + field.ox
			y = @y + @padding + field.oy + (i - 1) * 8

			print field.text, x, y, isSelected and 13 or 14
--

-- Screens
class MenuScreen

	@state = "menu"

	@menu = with Modal(nil, nil, 150, 50)
		\addField "Start Game", ->
			Game.state = GAME
		\addField "Settings", ->
			@state = "settings"
		\addField "Quit Game", ->
			exit!

	@settings = with Modal(nil, nil, 75, 25)
		\addField "Go Back", ->
			@state = "menu"

	@update = ->
		switch @state
			when "menu"
				@menu\listen!
				@menu\draw!
			when "settings"
				@settings\listen!
				@settings\draw!

	@display = ->


class GameScreen

	@isPaused = false

	@menu = with Modal(nil, nil, 125, 75)
		\addField "Go back to Menu", ->
			Game.state = MENU
			@isPaused = false
		\addField "Resume", ->
			@isPaused = false

	@update = ->
		if keyp 16
			sfx 0, 66, 60
			@isPaused = not @isPaused

	@display = ->
		print "Game"

		if @isPaused
			@menu\listen!
			@menu\draw!

	
-- Game Manager
export class Game
	@state = MENU

	@screens = {
		MenuScreen,
		GameScreen
	}

	@chooseState = ->
		screen = @screens[@state]

		if screen
			screen.update!
			screen.display!
		else
			@state = MENU
--

-- <TILES>
-- 001:2222222222222222222222222222222222222222222222222222222222222222
-- 002:3333333333333333333333333333333333333333333333333333333333333333
-- 003:4444444444444444444444444444444444444444444444444444444444444444
-- 004:5555555555555555555555555555555555555555555555555555555555555555
-- </TILES>

-- <SPRITES>
-- 000:b000000bb0bbbb0bb000000bb000000bb000000bb00bb00bb000000b0bbbbbb0
-- </SPRITES>

-- <MAP>
-- 000:100000000000000000000000000000000000000000000000000000000000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:000000000000000000000000000000000000000000000000000000000010200000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:000000000000000000000000000000000000000000000000000000000030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:12356789abb2344445555447dcc75000
-- </WAVES>

-- <SFX>
-- 000:03f403e603e703d703d713d663d6a3d4f30ff300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300500000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

