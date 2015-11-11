(function() {
  var HelpSpace, Observable, RedWallV2, Rx, cheerio,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Rx = require("rx");

  cheerio = require("cheerio");

  Observable = Rx.Observable;

  RedWallV2 = (function() {
    var scope, theRoughIdea;

    theRoughIdea = "1. repeat lazy function\n	(fn [] (#download reddit page))\n2. buffer and grab\n3. map and execute\n4. filter success\n5. map to parsed list of image links\n6. download image\n7. emit byte array\n8. take only one\n";

    scope = null;

    function RedWallV2() {
      this.test = bind(this.test, this);
      console.log("@ constructor");
      scope = this;
      this.test();
    }

    RedWallV2.prototype.repeatLazyFunction = function() {
      console.log("@ repeatLazyFunction");
      return Observable.repeat(scope.generateLazyPageDownload()).take(1000);
    };

    RedWallV2.prototype.bufferAndGrab = function() {
      console.log("@ bufferAndGrab");
      return Observable.zip([scope.repeatLazyFunction(), Observable.interval(1000)]).filter(function(lazyFunc, i) {
        return (i === 0) || (i === 30) || (i === 180);
      });
    };

    RedWallV2.prototype.parseToDoc = function(whichString) {
      var $;
      console.log("@ parseToDoc");
      $ = cheerio.load(whichString);
      return $;
    };

    RedWallV2.prototype.generateLazyPageDownload = function() {
      var daysToPages, indexsToDays, todaysIndex, todaysUrl;
      console.log("@ generateLazyPageDownload");
      indexsToDays = {
        0: "monday",
        1: "tuesday",
        2: "wednesday",
        3: "thursday",
        4: "friday",
        5: "saturday",
        6: "sunday"
      };
      daysToPages = {
        "monday": "http://www.reddit.com/r/bikeporn",
        "tuesday": "http://www.reddit.com/r/spaceporn",
        "wednesday": "http://www.reddit.com/r/roomporn",
        "thursday": "http://www.reddit.com/r/cityporn",
        "friday": "http://www.reddit.com/r/earthporn",
        "saturday": "http://www.reddit.com/r/bikeporn",
        "sunday": "http://www.reddit.com/r/bikeporn"
      };
      todaysIndex = (new Date()).getDay();
      todaysUrl = daysToPages[indexsToDays[todaysIndex]];
      return Observable.create(function(observer) {
        return HelpSpace.download(todaysUrl, function(downloadedContent) {
          observer.onNext(downloadedContent);
          return observer.onCompleted();
        });
      }).map(scope.parseToDoc);
    };

    RedWallV2.prototype.test = function() {
      var whatWeveGot;
      console.log("testing");
      whatWeveGot = this.bufferAndGrab();
      return whatWeveGot.subscribe(function(emitted) {
        console.log("good");
        return console.log(emitted);
      }, function(fucked) {
        console.log("not good");
        return console.log(fucked);
      }, function() {
        console.log("done");
        return null;
      });
    };

    return RedWallV2;

  })();

  HelpSpace = (function() {
    var request;

    function HelpSpace() {}

    request = require("request");

    HelpSpace.download = function(url, callback) {
      console.log("@ HelpSpace.download");
      return request({
        uri: url
      }, function(error, response, body) {
        return callback(arguments);
      });
    };

    return HelpSpace;

  })();

  new RedWallV2();

}).call(this);
