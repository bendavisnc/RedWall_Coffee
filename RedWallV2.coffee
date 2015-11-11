# Rx = require("./bower_components/rxjs")
Rx = require("rx")
cheerio = require("cheerio");

Observable = Rx.Observable

class RedWallV2

	theRoughIdea = """
		1. repeat lazy function
			(fn [] (#download reddit page))
		2. buffer and grab
		3. map and execute
		4. filter success
		5. map to parsed list of image links
		6. download image
		7. emit byte array
		8. take only one

	"""

	scope = null

	constructor: () ->
		console.log("@ constructor")
		scope = this
		this.test()

	# 1.
	repeatLazyFunction: () ->
		console.log("@ repeatLazyFunction")
		return Observable.repeat(scope.generateLazyPageDownload())
			.take(1000) # NOTE: weird that this is required with zip

	# 2.
	bufferAndGrab: () ->
		console.log("@ bufferAndGrab")
		return Observable.zip([
			scope.repeatLazyFunction()
			Observable.interval(1000)]
		)
		.filter((lazyFunc, i) ->
			return (i == 0) ||
				(i == 30) ||
				(i == 180)
		)
		# Observable.interval(1000)
		# scope.repeatLazyFunction()

	parseToDoc: (whichString) ->
		console.log("@ parseToDoc")
		$ = cheerio.load(whichString);
		return $

	generateLazyPageDownload: () ->
		console.log("@ generateLazyPageDownload")
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
			"monday": "http://www.reddit.com/r/bikeporn",
			"tuesday": "http://www.reddit.com/r/spaceporn",
			"wednesday": "http://www.reddit.com/r/roomporn",
			"thursday": "http://www.reddit.com/r/cityporn",
			"friday": "http://www.reddit.com/r/earthporn",
			"saturday": "http://www.reddit.com/r/bikeporn",
			"sunday": "http://www.reddit.com/r/bikeporn",
		}
		todaysIndex = (new Date()).getDay()
		todaysUrl = daysToPages[indexsToDays[todaysIndex]]
		return Observable.create(
			(observer) ->
				HelpSpace.download(todaysUrl, 
					(downloadedContent) ->
						observer.onNext(downloadedContent)
						observer.onCompleted()
				)
			).map(scope.parseToDoc)

	test: () =>
		console.log("testing")
		whatWeveGot = this.bufferAndGrab()
		whatWeveGot.subscribe(
			(emitted) ->
				console.log("good")
				console.log(emitted)
			(fucked) ->
				console.log("not good")
				console.log(fucked)
			() ->
				console.log("done")
				null
		)

	# getUrl: (fromWhichIndex) ->
	# 	indexsToDays = {
	# 		0: "monday",
	# 		1: "tuesday",
	# 		2: "wednesday",
	# 		3: "thursday",
	# 		4: "friday",
	# 		5: "saturday",
	# 		6: "sunday",
	# 	}
	# 	daysToPages = {
	# 		"monday": "https://www.reddit.com/r/bikeporn",
	# 		"tuesday": "https://www.reddit.com/r/spaceporn",
	# 		"wednesday": "https://www.reddit.com/r/roomporn",
	# 		"thursday": "https://www.reddit.com/r/cityporn",
	# 		"friday": "https://www.reddit.com/r/earthporn",
	# 		"saturday": "https://www.reddit.com/r/bikeporn",
	# 		"sunday": "https://www.reddit.com/r/bikeporn",
	# 	}
	# 	daysToPages[indexsToDays[fromWhichIndex]]

class HelpSpace

	# http = require("http");
	# http://www.storminthecastle.com/2013/08/25/use-node-js-to-extract-data-from-the-web-for-fun-and-profit/
	# @download: (url, callback) ->
	# 	http.get(url, (res) ->
	# 		data = ""
	# 		res.on('data', (chunk) ->
	# 			data += chunk
	# 		)
	# 		res.on("end", () ->
	# 			callback(data)
	# 		)
	# 	).on("error", () ->
	# 		callback(null);
	# 	)


	request = require("request")
	# http://www.sitepoint.com/web-scraping-in-node-js/
	@download: (url, callback) ->
		console.log("@ HelpSpace.download")
		request({uri: url,
			},
			(error, response, body) ->
				callback(arguments)
		)


new RedWallV2()
