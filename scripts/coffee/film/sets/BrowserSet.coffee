Set = require('tiny-filmmaking-studio').Set

module.exports = class BrowserSet extends Set

	constructor: ->

		super

		@id = 'browser'

		container = @_makeEl '#browser-container.container'
		.inside @film.display.stageEl
		.z 1

		frame = @_makeEl '#browser-frame'
		.inside container
		.width @_normalize 1176
		.height @_normalize 630

		@_setupDomEl 'Browser', 'Frame', frame, [
			'translation', 'scale', 'wysihwyg'
		]

		frameTop = @_makeEl '#browser-frame-top'
		.inside frame
		.height @_normalize 48

		frameBottom = @_makeEl '#browser-frame-bottom'
		.inside frame
		.height @_normalize 22