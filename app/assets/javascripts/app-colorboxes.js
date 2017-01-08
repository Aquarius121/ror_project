var clearRoute, clearPromise;
jQuery(function ($) {

  var body = $('body');
  var cbox = $('#colorbox');
  var cbox_delay = 1;
  var clearPromise;

  cbox.removeAttr('tabindex');

  $('#cboxContent').prepend($('.overlay').html()).append('<div class="colorbox-close close">X</div>');
  var cbox_overlay = $('#cboxContent').find('.ajax-overlay');

  $(document).bind('cbox_closed', function () {
    $('#cboxContent').removeClass('orange');
  });

  $(document).bind('cbox_load', function () {
    if ($('#cboxClose').length) {
      $('#cboxClose').remove();
      cbox_overlay.show();
    }
  });

  $(document).bind('cbox_complete', function () {
    var wrap;

    $('#cboxContent').addClass('orange');
    cbox.find('.all-comments').mCustomScrollbar(mCustomScrollbarSettings);
    if (cbox.width()!=792) $.colorbox.resize();
    wrap = cbox.find('#share-ride-wrapper');
    var dropbox = cbox.find('#dropbox');
    var dropboxImageHandlers = [
      {
        classname: 'user-avatar',
        url: '/avatars.json',
        onUploadFinished: function (i, file, response) {
          var form = $('body').find('#edit_user, #new_user');
          $.data(file).addClass('done');
          if (response.status) {
            form.find('.field-wrapper.avatar img').remove();
            form.find('#user_avatar_id').val(response.avatarid);
            form.find('.field-wrapper.avatar').prepend('<img src="' + response.url + '">');
            toastr.success('Avatar was uploaded.');
          } else {
            toastr.error('Bad file.');
          }
          $(".sign-div-wrapper").mCustomScrollbar("scrollTo", 0);
        }
      },
      {
        classname: 'club-logo',
        url: '/clubs/logoupload.json',
        onUploadFinished: function (i, file, response) {
          var wrap = $('.popup-club-wrapper-bg-create-club');
          var form = wrap.find('#new_club');
          $.data(file).addClass('done');
          if (response.status) {
            wrap.find('.img-wrapper img.club-img').remove();
            wrap.find('.img-wrapper img.club-img-reserved').hide();
            form.find('#club_logo_id').val(response.logoid);
            wrap.find('.img-wrapper').prepend('<img src="' + response.url + '" class="club-img" height="116px" width="116px">');
            toastr.success('Logo was uploaded.');
          } else {
            toastr.error('Bad file.');
          }
        }
      },
      {
        classname: 'ride-photo',
        url: 'routes/upload_img/' + dropbox.attr('data-route-id') + '.json',
        onUploadFinished: function (i, file, response) {
          $.data(file).addClass('done');
          var wrap = body.find('.route-photo .route-photo-wrapper');
          if (response.status) {
            wrap.append('<li class="photo-wrapper">' +
              '<a href="#" class="del-img" data-photo-id="' + response.avatarid + '">x</a>' +
              '<img src="' + response.url + '" data-full-url="' + response.bigUrl + '">');
            toastr.success('Upload successful');
          } else {
            toastr.error('Bad file.');
          }
        },
        maxFilesCount: 10
      }
    ];
    if (wrap.length) {
      $.ajax({
        type: "POST",
        url: '/shared_rides/sharegetfriends/' + wrap.attr('data-route-id'),
        success: function (data) {
          cbox_overlay.hide();
          var input = cbox.find('#shared_ride_friend');
          input.tokenInput(data.friends, {
            prePopulate: data.shared,
            theme: "facebook",
            queryParam: 'name',
            preventDuplicates: true,
            onAdd: function (item) {
              parent.$.colorbox.resize();
            },
            onDelete: function (item) {
              parent.$.colorbox.resize();
            },
            onReady: function (item) {
              parent.$.colorbox.resize();
            }
          }).focus();

        },
        dataType: 'json'
      });
      $.ajaxSetup({ cache: true });
      $.getScript('//connect.facebook.net/en_US/all.js', function () {
        FB.init({
          appId: '595428443887130'
        });
      });
      $.ajaxSetup({ cache: false });
    } else if (dropbox.length) {
      $.each(dropboxImageHandlers, function () {
        var options = _.extend({
          validation: {
            fileIsValid: function (file) {
              return file.type.match(/^image\//)
            },
            message: 'Only images are allowed!'
          },
          onUploadStarted: function (i, file, len) {
            createImage(file, dropbox);
          }
        }, this);
        if (dropbox.hasClass(this.classname))
          initializeFileUploader(dropbox, options);
      });
      cbox_overlay.hide();
    } else {
      cbox_overlay.hide();
    }
  });

  body.on('click', '.add-announcement a', function () {
    $.colorbox({href: $(this).attr('href') + ' #add-announcement-wrapper'});
    return false;
  });

  body.on('click', '.approve-members a', function () {
    $.colorbox({href: $(this).attr('href') + ' #approve-members-form'});
    return false;
  });

  cbox.on('submit', '#approve-members-form form', function () {
    var form = $(this);
    cbox_overlay.show();
    $.ajax({
      type: "POST",
      url: form.attr('action') + '.json',
      data: form.serialize(),
      success: function (data) {
        if (data.approve_count > 0) {
          $('.popup-club-wrapper-bg-own-club').find('.approve-members span').html(data.approve_count);
        } else {
          $('.popup-club-wrapper-bg-own-club').find('.approve-members').remove();
        }
        cbox_overlay.hide();
        setTimeout($.colorbox.close, cbox_delay);
      },
      dataType: 'json'
    });
    return false;
  });

  body.on('click', '.dropbox-upload-popup', function () {
    $.colorbox({html: '<div id="dropbox" class="user-avatar">' +
      '<span class = "message">' +
      'Drop images here to upload.' +
      '<br><i>(they will only be visible to you)</i>' +
      '<br>Or use this button <input type="file" id="fallback">' +
      '</span>' +
      '</div>'});
    return false;
  });

  $('#map-block').on('click', '.add-photo-to-ride', function () {
    $.colorbox({html: '<div id="dropbox" class="ride-photo" data-route-id="' + $(this).attr('data-route-id') + '">' +
      '<span class = "message">' +
      'Drop images here to upload.  Max 10 images.' +
      '<br><i>(they will only be visible to you)</i>' +
      '<br>Or use this button <input type="file" id="fallback">' +
      '</span></div>'});
    return false;
  });


  $('#map-block').on('click', '.photo-wrapper img', function () {
    body.find('.photo-wrapper img').each(function () {
      $(this).colorbox({rel: '.photo-wrapper img', href: $(this).attr('data-full-url'), transition: "none", maxWidth: "75%", maxHeight: "75%"});
    });
  });

  $('.popup-own-butler-ride-wrapper-bg .popup-own-ride-left').on('click', '.map-img img', function () {
    $('.popup-own-butler-ride-wrapper-bg .popup-own-ride-left').find('.gallery img, .map-img img').each(function () {
      $(this).colorbox({rel: '.gallery img, .map-img img', href: $(this).attr('src'), transition: "none", maxWidth: "75%", maxHeight: "75%"});
    });
  });

  $('.popup-own-ride-block.photos').on('click', '.thumbnail', function () {
    $('.popup-own-ride-block.photos img').each(function () {
      $(this).colorbox({rel: '.popup-own-ride-block.photos img', href: $(this).attr('src'), transition: "none", maxWidth: "75%", maxHeight: "75%"});
    });
  });

  $('#map-block').on('click', '.photo-wrapper .del-img', function () {
    $.colorbox({html: '<div class="cbox-confirm-wrap"><div class="cbox-title">Are you sure you want to Delete this image?</div><div class="cbox-buttons-wrap"><a class="cbox-button-confirm del-route-img-confirm" href="#" data-photo-id="' + $(this).attr('data-photo-id') + '">Yes</a> <a class="close" href="#">No</a></div></div>'});
    return false;
  });

  cbox.on('click', '.del-route-img-confirm', function () {
    cbox_overlay.show();
    var id = $(this).attr('data-photo-id');
    $.ajax({
      type: "POST",
      url: '/routes/delete_img/' + id + '.json',
      success: function (data) {
        $('#map-block').find('.route-photo-wrapper .photo-wrapper a[data-photo-id="' + id + '"]').parents('.photo-wrapper').remove();
        cbox_overlay.hide();
        $.colorbox.close();
      },
      dataType: 'json'
    });
    return false;
  });

  $('.popup-club-wrapper-bg-create-club .img-wrapper').click(function () {
    $.colorbox({html: '<div id="dropbox" class="club-logo">' +
      '<span class = "message">' +
      'Drop images here to upload.' +
      '<br><i>(they will only be visible to you)</i>' +
      '<br>Or use this button <input type="file" id="fallback">' +
      '</span></div>'});
    return false;
  });

  cbox.on('submit', '#new_announcement', function () {
    var form = $(this);
    cbox_overlay.show();
    $.ajax({
      type: "POST",
      url: form.attr('action') + '.json',
      data: form.serialize(),
      success: function (data) {
        setTimeout($.colorbox.close, cbox_delay);
        cbox_overlay.hide();
        loadAnnouncements(data.club_id);
      },
      dataType: 'json'
    });
    return false;
  });

  body.on('click', '#map-block .share a', function () {
    $.colorbox({href: $(this).attr('href') + ' #share-ride-container'});
    return false;
  });

  body.on('click', '.comment-ride', function () {
    $.colorbox({href: $(this).attr('href') + ' #comment-ride-wrapper'});
    return false;
  });

  cbox.on('submit', '#new_shared_ride, #new_comment', function () {
    var form = $(this);
    cbox_overlay.show();
    $.ajax({
      type: "POST",
      url: form.attr('action'),
      data: form.serialize(),
      success: function (data) {
        setTimeout($.colorbox.close, cbox_delay);
        cbox_overlay.hide();
        if (form.hasClass('new_comment')) {
          var text = "<li>" +
            "<div>" + data.author + "</div>" +
            "<div>" + data.body + "</div>" +
            "</li>";
          $('#map-block').find('.route-accordion-holder .comment-list').append(text);
        }
      },
      dataType: 'json'
    });
    return false;
  });

  clearRoute = function(){
    clearPromise = $.Deferred();
    $.colorbox({
      html: '<div class="cbox-confirm-wrap"><div class="cbox-title">Are you sure you want to Clear?</div><div class="cbox-buttons-wrap"><a class="cbox-button-confirm toggle-clear-trip" href="#">Yes</a> <a class="close" href="#">No</a></div></div>',
    });
    return clearPromise;
  };

  $(document).on('click', '.controls-clear', function () {
    clearRoute();
    return false;
  });

  cbox.on('click', '.toggle-clear-trip', function () {
    if (routes.isEditable()) {
      !routes.getInEditForm() && routes.clear();
      if (routes.getInEditForm()) {
        waypoints.removeViaPoints();
        routes.build();
      } else {
        waypoints.clear();
      }
      directions.reset();
    }
    $.colorbox.close();
    clearPromise.resolve();
    return false;
  });

  $('.delete-ride').on('click', function () {
    var rideId = $(this).attr('data-id');
    $.colorbox({html: '<div class="cbox-confirm-wrap"><div class="cbox-title">Are you sure you want to delete this ride?</div><br><div class="cbox-buttons-wrap"><a class="cbox-button-confirm delete-ride" href="#" data-id="' + rideId + '">Yes</a> <a class="close" href="#">No</a></div></div>'});
    return false;
  });

  cbox.on('click', '.delete-ride', function () {
    var rideId = $(this).attr('data-id');
    start_dashboard_ajax_loader();
    $.colorbox.close();
    $.ajax({
      type: "DELETE",
      url: '/routes/' + rideId + '.json',
      dataType: 'json',
      success: function (data) {
        currentUserRouteCountExceeded = data.route_count_exceeded;
        routes._setViewMode(currentUserRouteCountExceeded);
        $('.my-rides-content .result-wrapper[data-id="' + rideId + '"]').remove();
        $('.popup-own-ride-left .back-to-my-rides').click();
        stop_dashboard_ajax_loader();
        var option = $('#saved_routes').find("option[value='" + rideId + "']");
        if (routes.getRouteId() == rideId) {
          waypoints.clear();
          routes.clear();
          directions.reset();
          $('#saved_routes').val('').trigger('render');
          $('.map-block-wrapper .route-title').html('New route');
          $('.navigation-wrapper').addClass('hidden');
          $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
          $('.toggle-clear-trip').show();
          option.remove();
          window.location.hash = "";
        }
        option.remove();
        $('#saved_routes').trigger('render');
        toastr.success('Ride was deleted.');
      },
      error: function () {
        stop_dashboard_ajax_loader();
        toastr.error('Access not granted.');
      }
    });
    return false;
  });


  cbox.on('click', '.close', function () {
    $.colorbox.close();
    if (clearPromise) {
      clearPromise.reject();
      clearPromise = null;
    }
    cbox_overlay.hide();
    return false;
  });

  $(".controls .controls-polygon").click(function () {
    if (routes.getAlert() && !waypoints.isInPolylineMode()) {
      var html = '<div class="cbox-confirm-wrap">' +
        '<div class="cbox-title"><h2>Be Careful</h2></div>' +
        '<div>Switching to line mode means that your points no longer follows designated trails and roads. ' +
        'The elevation profiile and times can only be esimated. <br/> <br/> Just so you know.</p></div>' +
        '<div class="cbox-buttons-wrap"><a class="close" href="#">Ok</a></div>' +
        '</div>';
      $.colorbox({ html: html });
      routes.resetAlert();
    }

    var isActive = $(this).toggleClass("active").hasClass("active");
    waypoints.setPolylineMode(isActive);
  });
});