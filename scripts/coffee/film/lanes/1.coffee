IntroSet = require '../sets/IntroSet'
BallroomSet = require '../sets/BallroomSet'
BrowserSet = require '../sets/BrowserSet'

module.exports = (film) ->

	film.theatre.model.audio.add "../audio/narration/i-remember/1.mp3", 20000
	film.theatre.model.audio.add "../audio/narration/as-a-web-developer/1.mp3", 36000
	film.theatre.model.audio.add "../audio/narration/within-ten-minutes/1.mp3", 52000
	film.theatre.model.audio.add "../audio/narration/i-can-imagine/1.mp3", 60000

	film.addSet new IntroSet film
	film.addSet new BallroomSet film
	film.addSet new BrowserSet film