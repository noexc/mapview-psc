module.exports = function(grunt) {

  "use strict";

  grunt.initConfig({

    files: [
      "src/**/*.purs",
      "bower_components/purescript-*/src/**/*.purs",
      "bower_components/purescript-*/src/**/*.purs.hs"
    ],

    clean: {
      all: ["tmp", "output", "release"]
    },

    pscMake: {
      all: {
        src: "<%=files%>"
      }
    },

    uglify: {
      release: {
        files: {
          'release/html/index.js': ['html/index.js']
        }
      }
    },


    docgen: {
      readme: {
        src: "src/**/*.purs",
        dest: "API.md"
      }
    },

    copy: {
      main: {
        files: [
          {
            expand: true,
            cwd: "output",
            src: ["**"],
            dest: "tmp/node_modules/"
          },
          {
            src: ["js/index.js"],
            dest: "tmp/index.js"
          }
        ]
      },
      release: {
        files: [
          {
            expand: true,
            src: ["html/**"],
            dest: "release/"
          }
        ]
      }
    },

    browserify: {
      all: {
        src: ["tmp/index.js"],
        dest: "html/index.js"
      }
    }
  });

  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-purescript");
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask("default", ["pscMake:all", "copy:main", "browserify:all"]);
  grunt.registerTask("release", ["clean", "pscMake:all", "copy:main", "browserify:all", "copy:release", "uglify:release"]);
};
