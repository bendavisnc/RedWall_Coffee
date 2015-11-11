Observable = Rx.Observable

class RedWall

	theRoughIdea = """
		get-day -->
			get-index -->
				get-url -> try-in-three-x-second-spans --> -- fetch-reddit-doc -->
						get-image-links

					until-success-or-x-tries -->
						download-image -->
							save-image -->
								.
	"""

	# scope = null
	scope = RedWall.prototype

	constructor: () ->
		null
		# scope = this



	getDay: () ->
		return new Date()

	getIndex: (fromWhichDay) ->
		return fromWhichDay.getDay()

	getUrl: (fromWhichIndex) ->
		indexsToDays = {
			0: "monday",
			1: "tuesday",
			2: "wednesday",
			3: "thursday",
			4: "friday",
			5: "saturday",
			6: "sunday",
		}
		daysToPages = {
			"monday": "https://www.reddit.com/r/bikeporn",
			"tuesday": "https://www.reddit.com/r/spaceporn",
			"wednesday": "https://www.reddit.com/r/roomporn",
			"thursday": "https://www.reddit.com/r/cityporn",
			"friday": "https://www.reddit.com/r/earthporn",
			"saturday": "https://www.reddit.com/r/bikeporn",
			"sunday": "https://www.reddit.com/r/bikeporn",
		}
		daysToPages[indexsToDays[fromWhichIndex]]

	getImageLinks: (fromWhichUrl) ->
		downloadContent = null # todo
		return "data"

	tryInThreeXSecondSpans: (xSeconds, whichUrl, whichAction) ->
		return Observable.interval(xSeconds * 1000)
			.map(whichAction whichUrl)
			.startWith(whichAction whichUrl)
			# .takeUntil(scope.successFetchingDoc)
			# .takeWhile(() ->
				# return ! scope.todaysSubscription.isStopped
			# )



	# mappable promised reddit dom doc
	todaysFetchedDoc = Observable.return(scope.getDay())
		.map(scope.getIndex)
		.map(scope.getUrl)
		.map((theUrl) -> 
			scope.tryInThreeXSecondSpans(3, theUrl, scope.getImageLinks)) # TODO

	todaysSubscription:
		todaysFetchedDoc.subscribe(
			(e) -> 
				window.testObj = e
				console.dir(e)

			)

	# untilSuccesOrXTries: (xTries, )


	# ourConnectionTries
	# 	.map(this.untilSuccesOrXTries)
	# 	.map(this.downloadImage)
	# 	.map(this.saveImage)






	# whatWeAreDoing.subscribe(
	# 	([wasSuccessful, urlTried]) ->
	# 		# NOTE: would love to use pattern matching here
	# 		if (wasSuccessful)
	# 			printToLog("success using #{urlTried} at #{Timer.getX()}")
	# 			killAll() # Note: Less than the sexy I want
	# 		else
	# 			printToLog("failure using #{urlTried} at #{Timer.getX()}")
	# 	)

new RedWall()
