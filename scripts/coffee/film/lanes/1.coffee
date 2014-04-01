IntroSet = require '../sets/IntroSet'
BallroomSet = require '../sets/BallroomSet'
BrowserSet = require '../sets/BrowserSet'

module.exports = (film) ->

	film.addSet new IntroSet film
	film.addSet new BallroomSet film
	film.addSet new BrowserSet film