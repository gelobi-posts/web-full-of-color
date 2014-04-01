module.exports = class Ballsamic

	constructor: (@width, @height, earthSrc, moonSrc) ->

		@earth = new Image()
		@earth.src = earthSrc

		@moon = new Image()
		@moon.src = moonSrc

		@canvas = document.createElement "canvas"

		@ctx = @canvas.getContext("2d")

		@EPS = 0.0001

		@_x = []
		@_y = []

		@_xLast = []
		@_yLast = []

		@ax = []
		@ay = []
		@_nParts = 80

		@tStep = 1.0/60.0

		@_perimIters = 40

		@_relaxFactor = .9

		@_gravityForceY = -9.8
		@_gravityForceX = 0

		@_rad = 13

		@_blobAreaTarget = 0

		@_sideLength = 0

		@_mouseRad = 5

		@_mousePos = new Float32Array [@width/100, @height/100]

		do @_updateDims

		return

	tick: ->

		if @_playing

			do @_update

		return

	play: ->

		@_playing = yes

	pause: ->

		@_playing = no

	reposMouse: (x, y) ->

		unless @_isPointInBlob (x / 10), (y / 10)

			@_mousePos[0] = x / 10
			@_mousePos[1] = y / 10

		return

	_update: ->

		@_integrateParticles(@tStep)

		@_constrainBlobEdges()

		@_collideWithEdge()
		@_collideWithMouse()

		@_integrateParticles(@tStep)

		@_constrainBlobEdges()

		@_collideWithEdge()
		@_collideWithMouse()

		@_integrateParticles(@tStep)

		@_constrainBlobEdges()

		@_collideWithEdge()
		@_collideWithMouse()

		@ctx.clearRect(0, 0, @width, @height)

		do @_draw

		do @_drawMouse

	_updateDims: ->

		@ctx.canvas.width = @width
		@ctx.canvas.height = @height

		do @_setupParticles

	_setupParticles: ->

		@_positionsX = new Float32Array @_nParts
		@_positionsY = new Float32Array @_nParts

		@_xLast = new Float32Array @_nParts
		@_yLast = new Float32Array @_nParts

		@ax = new Float32Array @_nParts
		@ay = new Float32Array @_nParts

		cx = @width / 20
		cy = @height / 20

		for i in [0...@_nParts]

			ang = i * 2 * Math.PI / @_nParts
			@_positionsX[i] = cx + Math.sin(ang) * @_rad
			@_positionsY[i] = cy + Math.cos(ang) * @_rad
			@_xLast[i] = @_positionsX[i]
			@_yLast[i] = @_positionsY[i]
			@ax[i] = 0
			@ay[i] = 0

		@_sideLength = Math.sqrt( (@_positionsX[1]-@_positionsX[0])*(@_positionsX[1]-@_positionsX[0])+(@_positionsY[1]-@_positionsY[0])*(@_positionsY[1]-@_positionsY[0]) )

		@_blobAreaTarget = @_getArea()
		@_fixPerimeter()

		return

	_getArea: ->

		npartsmines = @_nParts - 1

		area = 0.0

		area += @_positionsX[npartsmines] * @_positionsY[0]-@_positionsX[0] * @_positionsY[npartsmines]

		for i in [0...npartsmines]

			area += (@_positionsX[i] * @_positionsY[i+1] - @_positionsX[i+1] * @_positionsY[i])

		area *= 0.5

		area

	_integrateParticles: (dt) ->

		dtSquared = dt * dt

		gravityAddY = -@_gravityForceY * dtSquared
		gravityAddX = -@_gravityForceX * dtSquared

		for i in [0...@_nParts]

			bufferX = @_positionsX[i]
			bufferY = @_positionsY[i]

			@_positionsX[i] = 2 * @_positionsX[i] - @_xLast[i] + @ax[i] * dtSquared - gravityAddX
			@_positionsY[i] = 2 * @_positionsY[i] - @_yLast[i] + @ay[i] * dtSquared + gravityAddY

			@_xLast[i] = bufferX
			@_yLast[i] = bufferY

			@ax[i] = 0
			@ay[i] = 0

		return

	_collideWithEdge: ->

		for i in [0...@_nParts]

			if (@_positionsX[i] < 0)

				@_positionsX[i] = 0
				@_yLast[i] = @_positionsY[i]

			else if (@_positionsX[i] > @width/10)

				@_positionsX[i] = @width/10
				@_yLast[i] = @_positionsY[i]

			if (@_positionsY[i] < 0)

				@_positionsY[i] = 0
				@_xLast[i] = @_positionsX[i]

			else if (@_positionsY[i] > @height/10)

				@_positionsY[i] = @height/10
				@_xLast[i] = @_positionsX[i]

		return

	_fixPerimeter: ->

		diffx = new Float32Array(@_nParts)
		diffy = new Float32Array(@_nParts)

		for i in [0...@_nParts]

			diffx[i] = 0
			diffy[i] = 0

		for j in [0...@_perimIters]

			for i in [0...@_nParts]

				if i is @_nParts-1

					next = 0

				else

					next = i+1

				dx = @_positionsX[next]-@_positionsX[i]
				dy = @_positionsY[next]-@_positionsY[i]

				distance = Math.sqrt(dx*dx+dy*dy)

				if (distance < @EPS) then distance = 1.0

				diffRatio = 1.0 - @_sideLength / distance

				diffx[i] += 0.5*@_relaxFactor * dx * diffRatio
				diffy[i] += 0.5*@_relaxFactor * dy * diffRatio

				diffx[next] -= 0.5*@_relaxFactor * dx * diffRatio
				diffy[next] -= 0.5*@_relaxFactor * dy * diffRatio

				@_positionsX[i] += diffx[i]
				@_positionsY[i] += diffy[i]

				diffx[i] = 0
				diffy[i] = 0

		return

	_constrainBlobEdges: ->

		@_fixPerimeter()

		perimeter = 0.0

		nx = new Float32Array(@_nParts)
		ny = new Float32Array(@_nParts)

		for i in [0...@_nParts]

			if i is @_nParts-1

					next = 0

				else

					next = i+1

			dx = @_positionsX[next]-@_positionsX[i]
			dy = @_positionsY[next]-@_positionsY[i]

			distance = Math.sqrt(dx*dx+dy*dy)

			if (distance < @EPS) then distance = 1.0

			nx[i] = dy / distance
			ny[i] = -dx / distance

			perimeter += distance

		deltaArea = @_blobAreaTarget - @_getArea()

		toExtrude = 0.5*deltaArea / perimeter

		for i in [0...@_nParts]

			if i is @_nParts-1

					next = 0

				else

					next = i+1

			@_positionsX[next] += toExtrude * (nx[i] + nx[next])
			@_positionsY[next] += toExtrude * (ny[i] + ny[next])

		return

	_collideWithMouse: ->

		for i in [0...@_nParts]

			dx = @_mousePos[0] - @_positionsX[i]
			dy = @_mousePos[1] - @_positionsY[i]

			distSqr = dx*dx+dy*dy

			continue if (distSqr > @_mouseRad * @_mouseRad)
			continue if (distSqr < @EPS * @EPS)

			distance = Math.sqrt(distSqr)

			@_positionsX[i] -= dx*(@_mouseRad/distance-1.0)
			@_positionsY[i] -= dy*(@_mouseRad/distance-1.0)

		return

	_isPointInBlob: (x, y) ->

		`for(var c = false, i = -1, l = this._nParts, j = l - 1; ++i < l; j = i){

			((this._positionsY[i] <= y && y < this._positionsY[j]) || (this._positionsY[j] <= y && y < this._positionsY[i]))
			&& (x < (this._positionsX[j] - this._positionsX[i]) * (y - this._positionsY[i]) / (this._positionsY[j] - this._positionsY[i]) + this._positionsX[i])
			&& (c = !c)

		}`
		c

	_drawMouse: ->

		@ctx.drawImage(@moon, @_mousePos[0] * 10 - (@_mouseRad*10), @_mousePos[1] * 10 - (@_mouseRad*10), @_mouseRad*20, @_mouseRad*20)

		return

	_draw: ->

		center_x = 0
		center_y = 0

		for i in [0...@_nParts]

			center_x += @_positionsX[i]
			center_y += @_positionsY[i]

		center_x /= @_nParts
		center_y /= @_nParts

		p1x = center_x * 10
		p1y = center_y * 10

		n = @_nParts/2

		for i in [0...n]

			j = i * @_nParts/n
			k = (i+1) * @_nParts/n

			k = 0 if k is @_nParts

			a1 = 2*Math.PI * (i / n)
			a2 = 2*Math.PI * ((i+1) / n)

			x0 = p1x
			x1 = @_positionsX[j] * 10
			x2 = @_positionsX[k] * 10
			y0 = p1y
			y1 = @_positionsY[j] * 10
			y2 = @_positionsY[k] * 10
			u0 = @earth.width/2
			u1 = @earth.width/2 + Math.sin(a1) * @earth.width/2
			u2 = @earth.width/2 + Math.sin(a2) * @earth.width/2
			v0 = @earth.height/2
			v1 = @earth.height/2 + Math.cos(a1) * @earth.height/2
			v2 = @earth.height/2 + Math.cos(a2) * @earth.height/2

			@ctx.save()

			@ctx.beginPath()

			@ctx.moveTo(x0, y0)

			@ctx.lineTo(x1 + (x1-x0), y1 + (y1-y0))

			@ctx.lineTo(x2 + (x2-x0), y2 + (y2-y0))

			@ctx.closePath()

			@ctx.clip()

			delta = u0*v1 + v0*u2 + u1*v2 - v1*u2 - v0*u1 - u0*v2
			delta_a = x0*v1 + v0*x2 + x1*v2 - v1*x2 - v0*x1 - x0*v2
			delta_b = u0*x1 + x0*u2 + u1*x2 - x1*u2 - x0*u1 - u0*x2
			delta_c = u0*v1*x2 + v0*x1*u2 + x0*u1*v2 - x0*v1*u2 - v0*u1*x2 - u0*x1*v2
			delta_d = y0*v1 + v0*y2 + y1*v2 - v1*y2 - v0*y1 - y0*v2
			delta_e = u0*y1 + y0*u2 + u1*y2 - y1*u2 - y0*u1 - u0*y2
			delta_f = u0*v1*y2 + v0*y1*u2 + y0*u1*v2 - y0*v1*u2	- v0*u1*y2 - u0*y1*v2

			@ctx.transform(delta_a / delta, delta_d / delta, delta_b / delta, delta_e / delta, delta_c / delta, delta_f / delta)

			@ctx.drawImage(@earth, 0, 0)

			@ctx.restore()

		return