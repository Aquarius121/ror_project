var zcClient = null;

var mCustomScrollbarSettings = {
  scrollInertia: 0,

  advanced: {
    autoScrollOnFocus: false,
    updateOnContentResize: true
  }
};

var isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0;

if (isMac)
  mCustomScrollbarSettings.mouseWheel = {
    deltaFactor: 1,
    scrollAmount: 1
  };

var maxMapWidth;
jQuery(function ($) {
  maxMapWidth = $('.logged-in #butler-map-holder').width() - 110;
});

function moveMapControls(open) {
  var $h = $('.logged-in #butler-map-holder');
  var blockWidth = $('.map-block-wrapper').outerWidth();
  var width = open ? maxMapWidth - blockWidth : maxMapWidth;
  var left = open ? 110 + blockWidth : 110;
  $h.width(width).css('left', left + "px");
  $('.logged-in #butler-map').width(width);
  google.maps.event.trigger(map.getMap(), 'resize');
}

function viewInLargeMap(id) {
  $('#saved_routes').find('option.null-option').remove();
  $('#saved_routes').val('').trigger('render');
  $('.navigation-wrapper, .navigation-wrapper-layer').addClass('hidden');
  $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
  $('.edit-download-send').show();
  routes.load(id);
}

function createRouteDivFromJson(route) {
  var currentElement = [];
  var template = $("#ride-template").html();
  var compiledHtml = $(_.template(template, {route: route}));
  if (route.id)
    currentElement = $('.my-rides-content [data-id="' + route.id + '"]');
  if (currentElement.length > 0) {
    currentElement.replaceWith(compiledHtml);
    $('.my-rides-content [data-id="' + route.id + '"] .img img').unveil();
  } else {
    $(".my-rides-content").prepend(compiledHtml).find(".img img").unveil();
  }
  currentUserRouteCountExceeded = route.route_count_exceeded;
  if (currentUserRouteCountExceeded) routes._setViewMode(true);
}

function copyRide() {
  var route_id = $(this).attr('data-id');
  var btn = $(this);
  if (!route_id) return false;
  var premiumCallback = function () {
    btn.attr("disabled", "disabled");
    if (btn.hasClass('toggle-copy-trip'))
      start_left_ajax_loader();
    else
      start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: '/routes/' + route_id + '/copy',
      dataType: 'json',
      success: function (route) {
        createRouteDivFromJson(route);
        $('#saved_routes').append('<option value="' + route.id + '">' + route.title + '</option>');
        routes.load(route.id);
        toastr.success('The ride has successfully been copied');
        if (btn.hasClass('toggle-copy-trip'))
          stop_left_ajax_loader();
        else
          stop_dashboard_ajax_loader();
        btn.removeAttr("disabled");
      }
    });

  };
  isPremium(premiumCallback);
  return false;
}

function closePopups() {
  $('.navigation-toggler .a-wrapper, .side-main-wrapper .a-wrapper').removeClass('active');
  $('.navigation-wrapper').addClass('hidden');
}

function closeLefties(skip) {
  (!skip || !skip.hasClass('map-block-wrapper')) && $('#ElevationsProfileChartHolder').hide();
  $('.map-layers-wrapper, .map-block-wrapper, .map-legend-wrapper').each(function () {
    var lefty = $(this);
    var elementToSkip = skip ? skip[0] : null;
    if (lefty[0] != elementToSkip) {
      var open = parseInt(lefty.css('left'), 10) == 110 && !lefty.hasClass('hidden');
      if (open) {
        var left = 110 - lefty.outerWidth() - 500;
        lefty.animate({
          left: left
        });
        if (lefty.hasClass('map-block-wrapper')) {
          moveMapControls(false);
        }
      }
    }
  });
  $('.side-main-wrapper > div.active').removeClass('active');
}

function leftPopupSlide(lefty, btn, moveControls, open) {
  var $elevationProfile = $('#ElevationsProfileChartHolder');
  var left;
  if (lefty.hasClass('map-block-wrapper')) {
    refreshTopForCloseLeftPopup();
  }
  if (lefty.hasClass('hidden')) {
    lefty.css('left', (parseInt(lefty.css('left'), 10) - lefty.outerWidth()) + 'px');
    lefty.removeClass('hidden');
  }
  if (open || parseInt(lefty.css('left'), 10) != 110) {
    left = 110;
  } else {
    left = 110 - lefty.outerWidth() - 500;
  }
  if (left == 110) {
    closePopups();
    closeLefties(lefty);
  }
  open = parseInt($('.map-block-wrapper').css('left'), 10) != 110 || open;
  if (moveControls && !open) {
    moveMapControls(open);
  }
  lefty.animate({
    left: left
  }, {
    done: function () {
      if (moveControls && open) {
        moveMapControls(open);
      }

      if (lefty.hasClass('map-block-wrapper')) {
        bmResizeEnd && bmResizeEnd();
        var leftOffset = left < 110 ? '110px' : '418px';
        $elevationProfile.css('left', leftOffset);
      }
    }
  });

  btn.toggleClass('active');
}


function start_left_ajax_loader() {
  $('.map-block-wrapper .ajax-loader').css('left', parseInt(($('.map-block-wrapper').outerWidth() / 2)) + 60 + "px");
  $('.map-block-wrapper .ajax-overlay').show();
}

function stop_left_ajax_loader() {
  $('.map-block-wrapper .ajax-overlay').hide();
}

function ajax_error_msg() {
  toastr.error('Oops, something was wrong');
}

function toggleButtonText(elt) {
  var elt_data = elt.attr("data-text");
  var elt_text = elt.text();
  elt.text(elt_data).attr("data-text", elt_text);
}

function refreshTopForCloseLeftPopup() {
  $('.map-block-wrapper .close').css('top', (parseInt($('.map-block-wrapper').css('height')) / 2) - 16 + 'px');
}

function suggestFriends($) {
  start_dashboard_ajax_loader();
  $.ajax({
    type: "GET",
    url: '/friendships/suggest.json',
    success: function (data) {
      $.each(data, function (i, user) {
        createFriendDiv(user);
      });
      stop_dashboard_ajax_loader();
    },
    error: function () {
      stop_dashboard_ajax_loader();
      ajax_error_msg();
    },
    dataType: 'json'
  });
}
jQuery(function ($) {
  $.ajaxSetup({
    timeout: 15000,
    error: function (event, request, settings) {
      stop_left_ajax_loader();
      stop_dashboard_ajax_loader();
      $('#cboxContent').find('.ajax-overlay').hide();
      ajax_error_msg();
    }
  });
  var $elevationProfile = $('#ElevationsProfileChartHolder');


  $(document).on('click', ".close-premium-account", function () {
    $.colorbox({html: '<div class="cbox-confirm-wrap"><div class="cbox-title">We are sorry to see you leave.</div> <div> Please view our refund policy in ' +
      '<a href="http://ridingsocial.com/terms-conditions/" target="_blank">our terms and conditions</a>. ' +
      'All sales are final. <br><br> Continue?<br></div><br><div class="cbox-buttons-wrap"><a class="cbox-button-confirm unsubscribe" href="#">Yes</a> <a class="close" href="#">No</a></div></div>'});

    $('#colorbox').on('click', '.cbox-button-confirm.unsubscribe', function () {
      $.colorbox.close();
      $('#ajax-update-profile').css('display', 'block');
      if (!$('.navigation-wrapper-layer').hasClass('hidden'))
        start_dashboard_ajax_loader();
      $.ajax({
        type: "POST",
        url: '/unsubscribe',
        success: function (data) {
          if (data.success) {
            location.reload();
            stop_dashboard_ajax_loader();
          } else {
            $('#ajax-update-profile').css('display', 'none');
            stop_dashboard_ajax_loader();
            toastr.error('Unsubscribe failed.');
          }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
          $('#ajax-update-profile').css('display', 'none');
          ajax_error_msg();
          stop_dashboard_ajax_loader();
        }
      });
    });
  });

  var ownRideWrapper = $('.popup-own-ride-wrapper-bg');

  $('.new-shared-rides-count').hover(
    function () {
      $(".my-rides-link").addClass("white");
    },
    function () {
      $(".my-rides-link").removeClass("white");
    }
  );

  $('.new-shared-rides-count').click(function () {
    $(".my-rides-link").click();

    var submitBtn = $(this).find('input[type=submit]');
    submitBtn.attr("disabled", "disabled");
    $(".my-rides-content").html('');
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      dataType: 'json',
      url: '/shared_rides/see_rides.json',
      success: function (data) {
        $.each(data, function (i, route) {
          createRouteDivFromJson(route);
        });
        submitBtn.removeAttr("disabled");
        $('.new-shared-rides-count').remove();
        stop_dashboard_ajax_loader();
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        submitBtn.removeAttr("disabled");
        stop_dashboard_ajax_loader();
        ajax_error_msg();
      }
    });
  });

  $('.user-menu-toggler').click(function () {
    $(this).find('.user-menu').toggleClass('hidden');
    $(this).find('.user-arrow-button').toggleClass('opened');
    $('.contact-button-container .contact-menu').addClass('hidden');
  });

  $('.contact-button-container').click(function () {
    $('.user-menu-toggler .user-menu').addClass('hidden');
    $('.user-menu-toggler .user-arrow-button').removeClass('opened');
    $(this).find('.contact-menu').toggleClass('hidden');
  });

  $('.plan-trip-link').click(function () {
    var btn = $(this).parent();
    leftPopupSlide($('.map-block-wrapper'), btn, true);
    var opened = btn.hasClass('active');
    !$elevationProfile.data('isClosed') && !waypoints.isNotReady() && $elevationProfile.animate(
      { width: opened ? 'show' : 'hide' },
      { done: bmResizeEnd }
    );
    return false;
  });

  $('.map-block-wrapper .close').click(function () {
    leftPopupSlide($('.map-block-wrapper'), $('.side-main-wrapper .plan-trip'), true);
    return false;
  });

  $('.legend-link').click(function () {
    leftPopupSlide($('.map-legend-wrapper'), $(this).parent());
    moveMapControls(false);
    return false;
  });

  function startCreatingNewRide(){
    if (currentUserRouteCountExceeded) {
      freeUserRideLimit();
      return false;
    }
    start_left_ajax_loader();
    $('#saved_routes').val('').trigger('render');
    $('.map-block-wrapper .route-title').html('New route');
    $('.navigation-wrapper').addClass('hidden');
    $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
    leftPopupSlide($('.map-block-wrapper'), $('.plan-trip-link').parent(), true, true);
    popupOpenNewRoute();
    $('.toggle-clear-trip').show();
    stop_left_ajax_loader();
  }

  function newRoute(){
    if (!waypoints.isNotReady()) {
      var deferred = clearRoute();
      deferred.done(startCreatingNewRide);
    } else {
      startCreatingNewRide();
    }
  }

  $('#new-route-main').on('click', function () {
    newRoute();
    return false;
  });

  function showSubscriptionPopup() {
    $('.premium-popup.navigation-wrapper').removeClass('hidden');
  }

  function showDashboardPopup() {
    $('.navigation-toggler.dashboard .navigation-wrapper').removeClass('hidden');
    $('.navigation-toggler.dashboard .a-wrapper').addClass('active');
  }

  function showAdditionalPopup(hash) {
    $('.account-popup').load('/users/additional #sign-div', function () {
      $(".account-popup select:not(.no-customselect)").customSelect();
      $(".account-popup").addClass('active').show();
      $(".sign-div-wrapper").mCustomScrollbar(mCustomScrollbarSettings);
      $(".account-close").show();
      if (hash && hash.length > 1) {
        window.walkThruRide = hash[1];
      }
    });
  }

  function parseHash(hash) {
    var removeHash = true;
    hash = hash.split('$'); // for #additional$route-1230
    switch (hash[0]) {
      case "#additional":
        showAdditionalPopup(hash);
        break;
      case "#dashboard":
        showDashboardPopup();
        break;
      case "#friendship-approve":
        showFriendsApproveTab();
        break;
      case "#subscription":
        showSubscriptionPopup();
        break;
      default:
        removeHash = false;
        break;
    }
    if (removeHash) location.hash = '';
  }

  $('.popup-rides-wrapper-bg').on('click', '.result-wrapper', function () {
    start_dashboard_ajax_loader();
    $.ajax({
      type: "GET",
      url: '/routes/' + $(this).attr('data-id') + '.json',
      success: function (data) {
        var rideWrapper = $('.popup-own-ride-wrapper-bg');
        rideWrapper.find('.see-comments a.see-comments-link').attr('data-id', data.id);
        rideWrapper.find('.download-garmin, .edit-ride, .view-large-map, .share-to-my-rides, .delete-ride, .send-offline').attr('data-id', data.id);
        rideWrapper.find('.share-to-my-rides').toggle(!data.owner);
        rideWrapper.find('.edit-ride, .send-offline').toggle(data.owner);
        rideWrapper.find('.embed-share').attr('href', '/shared_rides/new/' + data.id);
        rideWrapper.find('.title-info .title').html(data.title);
        rideWrapper.find('.distance .num').html(data.distance);
        rideWrapper.find('.time .num').html(data.time);
        rideWrapper.find('.date .num').html(data.ridedate);
        rideWrapper.find('.type .val').html(data.surface);
        rideWrapper.find('#description_ride').html(data.description);
        rideWrapper.find('.rating .num').html('');
        rideWrapper.find('.ride-comments').html('');
        if (data.encoded_path || data.ride_type_id == 4)
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
        $('.popup-rides-wrapper-bg').hide();
        rideWrapper.show();
      },
      dataType: 'json'
    });
    return false;
  });

  ownRideWrapper.on('click', '.see-comments a.see-comments-link', function () {
    var toggler = $(this);
    start_dashboard_ajax_loader();

    if (!$(this).hasClass("expanded")) {
      ownRideWrapper.find('.ride-comments').html('').load('/comments/new/' + $(this).attr('data-id') + ' #comment-ride-wrapper', function () {
        stop_dashboard_ajax_loader();
        toggler.toggleClass("expanded");
        toggleButtonText(toggler);
        return false;
      });
    }
    else {
      ownRideWrapper.find('.ride-comments').html('');
      stop_dashboard_ajax_loader();
      toggler.toggleClass("expanded");
      toggleButtonText(toggler);
    }

    return false;
  });

  ownRideWrapper.on('submit', '#new_comment', function () {
    var form = $(this);
    var id = form.find('#comment_related_id').val();
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: form.attr('action'),
      data: form.serialize(),
      success: function (data) {
        ownRideWrapper.find('.ride-comments').html('').load('/comments/new/' + id + ' #comment-ride-wrapper', function () {
          stop_dashboard_ajax_loader();
          return false;
        });
      },
      dataType: 'json'
    });
    return false;
  });

  ownRideWrapper.on('click', 'a.back-to-my-rides', function () {
    $('.popup-rides-wrapper-bg').show();
    ownRideWrapper.hide();
    return false;
  });

  $('.upload-gpx a.back-to-my-rides').on('click', function () {
    $('.upload-gpx').addClass('hidden');
    $('.navigation-wrapper.my-rides').removeClass('hidden');
    return false;
  });


  $('.trip-planner').on('click', '.show-elevation-profile', function () {
    $elevationProfile.show().data('isClosed', false);
  });
  $('.trip-planner').on('click', '.hide-elevation-profile', function () {
    $elevationProfile.hide().data('isClosed', true);
  });

  $('.map-block-wrapper').on('click', '.evaluation-button', function () {
    var hidden = $elevationProfile.filter(':visible').length == 0;
    $elevationProfile.animate({width: "toggle"}).data('isClosed', !hidden);
  });

  $elevationProfile.on('click', '.elevation-close', function () {
    $elevationProfile.animate({width: "toggle"}).data('isClosed', true);
  });

  $('body').on('change', '.account-popup .user-state', function () {
    $('.account-popup').find('#user_location').val($(this).val());
    var select = $('.account-popup').find('.user-city');
    var options = select.prop('options');
    select.val('').trigger('render');
    $('option:not([value=""])', select).remove();
    $.ajax({
      type: "GET",
      url: '/addresses/city/' + $(this).val() + '.json',
      success: function (data) {
        $.each(data, function (i, city) {
          options[options.length] = new Option(city, city);
        });
        select.trigger('render');
      }
    });
  });

  $('body').on('change', '.account-popup .user-city', function () {
    $('.account-popup').find('#user_location').val($('.account-popup').find('.user-state').val() + ', ' + $(this).val());
  });


  var accordionStatus = false;

  $('#map-block').bind("DOMSubtreeModified", function () {
    if ($(".route-accordion").length > 0 && !accordionStatus) {
      accordionStatus = true;
      $(".route-accordion").accordion({
        active: false,
        collapsible: true,
        heightStyle: "content",
        create: function (event, ui) {
          accordionStatus = false;
          $(".route-accordion").accordion("refresh").accordion('option', {active: false});
        }
      });
    }
  });

  $('body').on('click', '.devise-form-container .register-link, .restore-password-link, .invite-link', function () {
    $('body').find('.devise-form-container').load($(this).attr('href') + ' .devise-form-container>div', function () {
      signFormPos();
      $('#new_user select:not(.no-customselect), #edit_user select:not(.no-customselect)').customSelect();
      return false;
    });
    return false;
  });

  $('.edit-account a, .account-close').click(function () {
    toggleAccountPopup();
    $(this).parents('.user-menu').toggleClass('hidden');
    $('.user-menu-toggler').children('.user-arrow-button').removeClass('opened');
    return false;
  });

  var hidePopups = function () {
    $('.navigation-wrapper, .navigation-wrapper-layer').addClass('hidden');
    $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
  };

  $('.dashboard .update-profile-link, .dashboard .update-bikes .update-link').click(function () {
    var deferred = toggleAccountPopup();
    hidePopups();
    if ($(this).hasClass('update-link')) {
      deferred.done(function () {
        $('.sign-div-wrapper').mCustomScrollbar("scrollTo", $('.garage-field-wrapper').offset().top);
      });
    }
    return false;
  });

  $('.dashboard-left-bottom-item-body-rides .ride-wrapper a').click(function () {
    hidePopups();
    routes.load($(this).parents('.ride-wrapper').attr('data-id'));
    return false;
  });

  $('.dashboard-left-bottom-item-body-rides .see-all-rides-link').click(function () {
    var btn = $(this);
    var parent = btn.parents('.dashboard-left-bottom-item-body-rides');
    $.ajax({
      type: "POST",
      url: '/routes/show_own',
      success: function (data) {
        console.log(data);
        var routeLine;
        $.each(data, function (i, route) {
          routeLine = parent.find(".dashboard-ride-hidden .ride-wrapper").clone().appendTo(parent.find(".dashboard-rides-content"));
          routeLine.find('.user-avatar .avatar').attr('src', data.avatar);
          routeLine.find('.ride-date').html(route.ridedate);
          routeLine.find('.ride-title a').html(route.title).attr('href', '#route-' + route.id).on('click', function () {
            hidePopups();
            routes.load($(this).parents('.ride-wrapper').attr('data-id'));
            return false;
          });
          routeLine.find('.ride-difficulty-val').html('Hard');
          routeLine.find('.ride-distance').html(route.distance + 'mi');
          routeLine.attr('data-id', route.id);
        });
        btn.remove();
        parent.mCustomScrollbar(mCustomScrollbarSettings);
      },
      dataType: 'json'
    });
    return false;
  });

  $('body').on('click', '#share-ride-container a.popup-share-tabs-section-link', function () {
    var leftMargin = parseInt($(this).parents('.popup-share-tabs-section').offset().left) - parseInt($(this).parent('.popup-share-tabs-section-a-wrapper').offset().left);
    if (!$(this).parent('.popup-share-tabs-section-a-wrapper').hasClass('active')) {
      $('.popup-share-tabs-section-a-wrapper').removeClass('active');
      $(this).parents('.popup-share-tabs-section').find('.popup-share-tabs-section-content').addClass('hidden');
      $(this).parent('.popup-share-tabs-section-a-wrapper').addClass('active').find('.popup-share-tabs-section-content').first().css({"margin-left": leftMargin + "px"}).removeClass('hidden');
    } else if ($(this).parents('.navigation-toggler').find('.a-wrapper').hasClass('friendship-approve-active')) {
      $('.popup-share-wrapper-bg').removeClass('hidden');
      $(this).parents('.navigation-toggler').find('.a-wrapper').removeClass('friendship-approve-active');
    }
  });

  $('body').on('click', '#share-ride-container a.embed-edit-ride', function () {
    $(this).parents('#cboxContent').find('.colorbox-close.close').click();
    $('.map-block-wrapper .route-title').html('Edit route');
    $('.navigation-wrapper').addClass('hidden');
    $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
    var routeId = $(this).parents('#share-ride-container').attr('data-route-id');
    routes.load(routeId);
    showEditRouteForm(routeId);
    return false;
  });
  $('body').on('click', '#share-ride-container .embed-share a.popup-share-tabs-section-link', function () {
    var parent = $(this).parent();
    var generateEmbedCode = function () {
      var id = parent.parents("#share-ride-container").attr('data-route-id');
      var height = $('#embed-height', parent).val();
      var width = $('#embed-width', parent).val();

      var dimensions = ['width=', width, ' height=', height, ''].join('"');
      var src = ['src="', location.protocol, '//', location.host, '/embed/', id].join('');
      if (width < 640 && height < 640) src = src + ['?w=', width, '&h=', height].join('');
      src = src + '"';
      return ['<iframe', src, dimensions, 'frameBorder="0"></iframe>'].join(' ');
    };
    var setEmbedCode = function () {
      var code = generateEmbedCode();
      $("#embed-text", parent).text(code);
      $("a.embed-copy-clipboard", parent).attr('data-clipboard-text', code);
    };

    $('#embed-height, #embed-width', parent).keyup(setEmbedCode);
    setEmbedCode();

    ZeroClipboard.config({swfPath: swfPath, moviePath: swfPath});
    if (zcClient) zcClient.destroy();
    zcClient = new ZeroClipboard($("a.embed-copy-clipboard", parent)[0]);
    zcClient.on("complete", function (event) {
      toastr.success('Copied!');
    });
    zcClient.on("error noflash wrongflash", function (event) {
      $('.embed-copy-clipboard').hide();
      zcClient.destroy();
    });

    $("#embed-text", parent).on('focus', function () {
      var $this = $(this);
      $this.select();
      $this.mouseup(function () {
        $this.unbind("mouseup");
        return false;
      });
    });
  });

  $('.popup-friends-tabs-section-link').on('click', function () {
    var leftMargin = parseInt($(this).parents('.popup-friends-tabs-section').offset().left) - parseInt($(this).parent('.popup-friends-tabs-section-a-wrapper').offset().left);
    if (!$(this).parent('.popup-friends-tabs-section-a-wrapper').hasClass('active')) {
      $('.popup-friends-tabs-section-a-wrapper').removeClass('active');
      $(this).parents('.popup-friends-tabs-section').find('.popup-friends-tabs-section-content').addClass('hidden');
      $(this).parent('.popup-friends-tabs-section-a-wrapper').addClass('active').
        find('.popup-friends-tabs-section-content').
        first().
        css({"margin-left": leftMargin + "px"}).
        removeClass('hidden');

      var butlerRides = $(this).parent('.search-butler-rides').length > 0;
      var searchFriends = $(this).parent('.first').length > 0;
      if (butlerRides) {
        var noRidesAlreadyLoaded = $('.popup-butler-rides-tabs-form-result-content-wrapper .result-wrapper').length == 0;
        var form = $('.popup-butler-rides-tabs-form form');
        !$('input:submit', form).attr('disabled') && noRidesAlreadyLoaded && form.submit();
      }
      if (searchFriends) {
        var noFriendsAlreadyLoaded = $('.popup-friends-tabs-form-result-content-wrapper .result-wrapper').length == 0;
        noFriendsAlreadyLoaded && suggestFriends($);
      }
    } else if ($(this).parents('.navigation-toggler').find('.a-wrapper').hasClass('friendship-approve-active')) {
      $('.popup-friends-wrapper-bg-friendships-approve').addClass('hidden');
      $('.popup-friends-wrapper-bg').removeClass('hidden');
      $(this).parents('.navigation-toggler').find('.a-wrapper').removeClass('friendship-approve-active');
    }
  });

  $('.popup-rides-tabs-form form').submit(function () {
    var submitBtn = $(this).find('input[type=submit]');
    submitBtn.attr("disabled", "disabled");
    var myRidesContent = $(".my-rides-content");
    myRidesContent.html('');
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: {
        title: $(this).find('input.name').val(),
        location: $(this).find('input.location').val(),
        type: $(this).find('select.type').val()
      },
      success: function (data) {
        myRidesContent.hide();
        var template = $("#ride-template").html();
        $.each(data, function (i, route) {
          var compiledHtml = $(_.template(template, {route: route}));
          myRidesContent.prepend(compiledHtml);
        });
        myRidesContent.find(".img img").unveil();
        var firstFour = _($(".img img", myRidesContent)).first(4);
        _(firstFour).each(function (img) {
          var $img = $(img);
          if ($img.attr("src") != $img.data("src")) {
            $img.trigger("unveil")
          }
        });
        myRidesContent.show();
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

  $('.popup-rides-create-link').click(function () {
    startCreatingNewRide();
    return false;
  });


  $('.popup-rides-upload-link').click(function (e) {
    if (currentUserRouteCountExceeded) {
      freeUserRideLimit();
      return;
    }
    $('.navigation-wrapper').addClass('hidden');
    var $uploadGpx = $('.upload-gpx');
    var dropbox = $uploadGpx.find('#dropbox');
    $uploadGpx.removeClass('hidden').find('.successful-single-upload, .successful-multi-upload').addClass('hidden');
    $uploadGpx.find('#upload-status').html('');
    $uploadGpx.find('#dropbox, #dropbox .message').show();
    if (!dropbox.data('initialized')) {
      initializeGpxUploader(dropbox, {
        onUploadFinished: function (i, file, response) {
          $.data(file).addClass('done');
          if (response.length > 0) {
            toastr.success('File was uploaded.');
            _(response).each(function (route) {
              $('.upload-gpx .view-large-map').attr('data-id', route.id);
              createRouteDivFromJson(route);
            });
            $('.upload-gpx #upload-status').html('<b>Loaded: </b>' + _(response).map(function (r) {
              return r.title;
            }).join(', ') + ' track(s).');
            if (response.length == 1)
              $('.upload-gpx .successful-single-upload').removeClass('hidden');
            else
              $('.upload-gpx .successful-multi-upload').removeClass('hidden');

            $('.upload-gpx #dropbox').hide();
            $('.upload-gpx #dropbox .preview').remove();
          } else {
            toastr.error('Bad file.');
          }
        }
      });
      dropbox.data('initialized', true);
    }
  });

  $('.upload-gpx .upload-again').on('click', function () {
    var $uploadGpx = $('.upload-gpx');
    $uploadGpx.find('.successful-single-upload, .successful-multi-upload').addClass('hidden');
    $uploadGpx.find('#upload-status').html('');
    $uploadGpx.find('#dropbox, #dropbox .message').show();
  });

  $('.popup-own-ride-wrapper-bg').on('click', '.edit-ride', function () {
    $('#saved_routes').find('option.null-option').remove();
    $('#saved_routes').val('').trigger('render');
    $('.map-block-wrapper .route-title').html('Edit route');
    $('.navigation-wrapper').addClass('hidden');
    $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
    var routeId = $(this).attr('data-id');
    routes.load(routeId);
    showEditRouteForm(routeId);
    return false;
  });

  $('#user-nav .navigation li .own-club-left .back a').click(function () {
    $('.popup-club-wrapper-bg-own-club').addClass('hidden');
    $('.popup-club-wrapper-bg-create-club').addClass('hidden');
    $('.popup-club-wrapper-bg').removeClass('hidden');
    $(this).parents('.a-wrapper').removeClass('own-club-active');
    return false;
  });

  $('.view-help').click(function () {
    walkThruSite();
    $(this).parents('.user-menu-toggler').find('.user-menu').toggleClass('hidden');
    $(this).parents('.user-menu-toggler').find('.user-arrow-button').toggleClass('opened');
    return false;
  });

  $('.edit-subscription').click(function () {
    var wrapper = $('.premium-popup.navigation-wrapper');
    menuItemClick(wrapper);
    $(this).parents('.user-menu-toggler').find('.user-menu').toggleClass('hidden');
    $(this).parents('.user-menu-toggler').find('.user-arrow-button').toggleClass('opened');
    return false;
  });

  var menuItemClick = function (wrapper) {
    closeLefties();
    if (wrapper.hasClass('active')) {
      $('.navigation-wrapper-layer').addClass('hidden');
      wrapper.removeClass('active');
      wrapper.addClass('hidden');
    } else {
      $('.navigation-wrapper').addClass('hidden');
      wrapper.removeClass('hidden');
      $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
      $('.navigation-wrapper-layer').removeClass('hidden');
    }
    $('.back-search').addClass('hidden');
    $('.back-my-rides').addClass('hidden');
  };


  $('.contact-menu li a').click(function () {
    menuItemClick($('.' + $(this).data('container') + '-us-text'));
    $('.contact-menu').toggleClass('hidden');
    return false;
  });

  var noRidesAlreadyLoaded = true;

  $('.navigation-toggler .a-wrapper > a, .my-rides-link').click(function () {
    closeLefties();
    var aWrapper = $(this).parents('.a-wrapper');
    if (aWrapper.hasClass('active')) {
      if (aWrapper.hasClass('own-club-active')) {
        $('.popup-club-wrapper-bg-own-club').addClass('hidden');
        $('.popup-club-wrapper-bg-create-club').addClass('hidden');
        $('.popup-club-wrapper-bg').removeClass('hidden');
        aWrapper.removeClass('own-club-active');
      } else if (aWrapper.hasClass('friendship-approve-active')) {
        $('.popup-friends-wrapper-bg-friendships-approve').addClass('hidden');
        $('.popup-friends-wrapper-bg').removeClass('hidden');
        aWrapper.removeClass('friendship-approve-active');
      } else if (aWrapper.hasClass('my-rides')) {
        aWrapper.removeClass('active');
        $('.navigation-wrapper.my-rides').addClass('hidden');
      } else if (aWrapper.hasClass('butler-ride')) {
        $('.popup-own-butler-ride-wrapper-bg').addClass('hidden');
        $('.popup-friends-tabs-section').removeClass('hidden');
        aWrapper.removeClass('butler-ride');
      } else {
        $('.navigation-wrapper-layer').addClass('hidden');
        aWrapper.removeClass('active');
        $(this).parents('.navigation-toggler').children('.navigation-wrapper').addClass('hidden');
      }
    } else {
      $('.navigation-wrapper').addClass('hidden');
      if (aWrapper.hasClass('my-rides')) {
        $('.navigation-wrapper.my-rides').removeClass('hidden');
        var form = $('.popup-rides-tabs-form form');
        noRidesAlreadyLoaded && form.submit();
        noRidesAlreadyLoaded = false;
      } else {
        $(this).parents('.navigation-toggler').children('.navigation-wrapper').removeClass('hidden');
        var searchDiv = $(this).parents('.navigation-toggler.search');
        if (searchDiv.length > 0) {
          var searchFriends = $('.first.active', searchDiv).length > 0;
          var noFriendsAlreadyLoaded = $('.popup-friends-tabs-form-result-content-wrapper .result-wrapper').length == 0;
          searchFriends && noFriendsAlreadyLoaded && suggestFriends($);
        }
      }
      $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
      aWrapper.addClass('active');
      $('.navigation-wrapper-layer').removeClass('hidden');
    }
    $('.back-search').addClass('hidden');
    $('.back-my-rides').addClass('hidden');
    return false;
  });

  $('.popup-own-ride-wrapper-bg, .upload-gpx').on('click', '.view-large-map', function () {
    $('.back-my-rides').removeClass('hidden');
    viewInLargeMap($(this).attr('data-id'));
  });
  $('.popup-own-ride-wrapper-bg').on('click', '.share-to-my-rides', copyRide);
  $('.popup-own-ride-wrapper-bg').on('click', '.download-garmin', function () {
    var route_id = $(this).attr('data-id');
    if (!route_id) return false;
    if (F24E43D9 != '2E315E03') {
      getPremiumWindow();
    } else {
      window.location = "/routes/" + route_id + "/download";
    }
  });

  $('.popup-own-ride-wrapper-bg').on('click', '.send-offline', function () {
    var routeId = $(this).attr('data-id');
    if (!routeId) return false;
    routes.sendOffline(routeId);
    return false;
  });

  $('.back-my-rides').click(function () {
    $(this).removeClass('hidden');
    $('.navigation-wrapper.my-rides').removeClass('hidden');
    $('.my-rides.a-wrapper').addClass('active');
    $('.navigation-wrapper-layer').removeClass('hidden');
  });

  $('.cc-expiration').click(function () {
    $(this).addClass('hidden');
    showSubscriptionPopup();
    $.cookie('cc_expiration_seen', 'true', { expires: 15, path: '/' });
  });

  $('.navigation-wrapper-layer').click(function () {
    $(this).addClass('hidden');
    closePopups();
  });

  $('.navigation-wrapper .close').click(function () {
    $('.navigation-wrapper-layer').addClass('hidden');
    closePopups();
  });

  $('.embed-share').click(function () {
    $.colorbox({href: $(this).attr('href') + ' #share-ride-container'});
    return false;
  });

  var lastTimeCalled = new Date(1, 1, 2000, 12, 00, 00);
  var timeout = false, timeoutId;
  var delta = 500;
  $(window).resize(function () {
    lastTimeCalled = new Date();
    if (timeout === false) {
      timeout = true;
      timeoutId = setTimeout(resizeEnd, delta);
    }
  });

  function resizeEnd() {
    if (new Date() - lastTimeCalled < delta) {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(resizeEnd, delta);
    } else {
      timeout = false;

      var pageWidth = window.innerWidth;
//        var pageHeight = window.innerHeight;
//        var menuHeight = $("#map-block").height() + $("#user-nav").height();
//        var btnBottomValue = (pageHeight < menuHeight + 35) ? 0 : -35;
//        $(".evaluation-button").css("bottom", btnBottomValue);

      var elevationProfileWidth = $elevationProfile.width();

      // check width
      if (pageWidth > 1625) {
        (elevationProfileWidth < 900) && $elevationProfile.width(900);
      } else {
        var mapBlockOpened = $('.map-block-wrapper').css('left') == '110px';
        var indent = mapBlockOpened ? (418 + 45) : (110 + 45);  // map-block left position + close button :  sidebar left position + close button
        $elevationProfile.width(pageWidth - indent);
      }
    }
  }

  window.bmResizeEnd = resizeEnd;

  function initUnveilScrollBar(selector) {
    $(selector).mCustomScrollbar(_.extend({}, mCustomScrollbarSettings, {
      callbacks: {
        whileScrolling: function () {
          var scroller = $(".mCSB_container", this);
          var scrollerBox = scroller.closest(".mCustomScrollBox");
          var needToLoad = $(".img img", this).filter(function () {
            var $this = $(this);
            if ($this.attr("src") == $this.data("src")) return false;
            var scrollerTop = scroller.position().top;
            var scrollerHeight = scrollerBox.height();
            var offset = $this.closest("div.result-wrapper").position();
            return (offset.top < scrollerHeight - scrollerTop);
          });
          needToLoad.trigger("unveil");
        }
      }
    }));

  }

  function initScrollbars() {
    $('.add-custom-scroll').mCustomScrollbar(mCustomScrollbarSettings);
    $('.add-custom-dark-scroll').mCustomScrollbar(_.extend({theme: 'dark'}, mCustomScrollbarSettings));
    initUnveilScrollBar('.popup-rides-tabs-form-result-content, .popup-butler-rides-tabs-form-result-content');
  }

  function initCustomSelect() {
    $('.add-custom-select').customSelect();
    $('#new_user select:not(.no-customselect), #edit_user select:not(.no-customselect)').customSelect();
  }

  function init() {
    parseHash(window.location.hash);
    initScrollbars();
    initCustomSelect();

    if (!$('body').hasClass('anonymous')) {
      $.ajax({
        type: "POST",
        url: '/shared_rides/newsharecount.json',
        success: function (data) {
          if (data.count) {
            $('.new-shared-rides-count').text(data.count).show();
          }
        }
      });
    }

    $(".dashboard-left-bottom").accordion({
      header: ".dashboard-left-bottom-item-head", animate: "linear", icons: false
    });

    $.datepicker.formatDate("yy-mm-dd");
    $('.datepicker-input input').datepicker({currentText: "Now", dateFormat: "yy-mm-dd"});
    $(document).resize();
  }

  init();
});

function toggleAccountPopup(user_id) {
  var $account = $(".account-popup");
  if ($account.hasClass('active')) {
    $account.removeClass('active').hide();
    $(".account-close").hide();
    if ($account.children().hasClass('additional')) {
      walkThruSite();
    }
  } else {
    var deferred = $.Deferred();
    var url = '/users/edit' + (user_id ? '/' + user_id.toString() : '') + ' #sign-div';
    $('.account-popup').load(url, function () {
      $(".account-popup select:not(.no-customselect)").customSelect();
      $account.addClass('active').show();
      $(".sign-div-wrapper").mCustomScrollbar(mCustomScrollbarSettings);
      $(".account-close").show();
      deferred.resolve();
    });
    return deferred;
  }
}