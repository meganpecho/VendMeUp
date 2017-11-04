module.exports = function(grunt) {
	var serveStatic = require('serve-static');
	var modRewrite = require('connect-modrewrite');
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		sass: {
			dist: {
				files: {
					'build/style/main.css' : 'sass/main.scss'
				}
			},
			build: {
		        files: {
		            'build/style/main.css': 'sass/main.scss'
		        }
		    }
		},
		watch: {
			css: {
				files: '**/*.scss',
				tasks: ['sass']
			}
		},
		// serve: {
	 //        options: {
	 //            port: 9000
	 //        }
	 //    },
	 connect: {
	 	server: {
	      options: {
	        port: 8000,
	        open: true,
			base: ['./build/'],
			// middleware: function(connect, options) {
			// 	var middlewares;
			// 	middlewares = [];
			// 	middlewares.push(modRewrite(['^[^\\.]*$ /index.html [L]']));
			// 	options.base.forEach(function(base) {
			// 	  return middlewares.push(connect["static"](base));
			// 	});
			// 	return middlewares;
			// }
	        // base: {
	        //   path: 'www-root',
	        //   options: {
	        //     index: 'pages/index.html',
	        //     maxAge: 300000
	        //   }
	        // }
	      }
	    }
	  }
	});
	grunt.loadNpmTasks('grunt-contrib-sass');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-connect');
	// grunt.loadNpmTasks('grunt-serve');

	// grunt.registerTask('default', []);
	grunt.registerTask('serve', 'Sass then connect and watch', function () {
		grunt.task.run('sass', 'connect');
		grunt.task.run('watch');
	});

};