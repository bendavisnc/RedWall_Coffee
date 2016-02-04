# Rx = require("./bower_components/rxjs/rx.all.js")
Rx = require("rx")
cheerio = require("cheerio")
fs = require('fs')

Observable = Rx.Observable

Array.prototype.contains = (what) ->
	return this.indexOf(what) != -1

Array::randomized = -> @sort -> 0.5 - Math.random()

class RedWall

	helpSpace = null
	bigDance = null
	logger = null

	constructor: (whichHelpSpaceToUse) ->
		helpSpace = whichHelpSpaceToUse
		logger = 
			log: (whatToLog) ->
				console.log(whatToLog)

		go = () ->
			bigDance.subscribe(
				((emitted) ->
					logger.log("Successfully set #{emitted} as today's wallpaper")
				), 
				((error) ->
					logger.log("Uncaught error: #{error}")
				), 
				(() ->
					logger.log("Finished")
				)
			)
		test = () ->
			null

		# test()
		go()

	dayIndexStream = Observable.from([(new Date()).getDay()])

	dayStream = dayIndexStream.map \
		(whichIndex) -> 
			{
				0: "sunday",
				1: "monday",
				2: "tuesday",
				3: "wednesday",
				4: "thursday",
				5: "friday",
				6: "saturday",
			}[whichIndex]

	redditUrlStream = dayStream.map \
		(whichDay) -> 
			{
				"monday": "http://www.reddit.com/r/bikeporn",
				"tuesday": "http://www.reddit.com/r/spaceporn",
				"wednesday": "http://www.reddit.com/r/roomporn",
				"thursday": "http://www.reddit.com/r/cityporn",
				"friday": "http://www.reddit.com/r/earthporn",
				"saturday": "http://www.reddit.com/r/bikeporn",
				"sunday": "http://www.reddit.com/r/bikeporn",
			}[whichDay]


	redditPageStream = redditUrlStream.flatMap \
		(redditUrl) ->
			return Observable.create \
				(observer) ->
					helpSpace.download(
						redditUrl,
						(successfullyDownloaded) ->
							logger.log("Successfully downloaded #{redditUrl}")
							observer.onNext(successfullyDownloaded)
							observer.onCompleted()
						(failedDownload) ->
							logger.log("Couldn't download #{redditUrl}")
							observer.onError(failedDownload)
					)

				# return Observable.catch(redditPageStream, Observable.empty())
	redditPageStreamGivenThreeChances = \
		Observable.amb([
			Observable.catch(redditPageStream, Observable.empty()).delay(0 * 1000),
			Observable.catch(redditPageStream, Observable.empty()).delay(30 * 1000),
			Observable.catch(redditPageStream, Observable.empty()).delay(90 * 1000),
			# Observable.throw(new Error('Failed to retrieve reddit page content')).delay(10000)
			# Observable.create(
				# (observer) ->
					# throw new Error('Failed to retrieve reddit page content')
			# )

		]).defaultIfEmpty(Observable.throw(new Error('Failed to retrieve reddit page content')))

	jqueryDocStream = redditPageStreamGivenThreeChances.map \
		(docText) ->
			return cheerio.load(docText);

	imageUrlsStream = jqueryDocStream.map \
		(jqueryDoc) ->
			return jqueryDoc("div.entry.unvoted")
				.find("a.title.may-blank")
				.filter(
					(i, eachLink) ->
						linkFileExtension = helpSpace.getFileExtension(eachLink)
						return (linkFileExtension == "jpg") or
							(linkFileExtension == "jpeg") or
							(linkFileExtension == "png")
				).toArray() \
				.randomized()
				.map(
					(eachLink) ->
						return eachLink.attribs.href
				)


	imageContentStreamTriedSuccessively = imageUrlsStream.flatMap \
		(imageUrls) ->
			successiveTries = []
			howMuchDelay = -3000
			for imageUrl in imageUrls
				howMuchDelay += 3000
				fileExtension = helpSpace.getFileExtension(imageUrl)
				successiveTries.push (Observable.create \
					(observer) ->
						helpSpace.downloadForBinary( 
							imageUrl,
							(successfullyDownloaded) ->
								logger.log("Successfully downloaded #{imageUrl}")
								observer.onNext([successfullyDownloaded, fileExtension])
								observer.onCompleted()
							(failedDownload) ->
								logger.log("Couldn't download #{imageUrl}")
								null
						)
					).delay(howMuchDelay)
			# successiveTries.push Rx.Observable.throw(new Error('Failed to retrieve reddit image content')).delay(100)
			return Observable.amb(successiveTries) \
				.defaultIfEmpty(Observable.throw(new Error('Failed to retrieve reddit image content')))
				.first()

	imageContentSaved = imageContentStreamTriedSuccessively.map(
		([whichImageContent, whichFileExtenstion]) ->
			filename = "redwall.#{whichFileExtenstion}"
			fs.writeFile(filename, whichImageContent, {encoding: 'binary'},
				(err) ->
					if (err)
						throw new Error("image content not saved")
			)
			return filename
		).take(1)

	imageContentHeard = imageContentSaved.map(
		(whichFilename) ->
			helpSpace.informOS(whichFilename)
			return whichFilename
	)

	bigDance = imageContentHeard




class HelpSpace

	http = require("http");
	# http://www.storminthecastle.com/2013/08/25/use-node-js-to-extract-data-from-the-web-for-fun-and-profit/
	@downloadForBinary: (url, successCallback, badnewsCallback) ->
		http.get(url, (res) ->
			data = ""
			res.setEncoding('binary')
			res.on('data', (chunk) ->
				data += chunk
			)
			res.on("end", () ->
				successCallback(data)
			)
		).on("error", (e) ->
			badnewsCallback(e);
		)


	request = require("request")
	# http://www.sitepoint.com/web-scraping-in-node-js/
	@download: (url, successCallback, badnewsCallback) ->
		console.log("@ HelpSpace.download")
		# thisUrl = url
		request({uri: url,
			},
			(error, response, body) ->
				if (error)
					badnewsCallback(error)
				else
					successCallback(body)
		)

	@getFileExtension: (fromLinkorText) ->
		linkHref = if fromLinkorText.attribs then fromLinkorText.attribs.href else fromLinkorText
		return linkHref[(linkHref.lastIndexOf('.') + 1)..]

	exec = require('child_process').exec
	# http://stackoverflow.com/questions/20643470/execute-a-command-line-binary-with-node-js
	@informOS: (whichFilename) ->
		preciseFilename = require('path').resolve(
				__dirname, 
				whichFilename)
		cmd = """
			gsettings set org.gnome.desktop.background picture-uri file://#{preciseFilename} &&
			gsettings set org.gnome.desktop.background picture-options scaled
		"""

		exec(cmd, (error, stdout, stderr) ->
			null
		) # todo: error handling

new RedWall(HelpSpace)
