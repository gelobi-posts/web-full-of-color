Set = require('tiny-filmmaking-studio').Set
Ballsamic = require './ballroomSet/Ballsamic'

module.exports = class BallroomSet extends Set

	constructor: ->

		super

		@id = 'ballroom'

		container = @_makeEl '#ballroom-container.container'
		.z -1
		.inside @film.display.stageEl

		view = @_makeEl '#ballroom-view'
		.inside container
		.z 0

		@_setupDomEl 'Ballroom', 'View', view, [
			'translation', 'scale', 'wysihwyg'
		]

		piston = @_makeEl '#ballroom-view-piston'
		.inside view

		@_setupDomEl 'Ballroom', 'View Piston', piston, [
			'translation', 'wysihwyg'
		]

		deepBg = @_makeEl '#ballroom-deepBg'
		.inside piston
		.z -1

		beam = @_makeEl '#ballroom-beam'
		.inside piston

		@ballsamic = new Ballsamic @_normalize(1680), @_normalize(800), '../images/ballroom/the-ball.png', '../images/ballroom/the-ball.png'

		piston.adopt @ballsamic.canvas

		@ballsamic.canvas.style.position = 'absolute'
		@ballsamic.canvas.style.bottom = 0

		@film.onTick => do @ballsamic.tick

		setTimeout =>

			@ballsamic.play()

		, 1000