var message;

var imageTemplate = '<div class="preview">' +
  '<span class="imageHolder">' +
  '<img />' +
  '<span class="uploaded"></span>' +
  '</span>' +
  '<div class="progressHolder">' +
  '<div class="progress"></div>' +
  '</div>' +
  '</div>';

var fileTemplate = '<div class="preview">' +
  '<span class="imageHolder">' +
  '<span class="uploaded"></span>' +
  '</span>' +
  '<div class="progressHolder">' +
  '<div class="progress"></div>' +
  '</div>' +
  '</div>';

function createImage(file, dropbox) {

  var preview = $(imageTemplate),
    image = $('img', preview);

  var reader = new FileReader();

  image.width = 100;
  image.height = 100;

  reader.onload = function (e) {

    // e.target.result holds the DataURL which
    // can be used as a source of the image:

    image.attr('src', e.target.result);
  };

  // Reading the file as a DataURL. When finished,
  // this will trigger the onload function above:
  reader.readAsDataURL(file);

  message.hide();
  preview.appendTo(dropbox);

  // Associating a preview container
  // with the file, using jQuery's $.data():

  $.data(file, preview);
}

function createProgressbar(dropbox, file) {
  var preview = $(fileTemplate);
  message.hide();
  preview.appendTo(dropbox);
  $.data(file, preview);
}

function showMessage(msg) {
  message.html(msg);
}

/*options = url, onUploadFinished, maxFilesCount, validation, onUploadStarted*/
function initializeFileUploader(dropbox, options) {
  message = $('.message', dropbox);
  dropbox.filedrop({
    // The name of the $_FILES entry:
    paramname: 'file',
    fallback_id: 'fallback',
    maxfiles: options.maxFilesCount || 1,
    maxfilesize: options.maxfilesize || 2,
    url: options.url,

    uploadFinished: options.onUploadFinished,
    uploadStarted: options.onUploadStarted,
    headers: {'X-CSRF-Token': $("meta[name='csrf-token']").attr("content")},

    afterAll: function () {
      setTimeout($.colorbox.close, 1500);
    },

    error: function (err, file) {
      switch (err) {
        case 'BrowserNotSupported':
          showMessage('Your browser does not support HTML5 file uploads!');
          break;
        case 'TooManyFiles':
          alert('Too many files! Please select ' + this.maxfiles + ' at most!');
          break;
        case 'FileTooLarge':
          alert(file.name + ' is too large! Please upload files up to ' + this.maxfilesize + 'mb.');
          break;
        default:
          break;
      }
    },

    // Called before each upload is started
    beforeEach: function (file) {
      if (!options.validation.fileIsValid(file)) {
        alert(options.validation.message);
        // Returning false will cause the
        // file to be rejected
        return false;
      }
    },

    progressUpdated: function (i, file, progress) {
      $.data(file).find('.progress').width(progress);
    }
  });
}

function initializeGpxUploader(dropbox, options) {
  var uploaderOptions = _.extend({
    validation: {
      fileIsValid: function (file) {
        return file.name.match(/\.gpx$/i) ||
          file.name.match(/\.kml$/i) ||
          file.name.match(/\.kmz$/i);
      },
      message: 'Only GPX files are allowed!'
    },
    type: 'gpx',
    onUploadStarted: function (i, file, len) {
      createProgressbar(dropbox, file);
    },
    url: '/routes/upload.json',
    maxfilesize: 5
  }, options);
  initializeFileUploader(dropbox, uploaderOptions);
}
