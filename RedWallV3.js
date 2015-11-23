(function() {
  var HelpSpace, Observable, RedWall, Rx, cheerio, fs;

  Rx = require("rx");

  cheerio = require("cheerio");

  fs = require('fs');

  Observable = Rx.Observable;

  Array.prototype.contains = function(what) {
    return this.indexOf(what) !== -1;
  };

  Array.prototype.randomized = function() {
    return this.sort(function() {
      return 0.5 - Math.random();
    });
  };

  RedWall = (function() {
    var bigDance, dayIndexStream, dayStream, helpSpace, imageContentHeard, imageContentSaved, imageContentStreamTriedSuccessively, imageUrlsStream, jqueryDocStream, logger, redditPageStream, redditPageStreamGivenThreeChances, redditUrlStream;

    helpSpace = null;

    bigDance = null;

    logger = null;

    function RedWall(whichHelpSpaceToUse) {
      var go, test;
      helpSpace = whichHelpSpaceToUse;
      logger = {
        log: function(whatToLog) {
          return console.log(whatToLog);
        }
      };
      go = function() {
        return bigDance.subscribe((function(emitted) {
          return logger.log("Successfully set " + emitted + " as today's wallpaper");
        }), (function(error) {
          return logger.log("Uncaught error: " + error);
        }), (function() {
          return logger.log("Finished");
        }));
      };
      test = function() {
        return null;
      };
      go();
    }

    dayIndexStream = Observable.from([(new Date()).getDay()]);

    dayStream = dayIndexStream.map(function(whichIndex) {
      return {
        0: "sunday",
        1: "monday",
        2: "tuesday",
        3: "wednesday",
        4: "thursday",
        5: "friday",
        6: "saturday"
      }[whichIndex];
    });

    redditUrlStream = dayStream.map(function(whichDay) {
      return {
        "monday": "http://www.reddit.com/r/bikeporn",
        "tuesday": "http://www.reddit.com/r/spaceporn",
        "wednesday": "http://www.reddit.com/r/roomporn",
        "thursday": "http://www.reddit.com/r/cityporn",
        "friday": "http://www.reddit.com/r/earthporn",
        "saturday": "http://www.reddit.com/r/bikeporn",
        "sunday": "http://www.reddit.com/r/bikeporn"
      }[whichDay];
    });

    redditPageStream = redditUrlStream.flatMap(function(redditUrl) {
      return Observable.create(function(observer) {
        return helpSpace.download(redditUrl, function(successfullyDownloaded) {
          logger.log("Successfully downloaded " + redditUrl);
          observer.onNext(successfullyDownloaded);
          return observer.onCompleted();
        }, function(failedDownload) {
          logger.log("Couldn't download " + redditUrl);
          return observer.onError(failedDownload);
        });
      });
    });

    redditPageStreamGivenThreeChances = Observable.amb([Observable["catch"](redditPageStream, Observable.empty()).delay(0 * 1000), Observable["catch"](redditPageStream, Observable.empty()).delay(30 * 1000), Observable["catch"](redditPageStream, Observable.empty()).delay(90 * 1000)]).defaultIfEmpty(Observable["throw"](new Error('Failed to retrieve reddit page content')));

    jqueryDocStream = redditPageStreamGivenThreeChances.map(function(docText) {
      return cheerio.load(docText);
    });

    imageUrlsStream = jqueryDocStream.map(function(jqueryDoc) {
      return jqueryDoc("div.entry.unvoted").find("a.title.may-blank").filter(function(i, eachLink) {
        var linkFileExtension;
        linkFileExtension = helpSpace.getFileExtension(eachLink);
        return (linkFileExtension === "jpg") || (linkFileExtension === "jpeg") || (linkFileExtension === "png");
      }).toArray().randomized().map(function(eachLink) {
        return eachLink.attribs.href;
      });
    });

    imageContentStreamTriedSuccessively = imageUrlsStream.flatMap(function(imageUrls) {
      var fileExtension, howMuchDelay, imageUrl, j, len, successiveTries;
      successiveTries = [];
      howMuchDelay = -3000;
      for (j = 0, len = imageUrls.length; j < len; j++) {
        imageUrl = imageUrls[j];
        howMuchDelay += 3000;
        fileExtension = helpSpace.getFileExtension(imageUrl);
        successiveTries.push((Observable.create(function(observer) {
          return helpSpace.downloadForBinary(imageUrl, function(successfullyDownloaded) {
            logger.log("Successfully downloaded " + imageUrl);
            observer.onNext([successfullyDownloaded, fileExtension]);
            return observer.onCompleted();
          }, function(failedDownload) {
            logger.log("Couldn't download " + imageUrl);
            return null;
          });
        })).delay(howMuchDelay));
      }
      return Observable.amb(successiveTries).defaultIfEmpty(Observable["throw"](new Error('Failed to retrieve reddit image content'))).first();
    });

    imageContentSaved = imageContentStreamTriedSuccessively.map(function(arg) {
      var filename, whichFileExtenstion, whichImageContent;
      whichImageContent = arg[0], whichFileExtenstion = arg[1];
      filename = "redwall." + whichFileExtenstion;
      fs.writeFile(filename, whichImageContent, {
        encoding: 'binary'
      }, function(err) {
        if (err) {
          throw new Error("image content not saved");
        }
      });
      return filename;
    }).take(1);

    imageContentHeard = imageContentSaved.map(function(whichFilename) {
      helpSpace.informOS(whichFilename);
      return whichFilename;
    });

    bigDance = imageContentHeard;

    return RedWall;

  })();

  HelpSpace = (function() {
    var exec, http, request;

    function HelpSpace() {}

    http = require("http");

    HelpSpace.downloadForBinary = function(url, successCallback, badnewsCallback) {
      return http.get(url, function(res) {
        var data;
        data = "";
        res.setEncoding('binary');
        res.on('data', function(chunk) {
          return data += chunk;
        });
        return res.on("end", function() {
          return successCallback(data);
        });
      }).on("error", function(e) {
        return badnewsCallback(e);
      });
    };

    request = require("request");

    HelpSpace.download = function(url, successCallback, badnewsCallback) {
      console.log("@ HelpSpace.download");
      return request({
        uri: url
      }, function(error, response, body) {
        if (error) {
          return badnewsCallback(error);
        } else {
          return successCallback(body);
        }
      });
    };

    HelpSpace.getFileExtension = function(fromLinkorText) {
      var linkHref;
      linkHref = fromLinkorText.attribs ? fromLinkorText.attribs.href : fromLinkorText;
      return linkHref.slice(linkHref.lastIndexOf('.') + 1);
    };

    exec = require('child_process').exec;

    HelpSpace.informOS = function(whichFilename) {
      var cmd, preciseFilename;
      preciseFilename = require('path').resolve(__dirname, whichFilename);
      cmd = "gsettings set org.gnome.desktop.background picture-uri file://" + preciseFilename + " &&\ngsettings set org.gnome.desktop.background picture-options scaled";
      return exec(cmd, function(error, stdout, stderr) {
        return null;
      });
    };

    return HelpSpace;

  })();

  new RedWall(HelpSpace);

}).call(this);
