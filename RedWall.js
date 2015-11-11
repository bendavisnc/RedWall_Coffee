(function() {
  var Observable, RedWall;

  Observable = Rx.Observable;

  RedWall = (function() {
    var scope, theRoughIdea, todaysFetchedDoc;

    theRoughIdea = "get-day -->\n	get-index -->\n		get-url -> try-in-three-x-second-spans --> -- fetch-reddit-doc -->\n				get-image-links\n\n			until-success-or-x-tries -->\n				download-image -->\n					save-image -->\n						.";

    scope = RedWall.prototype;

    function RedWall() {
      null;
    }

    RedWall.prototype.getDay = function() {
      return new Date();
    };

    RedWall.prototype.getIndex = function(fromWhichDay) {
      return fromWhichDay.getDay();
    };

    RedWall.prototype.getUrl = function(fromWhichIndex) {
      var daysToPages, indexsToDays;
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
        "monday": "https://www.reddit.com/r/bikeporn",
        "tuesday": "https://www.reddit.com/r/spaceporn",
        "wednesday": "https://www.reddit.com/r/roomporn",
        "thursday": "https://www.reddit.com/r/cityporn",
        "friday": "https://www.reddit.com/r/earthporn",
        "saturday": "https://www.reddit.com/r/bikeporn",
        "sunday": "https://www.reddit.com/r/bikeporn"
      };
      return daysToPages[indexsToDays[fromWhichIndex]];
    };

    RedWall.prototype.getImageLinks = function(fromWhichUrl) {
      var downloadContent;
      downloadContent = null;
      return "data";
    };

    RedWall.prototype.tryInThreeXSecondSpans = function(xSeconds, whichUrl, whichAction) {
      return Observable.interval(xSeconds * 1000).map(whichAction(whichUrl)).startWith(whichAction(whichUrl));
    };

    todaysFetchedDoc = Observable["return"](scope.getDay()).map(scope.getIndex).map(scope.getUrl).map(function(theUrl) {
      return scope.tryInThreeXSecondSpans(3, theUrl, scope.getImageLinks);
    });

    RedWall.prototype.todaysSubscription = todaysFetchedDoc.subscribe(function(e) {
      window.testObj = e;
      return console.dir(e);
    });

    return RedWall;

  })();

  new RedWall();

}).call(this);
