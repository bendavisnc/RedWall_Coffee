gulp = require('gulp')
gutil = require('gulp-util')
run = require('gulp-run')
coffee = require('gulp-coffee')
watch = require('gulp-watch')



gulp.task('default', [], () ->
	gulp.src("./*.coffee")
		.pipe(watch("./*.coffee"))
		.pipe(coffee().on('error', gutil.log))
		.pipe(gulp.dest("."))
		.on('finish', () ->
			gutil.log("compiling coffee") # Note, why doesn't this work?
		)
	)

