FinishedFilm = require 'tiny-filmmaking-studio/scripts/js/lib/FinishedFilm'
setupLane1 = require './lanes/1'

film = new FinishedFilm

	id: 'web-full-of-color'

	lane: '1'

	aspectRatio: 2.1

	sourceResolution: [1680, 1050]

setupLane1 film

film.run()