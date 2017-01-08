var routes, map, optimizationAllowed = false, preserveViewport = true, directions;

var debugMode = document.cookie.indexOf('debugshow') != -1;
var logMsg = function () {
  if (!debugMode) {
    return;
  }
  console.log(arguments);
};

function saveNewRoute(){
  $('.toggle-save-trip, .toggle-clear-trip, .activity, .edit-controls').hide();
  $('.trip-planner-form').show();
  start_left_ajax_loader();
  $('.trip-planner-form').load('/routes/new .new_route', function () {
    $('.trip-planner-form select').customSelect();
    moveMapControls(true);
    $('.datepicker-input input').datepicker({dateFormat: "yy-mm-dd"});
    $('.cancel-edit').off().on('click', function () {
      routes.setInEditForm(false);
      $('.toggle-save-trip, .activity, .edit-controls').show();
      $('.trip-planner-form').hide();
      return false;
    });
    stop_left_ajax_loader();
  });
}


function popupOpenNewRoute() {
  waypoints.setPolylineMode(false);
  $('.back-my-rides').addClass('hidden');

  window.location.hash = "";
  $('#map-block .share').html('');
  $('.toggle-save-trip').removeClass('not-owner').show();
  $('.toggle-copy-trip, .routes-param').hide();
  $('.trip-planner-form, .show-controls, .select-route').hide();
  $('.edit-controls, .start-end-points').show();
  //$('.start-end-points, .additional-way-options').hide();

  routes.clear();
  waypoints.clear();
  directions.reset();

  $('.route-accordion-holder').hide();
  $('.trip-planner, .trip-planner-form').html('');
  $('.route-accordion-holder .route-accordion>:not(.waypoints)').remove();
  $('#saved_routes').find('option.null-option').remove();

  $('.toggle-save-trip').off('click').click(function () {
    $(this).hide();
    saveNewRoute();
    return false;
  });

  //$(".routes-param.controls").show();
  $(".routes-param.controls .controls-polygon").removeClass("active");
}
function getEncodedPath() {
  var routeDirections = directions.getDirectionsRenderer().getDirections();
  if (!routeDirections) {
    return waypoints.isInPolylineMode() ?
      google.maps.geometry.encoding.encodePath(directions.getPath().getPath())
      :
      '';
  }
  var route = routeDirections.routes[0];
  return route.overview_polyline.points || route.overview_polyline;
}

function staticMapUrlForRoute(route, size, format) {
  size = size || '608x358';
  format = format || 'jpg';
  if (route.encoded_path) {
    return [
      "https://maps.google.com/maps/api/staticmap?size=", size,
      "&maptype=roadmap&format=", format,
      "&path=weight:7|color:0xD76020FF|enc:", route.encoded_path
    ].join('');
  } else {
    return [
      "https://maps.google.com/maps/api/staticmap?size=", size,
      "&maptype=roadmap&format=", format,
      "&zoom=12&center=", route.start_location
    ].join('');
  }
}

function showEditRouteForm(routeId) {
  routes.setInEditForm(true);
  start_left_ajax_loader();
  $('.controls .controls-polygon').toggleClass('active', waypoints.isInPolylineMode());
  $('.navigation-wrapper, .navigation-wrapper-layer, .back-my-rides').addClass('hidden');
  $('.navigation-toggler .a-wrapper, .a-wrapper.my-rides').removeClass('active');
  $('.activity').hide();

  $('.trip-planner-form').load('/routes/' + routeId + '/edit .edit_route', function () {
    $('.trip-planner-form select').customSelect();
    $('.route-accordion-holder, .trip-planner, .share, .edit-download-send').hide();
    moveMapControls(true);
    $('.datepicker-input input').datepicker({dateFormat: "yy-mm-dd"});
    $('.toggle-save-trip, .toggle-clear-trip').hide();
    $('.trip-planner-form').show();
    stop_left_ajax_loader();
    var isOwner = !$('.toggle-save-trip').hasClass('not-owner');
    directions.getPath() && map.fitBounds(map.newBoundsFromRoute(directions.getPath()));
    if (isOwner && routes.isEditable()) {
      directions.setPathMode(0);
      routes._setViewMode(false);
      waypoints.toggleDraggable();
      $('.edit-controls, .controls').show();
      $('.start-end-points, .additional-way-options').hide();
    } else {
      toastr.warning('Please note the routes uploaded via GPX or the app that are "ridden by me" are not editable. Only the names and descriptions are editable for these route types.', '',
        {timeOut: 30000});
    }
    $('.cancel-edit').off().on('click', function () {
      viewInLargeMap(routeId);
    });
  });
}

jQuery(function ($) {
  if (!document.getElementById('butler-map')) {
    return;
  }

  $('.toggle-save-trip').click(function () {
    saveNewRoute();
    return false;
  });

  $('.toggle-copy-trip').click(copyRide);

  function submitRoute(){
    var that = $(this);
    start_left_ajax_loader();
    $('#route_data', this).val(waypoints.serialize());

    var $waypoints = $('#waypoints');

    var ride_distance = $waypoints.attr('data-distance');
    ride_distance && $('#route_ride_distance', this).val(ride_distance);

    var ride_time = $waypoints.attr('data-time');
    ride_time && $('#route_ride_time', this).val(ride_time);

    var encodedPath = getEncodedPath();
    encodedPath && $('#route_encoded_path', this).val(encodedPath);

    $.post($(this).attr('action'), $(this).serialize(), null, 'json').done(function (route) {
      console.log(route);
      if (route.premium == false) {
        freeUserRideLimit();
        return;
      }
      if (typeof route.id === 'undefined') {
        alert('route not saved');
        return;
      }
      that.hide();
      $('#saved_routes option[value=' + route.id + ']').remove();
      $('#saved_routes').append('<option value="' + route.id + '">' + route.title + '</option>');
      $('.map-block-wrapper .route-title').html(route.title);
      $('.trip-planner-form').html('').hide();
      routes.load(route.id, route);
      $('#map-block .share').html('<a href="' + '/shared_rides/new/' + route.id + '">Share this trip</a>').show();
      $('.show-controls').show();
      $(".map-block-wrapper").mCustomScrollbar("scrollTo", 0);
      $('.toggle-clear-trip').hide();
      createRouteDivFromJson(route);
    }).fail(function (jqXHR, textStatus, errorThrown) {
      _.each(_.keys(jqXHR.responseJSON), function (key) {
        toastr.error('Plan ' + key + ' ' + jqXHR.responseJSON[key].join(', ') + '.');
      });
    });
    return false;
  }

  $('.trip-planner-form').on('submit', 'form', submitRoute);

  $('#saved_routes').change(function () {
    // clear all prev routes
    waypoints.clear();
    routes.clear();
    directions.reset();

    if ($(this).val() != '0') {
      $(this).find('option.null-option').remove();
      $('#saved_routes').trigger('render');
    }
    if ($(this).val() != '' && $(this).val() != '0') {
      routes.load($(this).val());
    } else if ($(this).val() != '0') {
      start_left_ajax_loader();
      moveMapControls(true);
      popupOpenNewRoute();
      stop_left_ajax_loader();
    }
  });
});

// impl
routes = (function ($) {
  var viewMode = false;
  var editableRoute = true;
  var editForm = false;
  var _canCopy = true;
  var metersToMile = 0.00062137119223733;
  var elevationsProfile;
  var isG1Description = false;
  var isBdr = false;
  var showAlert = true; // show popup alert to user about using polygon tool
  var routeId = null;
  var routeBuilt = false;

  var secondsToScreen = function (sec) {
    var str = [];
    var hours = Math.floor(sec / 3600);
    sec -= hours * 3600;
    str.push(hours);
    str.push(':');
    var minutes = Math.ceil(sec / 60);
    if (minutes < 10) {
      str.push('0');
    }
    str.push(minutes);
    return str.join('');
  };
  var cacheDirectionsPath = function () {
    var path;
    try {
      path = directions.getPath().getPath();
    }
    catch (e) {
      console.log(e.message, "Try another way");
      path = directions.getPath().getPath().getArray();
    }
    var ret = [];
    for (var i = 0; i < path.length; i++) {
      ret.push([path[i].lat().toFixed(5) * 1.0, path[i].lng().toFixed(5) * 1.0]);
    }
    return ret;
  };

  var cachedRoutePath = [];

  return {
    init: function () {
      showAlert = true;

      var rendererOptions = {
        draggable: true, preserveViewport: preserveViewport === true,
        polylineOptions: RidingSocial.Config.routePolylineOptions
      };
      directions = map.newDirections(rendererOptions);

      elevationsProfile = map.newElevationProfile();

      directions.events.addListener('directions_changed', function () {
        routes.onDirectionsChange();
        !isEmbed && directions.getStartLocation() && elevationsProfile.init().then(function () {
          elevationsProfile.displayProfileChart(directions.getPath());
        });
      });
      if (currentUserRouteCountExceeded) viewMode = true;
    },

    build: function (fitBounds) {
      if (waypoints.isNotReady()) {
        directions.reset();
        $('#ElevationsProfileChartHolder').hide();
        if (directions.getStartLocation()) {
          map.setCenter(directions.getStartLocation().getLocation());
          (fitBounds || map.getZoom() < RidingSocial.Config.defaultZoom) && map.setZoom(RidingSocial.Config.defaultZoom);
          leftPopupSlide($('.map-block-wrapper'), $('.plan-trip-link').parent(), true, true);
          $(".routes-param.controls .controls-polygon").removeClass("active");
        }
        return;
      }
      elevationsProfile.init().then(function () {
        routes.buildDirections(fitBounds);
      });

      !$('#ElevationsProfileChartHolder').data('isClosed') && $('#ElevationsProfileChartHolder').show();
      !isEmbed && leftPopupSlide($('.map-block-wrapper'), $('.plan-trip-link').parent(), true, true);
      $(".controls-polygon").toggleClass("active", waypoints.isInPolylineMode());
      $('.routes-param.controls').toggle(!viewMode);
    },

    buildDirections: function(fitBounds){
      var routeParts = routes.buildRouteParts();
      directions.route(routeParts, 0,
        function (path) {    // SUCCESS CALLBACK
          routeBuilt = true;
          directions.setMap(map);
          if (routes.isInViewMode() || fitBounds) {
            map.fitBounds(map.newBoundsFromRoute(path));
          }
        },
        function (status) {  // FAIL CALLBACK
          console.warn("Failed to build route due " + status);
        });

    },

    buildRouteParts: function () {
      var routePartsWaypoints = [
//                {
//                    isPolyline: false,
//                    origin: "",
//                    destination: "",
//                    waypoints: []
//                }, {
//                }
      ];  // result of filtering Markers

      var index = -1;
      var sliceBegin;
      var Waypoints = waypoints.getWaypoints();
      if (Waypoints.length < 2) return;

      var waypointAtIndex = function (i) {
        return {
          latitude: Waypoints[i].latitude,
          location: Waypoints[i].location,
          longitude: Waypoints[i].longitude
        };
      };

      var polylineBuilding = !!Waypoints[0].isPolyline;
      routePartsWaypoints.push({
        isPolyline: polylineBuilding,
        origin: waypointAtIndex(0),
        destination: null,
        waypoints: []
      });
      index++;
      sliceBegin = 1;

      for (var i = 1; i < Waypoints.length; i++) {
        if (!!Waypoints[i].isPolyline === polylineBuilding) {
          routePartsWaypoints[index].destination = waypointAtIndex(i);
          routePartsWaypoints[index].waypoints = Waypoints.slice(sliceBegin, i);
        }
        else {
          routePartsWaypoints.push({
            isPolyline: !!Waypoints[i].isPolyline,
            origin: waypointAtIndex(i - 1),
            destination: waypointAtIndex(i),
            waypoints: []
          });

          polylineBuilding = !!Waypoints[i].isPolyline;
          index++;
          sliceBegin = i;
        }
      }

      /** Filter route parts to exclude parts without destination */
      routePartsWaypoints = _.filter(routePartsWaypoints, function (part) {
        return _.compact(_.values(part.destination)).length > 0;
      });

      /*** Update those route parts, that are directions with waypoints count more than 23 (business version)*/
      var _postProduction = [];
      var count = mapviewConf.waypointRestriction;
      _.each(routePartsWaypoints, function (routePart) {
        if (routePart.isPolyline) {
          _postProduction.push(routePart);
          return;
        }
        else if (routePart.waypoints.length <= count) {
          _postProduction.push(routePart);
          return;
        }

        /*
         * ORIGIN
         * {
         *   isPolyline: false,
         *   origin: latLng
         *   destination: latLng
         *   waypoints: array [latLng, ].lenght > 23
         * }
         *
         * GOES TO
         *
         * 0:  {
         *       isPolyline: false
         *       origin: ORIGIN.origin
         *       waypoints: ORIGIN.waypoints[0..22]
         *       destination: ORIGIN.waypoints[23]
         *     },
         * 1:  {
         *       isPolyline: false
         *       origin: ORIGIN.waypoints[23]
         *       waypoints: ORIGIN.waypoints[24..46]
         *       destination: ORIGIN.waypoints[47]
         *     },
         * and so on
         * */
        var smallParts = [
          {
            isPolyline: false,
            origin: routePart.origin,
            waypoints: routePart.waypoints.slice(0, count),
            destination: routePart.waypoints[count]
          }
        ];
        var iterCount = (routePart.waypoints.length / (count + 1) | 0) + (routePart.waypoints.length % count ? 1 : 0);
        // (count+1) - coz we use 9 origin waypoints to build 1 small part (if count = 8)
        // + (routePart.waypoints.length%count ? 1 : 0) - coz this type of division (37 / 11 | 0) round value down

        for (var j = 1; j < iterCount; j++) { // (37 / 11 | 0) = 3 (int)
          smallParts.push({
            isPolyline: false,
            origin: routePart.waypoints[j * count + (j - 1)],
            waypoints: routePart.waypoints.slice(j * count + j, (j + 1) * count + j),
            destination: routePart.waypoints[(j + 1) * count + j]
          });
        }
        smallParts[smallParts.length - 1].destination = routePart.destination;

        _.each(smallParts, function (part) {
          _postProduction.push(part);
        });
      });

      return _postProduction;
    },
    onDirectionsChange: function () {
      if (directions.getPathMode() != 1) {
        var total = directions.getDistance();
        var duration = directions.getDuration();
        cachedRoutePath = cacheDirectionsPath();

        $('#waypoints').attr('data-distance', total).attr('data-time', duration);
        $('#route-length').text((total * metersToMile).toFixed(1));
        $('#route-duration').text(secondsToScreen(duration));
      }

      var waypointsCount = directions.getViaPoints().length;
      var uploadedGpx = directions.getPathMode()==1;
      waypointsCount = (C7E1249F == 'ED908C23' && !uploadedGpx) ? (22 - waypointsCount) : (waypointsCount + 2);
      $('#route-waypoints-count').text(waypointsCount);

      $('#type-in-locations, .waypoints-ready').hide();
      $('.show-controls, .add-destination, .route-waypoints-wraper').show();
      $('.want-upgrade').toggle(F24E43D9 != '2E315E03');
      $('.activity').toggle(!editForm);
      $('.toggle-save-trip').toggle(!routeId);
    },
    onLoad: function (route) {
      console.log("onLoad");
      routes.setRouteType(route);
      var data = route.data;
      var points = waypoints.unserialize(data);
      routes.build();
      if (routes.isInViewMode()) $(".controls").hide();
      waypoints.resetHistory();

      if (!waypoints.isNotReady()) {
        waypoints.toggleDraggable();
      } else {
        _(points).each(function (point) {
          var marker = point.getMarker();
          marker.setMap(null);
        });
        if (directions.getStartLocation()) {
          $('.waypoints-not-ready').hide();
        }
      }

      $('#route-length').text(route.distance);
      $('#route-duration').text(route.formatted_time);
      $('#route-waypoints-count').text(points.count);
      $('.edit-download-send').toggle(!(routes.isBdrOrG1() && B41C6E6D != '101F9B92'));
    },
    load: function (id, route) {
      routeId = id;
      start_left_ajax_loader();
      $('#map-block .show-controls').show();
      $('.select-route, .edit-download-send').show();
      $('.edit-controls, .toggle-save-trip, .route-waypoints-wraper, .want-upgrade').hide();

      viewMode = true;
      routes.setInEditForm(false);
      if (!route) {
        $.get('/routes/' + id + '.json', function (route) {
          $(document).attr('title', route.title + ' - Butler Maps');
          $('.map-block-wrapper .route-title').html(route.title);
          routes.handleOwn(route);
          routes.onLoad(route);
        }, 'json');
      } else {
        routes.onLoad(route);
      }

      var isOwner = !$('.toggle-save-trip').hasClass('not-owner');
      isOwner && $('.toggle-save-trip').hide();
      $('.go-button').hide();

      $.ajax({
        url: '/routes/' + id,
        type: 'get',
        dataType: "html",
      }).done(function (data) {

        $('.trip-planner').html(
          jQuery("<div>").append(jQuery.parseHTML(data)).find('#view-part')
        );

        $('.trip-planner').show();
        $('.trip-planner-form').hide();
        $('.toggle-save-trip').off('click').click(function () {
          showEditRouteForm(id);
          return false;
        });

        $(".routes-param").off("click", "a.metric").on("click", "a.metric", function (event) {
          $("a.metric").removeClass("active");
          $(this).addClass("active");
          directions.setMetric($(this).data("metric"));
          !isEmbed && elevationsProfile.init().then(function () {
            elevationsProfile.displayProfileChart(directions.getPath());
          });
          return false;
        });
        var raty = $('.raty');
        var score = parseFloat(raty.html());
        raty.html('');
        raty.raty({
          readOnly: true,
          score: score,
          showHalf: true,
          starHalf: ratyConf.starHalf,
          starOff: ratyConf.starOff,
          starOn: ratyConf.starOn
        });
        moveMapControls(true);

        $('.route-accordion-holder .route-accordion>:not(.waypoints)').remove();
        $('.route-accordion-holder .route-accordion').append($(data).find('.route-accordion').html());
        $('.route-accordion-holder').show();
        $(".route-accordion").accordion("refresh").accordion('option', {active: false});
        stop_left_ajax_loader();
      });

      window.location.hash = "route-" + id;
      if ($("#saved_routes option[value='" + id + "']").length !== 0) {
        $('#saved_routes').val(id).trigger('render');
      }
    },
    clear: function () {
      routeId = null;
      viewMode = false;
      editableRoute = true;
      routeBuilt = false;
      isG1Description = false;
      routes.setInEditForm(false);
      waypoints.toggleDraggable();
      directions.setPathMode(0);
      directions.setPath(null);
      $('#route-length').text('0');
      $('#route-duration').text('00:00');
      $('#route-waypoints-count').text('0');

//      $('#route-waypoints-count').text(C7E1249F == 'ED908C23' ? 22 : 0);

      $('#type-in-locations').show();
      $('.show-controls, .add-destination, .route-waypoints-wraper').hide();
      $('.want-upgrade').toggle(F24E43D9 != '2E315E03');

      routes.build();
      elevationsProfile.clear();
    },
    isInViewMode: function () {
      return viewMode;
    },
    isEditable: function () {
      return editableRoute;
    },
    isCopyable: function () {
      return _canCopy;
    },
    setRouteType: function (route) {
      isG1Description = route.ride_type_id == 4;
      isBdr = route.ride_type_id == 5;
    },
    isG1: function () {
      return isG1Description;
    },
    isBdr: function () {
      return isBdr;
    },
    isBdrOrG1:function(){
      return isG1Description || isBdr;
    },
    getRouteId: function () {
      return routeId;
    },
    handleOwn: function (route) {
      var uploaded = false;
      if (route.is_readonly !== undefined && route.is_readonly) {
        editableRoute = false;
      } else {
        if (route.data) {
          var data = JSON.parse(route.data);
          uploaded = data.route_type == "uploaded";
        }
        editableRoute = route.type !== "ridden" && !(route.ride_type_id == 2 || route.ride_type_id == 4) && !uploaded;
      }
      _canCopy = !(route.ride_type_id == 2 || route.ride_type_id == 4);
      if (!route.owner) {
        $('.toggle-copy-trip').attr('data-id', route.id).toggle(_canCopy);
        var nullOption = $('#saved_routes').find('option.null-option');
        if (nullOption.length == 0) {
          $('#saved_routes').append('<option value="0" class="null-option">' + route.title + '</option>');
        } else {
          nullOption.text(route.title);
        }
        $('#saved_routes').val(0).trigger('render');
        $('#map-block .share').html('').hide();
        $('.toggle-save-trip').addClass('not-owner').hide();
      } else {
        $('#map-block .share').html('<a href="' + '/shared_rides/new/' + route.id + '">Share this trip</a>').toggle(_canCopy);
        $('.toggle-copy-trip').hide();
        $('.toggle-save-trip').removeClass('not-owner').hide();
      }
    },
    preLoad: function (id) {
      if (id == null) {
        if (isEmbed) return embededRoute;
        if (false === window.location.hash.indexOf('#route-')) {
          return false;
        }
        var routeId = parseInt(window.location.hash.split('#route-')[1]);
        if (Math.floor(routeId) == routeId && $.isNumeric(routeId) && routeId != 0) {
          id = routeId;
        } else {
          return false;
        }
      }
      var route;
      $.ajax({
        url: '/routes/' + id + '.json',
        type: 'get',
        dataType: 'json',
        async: false,
        success: function (data) {
          route = data;
        },
        error: function () {
          route = false;
        }
      });
      if (route === false || route.data.destination === null || route.data.origin === null) {
        return false;
      }
      routes.handleOwn(route);
      return route;
    },
    setCachedRoutePath: function (path) {
      if (typeof path !== "undefined" && path.length && path.length > 0) {
        directions.setPath(map.newPathFromArray(path));
        directions.setPathMode(1);
      }
      cachedRoutePath = path;
    },
    getCachedRoutePath: function () {
      return cachedRoutePath;
    },
    _setViewMode: function (v) {
      viewMode = v;
    },
    getAlert: function () {
      return showAlert;
    },
    resetAlert: function () {
      showAlert = false;
    },
    setInEditForm: function(v) {
      editForm = v;
    },
    getInEditForm: function() {
      return editForm;
    },
    getRouteBuilt: function () {
      return routeBuilt;
    },
    sendOffline: function(routeId){
      if (C7E1249F == 'ED908C23') {
        getPremiumWindow('Caching maps for offline viewing is part of our plus and premium memberships.', 'It allows you to view map details on your mobile app even when you don\'t have a cell signal. <br>It works great! Try it out by upgrading here.<br>');
        return false;
      }
      $.ajax({
        type: "POST",
        url: '/notifications/' + routeId + ".json",
        success: function (data) {
          toastr.success('A notification was sent to your app to download the map for offline use (Currently iOS devices only)');
        },
        error: function (jqXHR, textStatus, errorThrown) {
          if (jqXHR.responseText)
            toastr.warning(jqXHR.responseText);
          else
            ajax_error_msg();
        },
        dataType: 'json'
      });
    }
  };
})(jQuery);

RidingSocial.MapTools.then(function () {
  routes.init();
  var route = routes.preLoad();
  if (route !== false) {
    console.log('loading route', route.id);
    routes.load(route.id, route);
    routes.setRouteType(route);
  }

  map.clickListener = map.events.addListener("click", function (e) {

//    if (currentUserRouteCountExceeded) {
//        freeUserRideLimit();
//        return false;
//    }

    if (routes.isInViewMode() || !routes.isEditable()) {
      return false;
    }

    var waypointsCount = directions.getViaPoints().length;
    if (waypointsCount >= 22 && C7E1249F == 'ED908C23') {
      getPremiumWindow('Free accounts are limited to 24 waypoints. Upgrade to get access to unlimited waypoints for your awesome rides.');
      return false;
    }

    var location = typeof e.latLng !== "undefined" ?
      map.newLatLng(e.latLng.lat(), e.latLng.lng()) :
      map.newLatLng(e.mapPoint.getLatitude(), e.mapPoint.getLongitude());

    directions.setPathMode(0);
    waypoints.add({
      latlng: location,
      geocode: true,
      isPolyline: waypoints.isInPolylineMode()
    });
    routes.build();
    leftPopupSlide($('.map-block-wrapper'), $('.plan-trip-link').parent(), true, true);
  });
});
