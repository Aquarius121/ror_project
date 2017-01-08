function loadButlerRide(id) {
  start_dashboard_ajax_loader();
  $.ajax({
    type: "GET",
    url: '/routes/' + id + '.json',
    dataType: 'json',
    success: function (data) {
      if (data.ride_type_id == 5) {
        var rideWrapper = $('.popup-bdr-ride-wrapper-bg');
        rideWrapper.find('.see-comments a.see-comments-link').attr('data-id', data.id);
        rideWrapper.find('.download-garmin, .edit-ride, .view-large-map, .share-to-my-rides, .delete-ride, .send-offline').attr('data-id', data.id);
        rideWrapper.find('.share-to-my-rides').toggle(!data.owner);
        rideWrapper.find('.embed-share').attr('href', '/shared_rides/new/' + data.id);
        rideWrapper.find('.title-info .title').html(data.title);
        rideWrapper.find('.distance .num').html(data.distance);
        rideWrapper.find('.time .num').html(data.time);
        rideWrapper.find('.date .num').html(data.ridedate);
        rideWrapper.find('.type .val').html(data.surface);
        rideWrapper.find('#description_ride').html(data.description);
        rideWrapper.find('.rating .num').html('');
        rideWrapper.find('.ride-comments').html('');
        if (data.encoded_path)
          rideWrapper.find('.map-img .img').html('<img src="' + staticMapUrlForRoute(data) + '"/>');
        rideWrapper.find('.rating .num').raty({
          readOnly: true,
          score: data.rating,
          showHalf: true,
          starHalf: ratyConf.starHalf,
          starOff: ratyConf.starOff,
          starOn: ratyConf.starOn
        });
        if (data.images.length > 0) {
          var gallery = rideWrapper.find('.photos .photo-container');
          gallery.html('');
          $.each(data.images, function (i, img) {
            gallery.append('<div class="ride-thumb"><a href="#" class="thumbnail">' +
            '<img src="' + img.url + '"></a></div>');
          });
        } else {
          $('.photo-container').empty();
        }
        stop_dashboard_ajax_loader();

        $('.popup-friends-tabs-section').addClass('hidden');
        rideWrapper.removeClass('hidden');
        rideWrapper.parents('.navigation-toggler').find('.a-wrapper').addClass('butler-ride');
        $('.navigation-wrapper-layer').removeClass('hidden');
        rideWrapper.parents('.navigation-wrapper').removeClass('hidden');
        rideWrapper.show();
      } else {
        $('.popup-bdr-ride-wrapper-bg').addClass('hidden');
        var rideWrapper = $('.popup-own-butler-ride-wrapper-bg');
        rideWrapper.find('.see-comments a.see-comments-link').attr('data-id', data.id);
        rideWrapper.find('.view-large-map').attr('data-id', data.id);
        rideWrapper.find('.title-info .title').html(data.title);
        rideWrapper.find('.description').html(data.description);
        rideWrapper.find('.ride-comments').html('');
        $('.popup-friends-tabs-section').addClass('hidden');
        rideWrapper.removeClass('hidden');
        rideWrapper.parents('.navigation-toggler').find('.a-wrapper').addClass('butler-ride');
        $('.navigation-wrapper-layer').removeClass('hidden');
        rideWrapper.parents('.navigation-wrapper').removeClass('hidden');

        rideWrapper.find('.nearby-butler').addClass('hidden');
        var mapWrapper = rideWrapper.find('.popup-own-ride-right .map-img .img');
        if (data.encoded_path || data.ride_type_id == 4) {
          mapWrapper.html('<img src="' + staticMapUrlForRoute(data, '346x290') + '">')
        }
        if (data.ride_type_id == 4) {
          mapWrapper.empty().hide();
          $.ajax({
            type: "GET",
            url: '/routes/' + id + '/nearby.json',
            dataType: 'json',
            success: function (data) {
              var template = "<a data-id='<%=route.id %>' class='butler-ride-title'><%= route.title %></a>";
              rideWrapper.find('.nearby-rides').empty();
              _(data).each(function (butlerRide) {
                var compiledHtml = _.template(template, {route: butlerRide});
                rideWrapper.find('.nearby-rides').append($(compiledHtml));
              });
              rideWrapper.find('.nearby-butler').removeClass('hidden');
              stop_dashboard_ajax_loader();
            }
          });
        } else {
          mapWrapper.show();
          stop_dashboard_ajax_loader();
        }

        var imgWr = rideWrapper.find('.popup-own-ride-left .map-img');
        imgWr.html('<div class="img"></div>');
        if (data.images.length > 0) {
          var gallery = rideWrapper.find('.popup-own-ride-left .gallery');
          gallery.html('');
          var mainPhoto = data.images.shift();
          imgWr.html('<img src="' + mainPhoto.url + '" width="' + imgWr.find('.img, img').width() + 'px" >');
          $.each(data.images, function (i, img) {
            gallery.append('<img src="' + img.url + '">');
          });
        }
      }
    }
  });
}

jQuery(function ($) {

  $('.popup-butler-rides-tabs-form-result').on('click', '.result-wrapper', function () {
    loadButlerRide($(this).data('id'));
    $('.back .back-to-butler-rides').show();
    return false;
  });

  $('.popup-own-butler-ride-wrapper-bg').on('click', '.see-comments a.see-comments-link', function () {
    var toggler = $(this);
    start_dashboard_ajax_loader();

    if (!$(this).hasClass("expanded")) {
      $('.popup-own-butler-ride-wrapper-bg').find('.ride-comments').html('').load('/comments/new/' + $(this).attr('data-id') + ' #comment-ride-wrapper', function () {
        stop_dashboard_ajax_loader();
        toggler.toggleClass("expanded");
        toggleButtonText(toggler);
        return false;
      });
    }
    else {
      $('.popup-own-butler-ride-wrapper-bg').find('.ride-comments').html('');
      stop_dashboard_ajax_loader();
      toggler.toggleClass("expanded");
      toggleButtonText(toggler);
    }

    return false;
  });

  $('.popup-own-butler-ride-wrapper-bg').on('submit', '#new_comment', function () {
    var form = $(this);
    var id = form.find('#comment_related_id').val();
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: form.attr('action'),
      data: form.serialize(),
      success: function (data) {
        $('.popup-own-butler-ride-wrapper-bg').find('.ride-comments').html('').load('/comments/new/' + id + ' #comment-ride-wrapper', function () {
          stop_dashboard_ajax_loader();
          return false;
        });
      },
      dataType: 'json'
    });
    return false;
  });

  $('.popup-own-butler-ride-wrapper-bg').on('click', 'a.back-to-butler-rides', function () {
    $('.popup-friends-tabs-section').removeClass('hidden');
    $('.popup-own-butler-ride-wrapper-bg, .popup-bdr-ride-wrapper-bg').addClass('hidden').parents('.navigation-toggler').find('.a-wrapper').removeClass('butler-ride');
    return false;
  });

  $('.popup-bdr-ride-wrapper-bg').on('click', 'a.back-to-butler-rides', function () {
    $('.popup-friends-tabs-section').removeClass('hidden');
    $('.popup-own-butler-ride-wrapper-bg, .popup-bdr-ride-wrapper-bg').addClass('hidden').parents('.navigation-toggler').find('.a-wrapper').removeClass('butler-ride');
    return false;
  });

  $('.popup-butler-rides-tabs-form form').submit(function () {
    var submitBtn = $(this).find('input[type=submit]');
    submitBtn.attr("disabled", "disabled");
    $(".popup-butler-rides-tabs-form-result-content-wrapper").html('');
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: {
        title: $(this).find('input.name').val(),
        location: $(this).find('input.location').val(),
        ride_type: $(this).find('.type').val()
      },
      success: function (data) {
        $.each(data, function (i, route) {
          var template = $("#butler-ride-template").html();
          var compiledHtml = $(_.template(template, {route: route}));
          var content = $(".popup-butler-rides-tabs-form-result-content-wrapper");
          content.append(compiledHtml);
          $(".img img", content).unveil();
          var firstFour = _($(".img img", content)).first(4);
          _(firstFour).each(function (img) {
            var $img = $(img);
            if ($img.attr("src") != $img.data("src")) {
              $img.trigger("unveil")
            }
          });
        });
        submitBtn.removeAttr("disabled");
        stop_dashboard_ajax_loader();
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        submitBtn.removeAttr("disabled");
        stop_dashboard_ajax_loader();
        ajax_error_msg();
      },
      dataType: 'json'
    });
    return false;
  });

  $('.popup-own-butler-ride-wrapper-bg').on('click', '.view-large-map', function () {
    $('.back-search').removeClass('hidden');
    viewInLargeMap($(this).attr('data-id'));
  });

  $('.popup-bdr-ride-wrapper-bg').on('click', '.view-large-map', function () {
    $('.back-search').removeClass('hidden');
    viewInLargeMap($(this).attr('data-id'));
  });

  $('.popup-bdr-ride-wrapper-bg').on('click', '.download-garmin', function () {
    var route_id = $(this).attr('data-id');
    if (!route_id) return false;
    if (F24E43D9 != '2E315E03') {
      getPremiumWindow();
    } else {
      window.location = "/routes/" + route_id + "/download";
    }
  });

  $('.back-search').click(function () {
    $(this).removeClass('hidden');
    $(this).parents('.navigation-toggler').children('.navigation-wrapper').removeClass('hidden');
    $(this).parents('.a-wrapper').addClass('active');
    $('.navigation-wrapper-layer').removeClass('hidden');
  });

  $('.popup-own-butler-ride-wrapper-bg').on('click', 'a.butler-ride-title', function () {
    loadButlerRide($(this).attr('data-id'));
  });

});