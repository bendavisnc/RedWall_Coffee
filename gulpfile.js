(function() {
  var coffee, gulp, gutil, run, watch;

  gulp = require('gulp');

  gutil = require('gulp-util');

  run = require('gulp-run');

  coffee = require('gulp-coffee');

  watch = require('gulp-watch');

  gulp.task('default', [], function() {
    return gulp.src("./*.coffee").pipe(watch("./*.coffee")).pipe(coffee().on('error', gutil.log)).pipe(gulp.dest(".")).on('finish', function() {
      return gutil.log("compiling coffee");
    });
  });

}).call(this);
