EditingFilm = require('tiny-filmmaking-studio').EditingFilm
setup1 = require './lanes/1'

film = new EditingFilm

	id: 'web-full-of-color'

	lane: '1'

	pass: 'qwerty'

	aspectRatio: 2.1

	port: 6545

	sourceResolution: [1680, 1050]

setup1 film

film.theatre.model.audio.add "../audio/narration/i-remember/1.mp3", 20000
film.theatre.model.audio.add "../audio/narration/as-a-web-developer/1.mp3", 36000
film.theatre.model.audio.add "../audio/narration/within-ten-minutes/1.mp3", 52000
film.theatre.model.audio.add "../audio/narration/i-can-imagine/1.mp3", 60000

film.run()