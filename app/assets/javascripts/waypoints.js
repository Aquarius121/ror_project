waypoints = (function ($) {
  var wpDOM = null;
  var geocoder = null;
  var inPolylineMode = false;

  var $startingAddressInput = $('.starting-address-input');
  var $goingAddressInput = $('.going-address-input');
  var startAddress = $startingAddressInput.val();
  var endAddress = $goingAddressInput.val();
  var startAnswer, endAnswer;

  var applyDefault = function (args) {
    if (typeof args.id == 'undefined') {
      if (directions.getStartLocation() == null) {
        args.id = 'start';
      } else {
        args.id = 'end';
      }
    }
    if (typeof args.after == 'undefined') {
      args.after = args.id == 'start' ? 'template' : (args.id == 0 ? 'start' : 'via-' + (args.id - 1));
    }
    return args;
  };

  var updateLabel = function (point, label) {
    point.setLabel(label);
    $('.wp-' + point.getId() + ' .location', wpDOM).val(label);
  };

  var setDraggableForMarker = function (location, draggable) {
    if (!location) return;
    location.getMarker().getMarker().setDraggable(draggable);
  };

  var addToWaypoints = function (args) {

    args = applyDefault(args);
    var point = map.newLatLngViaPoint(args.latlng.lat(), args.latlng.lng(), args.id);

    point.isPolyline = args.isPolyline;

    if (args.id == 'start') {
      var start = directions.getStartLocation();
      if (start != null) {
        start.getMarker().getMarker().setMap(null);
      }
      directions.setStartLocation(point);

      $('.routes-param').show();
    } else if (args.id == 'end') {
      var destination = directions.getEndLocation();
      if (destination != null) {
        directions.addViaPoint(destination);
        destination.updateIcon();
      }
      var viapoints = _.clone(directions.getViaPoints());
      if (viapoints.length) {
        var last = viapoints.pop();
        args.after = last.getId();
      } else {
        args.after = 'start';

//        if (!routes.isInViewMode()) {
//          $('.additional-way-options, .go-button').show();
//        }
      }

      directions.setEndLocation(point);
    } else if (args.insert === true) {
      directions.insertViaPoint(args.id, point);
    } else {
      directions.addViaPoint(point);
    }
    point.createMarker();
    point.events.addListener('dragend', function(event){
      var label;
      var id = point.getId();
      var setLabel = function(label){
        if (id == 'start')
          $startingAddressInput.val(label);
        else
          $goingAddressInput.val(label);
      };
      if (id == 'start' || id == 'end') {
        geocoder.reverse(new RidingSocial.MapTools.Google.LatLng(event.latLng.lat(), event.latLng.lng()), function (results) {
          label = results[0].formatted_address;
          setLabel(label);
        }, function () {
          label =  event.latlng.lat().toFixed(5) + ',' + event.latlng.lng().toFixed(5);
          setLabel(label);
        });
      }
    });
    $('.wp-' + args.after).after($('.wp-template', wpDOM).clone().removeClass('wp-template').addClass('wp-' + point.getId()));
    $('.wp-' + point.getId() + ' .wp-button', wpDOM).data('id', point.getId());
    if (typeof args.geocode === 'undefined' || !args.geocode) {
      point.setLabel(args.location);
      $('.wp-' + point.getId() + ' .location', wpDOM).val(point.getLabel());
    }
    return point;
  };

  var hideWaypoint = function (wp) {
    wp.hide();
    $('.wp-' + wp.getId(), wpDOM).remove();
  };

  var removeViaPoints = function() {
    var wp = directions.getViaPoints();
    for (var i = 0; i < wp.length; i++) {
      hideWaypoint(wp[i]);
    }
    directions.setViaPoints(false);

  };
  var clearAll = function () {
    _(['Start', 'End']).each(function (locationName) {
      var location = directions['get' + locationName + 'Location']();
      location && hideWaypoint(location);
      directions['set' + locationName + 'Location'](null);
    });
    removeViaPoints();
  };

  var UndoStack = new function () {
    this.stack = [];
    this.top = -1;
    this.limit = 100;
    var undoStackSelf = this;

    this.push = function (point) {
      if (undoStackSelf.top < undoStackSelf.limit) {
        undoStackSelf.top++;
        undoStackSelf.stack.push(point);

        return undoStackSelf.top;
      }
      else
        return null;
    };

    this.pop = function () {
      if (undoStackSelf.top < 0)
        return null;

      var point = undoStackSelf.stack.pop();
      undoStackSelf.top--;
      return point;
    };

    this.clear = function () {
      undoStackSelf.stack = [];
      undoStackSelf.top = -1;
    };

    return this;
  }();
  var RedoStack = new function () {
    this.stack = [];
    this.top = -1;
    this.limit = 100;
    var redoStackSelf = this;

    this.push = function (point) {
      if (redoStackSelf.top < redoStackSelf.limit) {
        redoStackSelf.top++;
        redoStackSelf.stack.push(point);

        return redoStackSelf.top;
      }
      else
        return null;
    };

    this.pop = function () {
      if (redoStackSelf.top < 0)
        return null;

      var point = redoStackSelf.stack.pop();
      redoStackSelf.top--;
      return point;
    };

    this.clear = function () {
      redoStackSelf.stack = [];
      redoStackSelf.top = -1;
    };

    return this;
  }();

  RidingSocial.MapTools.then(function () {
    waypoints.init();
    $startingAddressInput = $('.starting-address-input').data({wpId:'start'});
    $goingAddressInput = $('.going-address-input').data({wpId:'end'});;

    function attachAutoComplete(index, el){
      el = el ? el : index;
      var $el = $(el);
      var wpId = $el.data() && $el.data().wpId;
      var autoComplete = new RidingSocial.MapTools.Google.Places({map: map, element: el});
      autoComplete.events.addListener('place_changed', function(){
        var place = autoComplete.getPlace();
        if (!place.geometry) return;
        place['visible_address'] = $el.val();
        addWaypointFromPlace(place, wpId);
      });
      var $span = $el.next('span');
      $span.on('click', function(){
        $el.val('');
        if (waypoints.get(wpId)){
          waypoints.remove(wpId);
          routes.clear();
        }
        if (!_.contains(['start', 'end'], wpId)){
          autoComplete.events.clearListeners();
          $el.remove();
          $span.off().remove();
        }
      });
      $el.data({wpId:wpId, autoComplete: autoComplete});
    }

    $('.starting-address-input, .going-address-input').each(attachAutoComplete);

    startAddress = $startingAddressInput.val();
    endAddress = $goingAddressInput.val();

    var addWaypointFromAnswer = function (answer, waypointId) {
      var location = answer[0].geometry.location;
      var latlng = map.newLatLng(location.lat(), location.lng());
      waypoints.add({
        location: answer[0].formatted_address,
        latlng: latlng,
        id: waypointId
      });
      map.setCenter(latlng);
    };

    var addWaypointFromPlace = function (place, waypointId) {
      var intermediateWaypoint = waypointId != 'start' && waypointId != 'end';
      if (place.geometry.viewport) {
        map.getMap().fitBounds(place.geometry.viewport);
      } else {
        map.getMap().setCenter(place.geometry.location);
        map.setZoom(RidingSocial.Config.defaultZoom);
      }

      var location = place.geometry.location;
      var latlng = map.newLatLng(location.lat(), location.lng());

      if (waypoints.get(waypointId)){
        waypoints.remove(waypointId);
      }

      waypoints.add({
        location: place.visible_address,
        latlng: latlng,
        id: waypointId,
        insert: intermediateWaypoint
      });

      if (routes.getRouteBuilt()) routes.build();
    };

    var findStartLocation = function () {
      startAddress = $startingAddressInput.val();
      return geocoder.geocode(startAddress, function (answer) {
        startAnswer = answer;
        addWaypointFromAnswer(startAnswer, 'start');
        map.setZoom(RidingSocial.Config.defaultZoom);
      });
    };
    var findEndLocation = function () {
      endAddress = $goingAddressInput.val();
      geocoder.geocode(endAddress, function (answer) {
        endAnswer = answer;
        addWaypointFromAnswer(endAnswer, 'end');
      });
    };

    $('.go-button').click(function () {
      startAddress = endAddress = null;
      if (!waypoints.get('start')) findStartLocation();
      if (!waypoints.get('end')) findEndLocation();
      routes.build(true);
      $('.toggle-save-trip').show();
      if (!($('.plan-trip-link').parent().hasClass('active'))) {
        leftPopupSlide($('.map-block-wrapper'), $('.plan-trip-link').parent(), true, true);
      }
      return false;
    });

    $('.toggle-save-to-plans').click(function () {
      $('.edit-controls, .toggle-save-trip, .select-route').hide();
    });

    $('#a-edit').click(function () {
      if (routes.isEditable()) {directions.setPathMode(0);}
      routes.buildDirections();
      showEditRouteForm(routes.getRouteId());
    });

    $('#a-download').click(function () {
      var route_id = routes.getRouteId();
      if (!route_id) return false;
      if (F24E43D9 != '2E315E03') {
        getPremiumWindow();
      } else {
        window.location = "/routes/" + route_id + "/download";
      }
    });

    $('#a-send').click(function () {
      var routeId = routes.getRouteId();
      routeId && routes.sendOffline(routeId);
      return false;
    });

    $('#a-add-destination').click(function () {
      var el = $('<input type="text" value="" class="waypoint-address" />' +
        '<span class="clear-input"></span>');
      $(el[0]).data({wpId: directions.getViaPoints().length});
      attachAutoComplete(el[0]);
      $('#goingaddress').before(el);
    });

    $('#avoid-highways').change(function () {
      //$('#avoid-highways').is(":checked");
    });

    $('#avoid-toll-ways').change(function () {
      //$('#avoid-toll-ways').is(":checked");
    });

    $('#best-moto-roads').change(function () {
      //$('#best-moto-roads').is(":checked");
    });

    $('#avoid-season-closed').change(function () {
      //$('#avoid-season-closed').is(":checked");
    });

    $('#include-dirt').change(function () {
      //$('#include-dirt').is(":checked");
    });

    $('.want-upgrade').click(function () {
      getPremiumWindow('Free accounts are limited to 24 waypoints. Upgrade to get access to unlimited waypoints for your awesome rides.');
      return false;
    });

    $startingAddressInput.on('blur', function (){
      setTimeout(function(){!directions.getStartLocation() && findStartLocation()}, 100);
    });

    $goingAddressInput.on('blur', function () {
      setTimeout(function(){!directions.getEndLocation() && findEndLocation()}, 100);
    });

    // controls
    $('.controls-undo').click(function () {
      if (!routes.isInViewMode()) waypoints.undo();
      return false;
    });

    $('.controls-redo').click(function () {
      if (!routes.isInViewMode()) waypoints.redo();
      return false;
    });
  });
  /*** used by undo / redo functions */
  var _getWaypoint = function (point) {
    return {
      supressAddState: true,
      label: point.label,
      latlng: map.newLatLng(point.latlng.lat(), point.latlng.lng()),
      isPolyline: point.isPolyline
    }
  };

  var updateWaypointInputs = function(){
    var startFrom = directions.getStartLocation() ? directions.getStartLocation().getLabel() : null;
    var endAt = directions.getEndLocation() ? directions.getEndLocation().getLabel() : null;

    startFrom && $startingAddressInput.val(startFrom);
    endAt && $goingAddressInput.val(endAt);
  };

  var showDirectionToggles = function(){

  };

  var showControls = function(){
    $('.show-controls').show();
  };

  var showGoButton = function(){
    $('.go-button').show();
  };

  return {
    init: function () {
      wpDOM = $('#waypoints');
      geocoder = map.newGeocoder();
      this.onChange();
      var notReady = this.isNotReady();
      if (notReady) {
        $('.show-controls, .select-route').hide();
      }
      else {
        $('.show-controls, .select-route').show();
        $('.edit-controls').hide();
      }
      $('.add-destination, .routes-param').hide();
      if (routes.isInViewMode()) {
        $('.show-controls, .select-route').show();
        $('.toggle-save-trip, .edit-controls, .route-waypoints-wraper, .want-upgrade').hide();
      }
      $('#route_title').get(0).placeholder = 'Enter Plan Name';
      $('#route_description').get(0).placeholder = 'Enter Description';
    },
    onChange: function () {
      var notReady = this.isNotReady();
      if (routes.isG1()) {
        notReady = directions.getStartLocation() != null;
      }
      var present = directions.getStartLocation() != null;
      var ready = !notReady;

      $('.waypoints-not-ready').toggle(notReady);
      $('.waypoints-ready').toggle(ready);
      $('.waypoints-not-present').toggle(!present);
      $('.not-owner').hide();
      $('.toggle-clear-trip').toggle($('#saved_routes').val() == '');
      $('#type-in-locations .title').toggleClass('active', ready);
      updateWaypointInputs();
    },
    add: function (args) {
      if (args.supressAddState !== true)
        waypoints.addState();
      var point = addToWaypoints(args);
      var self = this;
      if (typeof args.geocode !== 'undefined' && args.geocode) {
        geocoder.reverse(args.latlng, function (results) {
          var label = results[0].formatted_address;
          updateLabel(point, label, args.id);
          self.onChange();
        }, function () {
          updateLabel(point, args.latlng.lat().toFixed(5) + ',' + args.latlng.lng().toFixed(5));
          console.warn('Geocoder failed', args);
        });
      }
      else if (args.label) {
        updateLabel(point, args.label);
      }
      this.onChange();
      return true;
    },
    remove: function (id) {
      $('.wp-' + id, wpDOM).remove();
      var point;
      var removed;
      var wp = directions.getViaPoints();
      if (id == 'start') {
        removed = directions.getStartLocation();
        if (removed === null) {
          return null;
        }
        directions.setStartLocation(null);
        if (wp.length > 0) {
          point = wp.shift();
          directions.setStartLocation(point);
          point.updateIcon();
        }
      } else if (id == 'end') {
        removed = directions.getEndLocation();
        directions.setEndLocation(null);
        if (wp.length > 0) {
          point = wp.pop();
          directions.setEndLocation(point);
          point.updateIcon();
        }
      } else {
        var removedArray = wp.splice(id, 1);
        removed = removedArray[0];
      }
      removed.hide();
      $('.wp-' + removed.getId(), wpDOM).remove();
      directions.setViaPoints(wp);
      for (var i = 0; i < wp.length; i++) {
        wp[i].updateIcon();
      }
      this.onChange();
      return removed;
    },
    toggleDraggable: function () {
      var draggable = routes.isInViewMode() || !routes.isEditable() ? false : true;
      setDraggableForMarker(directions.getStartLocation(), draggable);
      var wp = directions.getViaPoints();
      for (var i = 0; i < wp.length; i++) {
        wp[i].getMarker().getMarker().setDraggable(draggable);
      }
      setDraggableForMarker(directions.getEndLocation(), draggable);
    },
    get: function (id) {
      if (id == 'origin' || id == 'start') {
        return directions.getStartLocation();
      }
      if (id == 'destination' || id == 'end') {
        return directions.getEndLocation();
      }
      return directions.getViaPoint(parseInt(id));
    },
    removeViaPoints: removeViaPoints,
    clear: function () {
      $('.waypoint-address').each(function(index, el){
        var $el = $(el);
        var elData = $el.data();
        var $span = $el.next('span');
        elData.autoComplete.events.clearListeners();
        elData.autoComplete = null;
        $el.val('').remove();
        $span.off().remove();
      });
      clearAll();
      inPolylineMode = false;
      $(".controls .controls-polygon").removeClass('active');
      $('#avoid-highways, #avoid-toll-ways').removeAttr('checked');

      if (routes.isInViewMode()) {
        $('.trip-planner-form').show();
      } else {
        $('#type-in-locations').show();
        $('.show-controls, .trip-planner-form').hide();
      }
      $('.routes-param').hide();

      $startingAddressInput.val('');
      $goingAddressInput.val('');
      startAddress = endAddress = null;
      this.onChange();
    },
    isNotReady: function () {
      var notReady = directions.getStartLocation() == null || directions.getEndLocation() == null;
      return notReady;
    },
    serialize: function () {
      if (directions.getStartLocation() == null) {
        return JSON.stringify({});
      }
      var serialized = [];
      var serializeWaypoint = function (location) {
        return {
          location: location.getLabel(),
          latitude: location.getLocation().lat(),
          longitude: location.getLocation().lng(),
          isPolyline: location.isPolyline
        }
      };
      var wp = directions.getViaPoints();
      for (var i = 0; i < wp.length; i++) {
        serialized.push(serializeWaypoint(wp[i]));
      }
      var ret = {
        origin: serializeWaypoint(directions.getStartLocation()),
        waypoints: serialized
      };
      var destination = directions.getEndLocation();
      if (destination) {
        ret.destination = serializeWaypoint(destination);
      }
      ret['route_data'] = routes.getCachedRoutePath();
      ret['route_type'] = waypoints.isInPolylineMode() ? "polyline" : "directions";
      /* TODO: should depricate */
      return JSON.stringify(ret);
    },
    unserialize: function (str) {
      clearAll();
      var points = [];
      var point;
      var data = JSON.parse(str);

      point = addToWaypoints({
        location: data.origin.location,
        latlng: map.newLatLng(data.origin.latitude, data.origin.longitude),
        id: 'start',
        isPolyline: data.origin.isPolyline
      });
      points.push(point);
      if (data.destination) {
        point = addToWaypoints({
          location: data.destination.location,
          latlng: map.newLatLng(data.destination.latitude, data.destination.longitude),
          id: 'end',
          isPolyline: data.destination.isPolyline
        });
        points.push(point);

        waypoints.setPolylineMode(data.destination.isPolyline == true);
      }
      for (var i = 0; i < data.waypoints.length; i++) {
        point = addToWaypoints({
          location: data.waypoints[i].location,
          latlng: map.newLatLng(data.waypoints[i].latitude, data.waypoints[i].longitude),
          id: i,
          isPolyline: data.waypoints[i].isPolyline
        });
        points.push(point);
      }
      directions.setPathMode(0);
      routes.setCachedRoutePath(data.route_data);
      if (routes.getInEditForm() && routes.isEditable()) {directions.setPathMode(0);}
      this.onChange();
      return points;
    },
    undo: function () {
      var self = this;
      var state = _.clone(UndoStack.pop());
      if (state !== null) {
        RedoStack.push(_.clone(this.getState()));

        waypoints.clear();
        routes.clear();

        if (state.startLocation !== null)
          this.add(_getWaypoint(state.startLocation));

        if (state.endLocation !== null)
          this.add(_getWaypoint(state.endLocation));

        state.viaPoints.forEach(function (point) {
          self.add(_.extend(_getWaypoint(point), {id: point.id}));
        });

        routes.build();
      }
      else
        return false;
    },
    redo: function () {
      var self = this;
      var state = _.clone(RedoStack.pop());

      if (state !== null) {
        UndoStack.push(state);

        waypoints.clear();
        routes.clear();

        if (state.startLocation !== null)
          this.add(_getWaypoint(state.startLocation));

        if (state.endLocation !== null)
          this.add(_getWaypoint(state.endLocation));

        state.viaPoints.forEach(function (point) {
          self.add(_.extend(_getWaypoint(point), {id: point.id}));
        });

        routes.build();
      }
      else
        return false;
    },
    getState: function () {
      var startLocation = directions.getStartLocation();
      var viaPoints = directions.getViaPoints();
      var endLocation = directions.getEndLocation();

      var state = {};

      if (startLocation != null) {
        state["startLocation"] = {
          label: startLocation.getLabel(),
          latlng: startLocation.getLocation().getLatLng(),
          isPolyline: startLocation.isPolyline
        };
      }
      else {
        state["startLocation"] = null;
      }

      state["viaPoints"] = _.map(viaPoints, function (point) {
        return {
          id: point.getId(),
          label: point.getLabel(),
          latlng: point.getLocation().getLatLng(),
          isPolyline: point.isPolyline
        };
      });

      if (endLocation != null) {
        state["endLocation"] = {
          label: endLocation.getLabel(),
          latlng: endLocation.getLocation().getLatLng(),
          isPolyline: endLocation.isPolyline
        };
      }
      else {
        state["endLocation"] = null;
      }

      return state;
    },
    addState: function () {
      RedoStack.clear();
      UndoStack.push(this.getState());
    },
    resetHistory: function () {
      UndoStack.clear();
      RedoStack.clear();
    },
    setPolylineMode: function (v) {
      inPolylineMode = v;
    },
    isInPolylineMode: function () {
      return inPolylineMode;
    },
    getWaypoints: function () {
      if (directions.getStartLocation() == null) return [];

      var serialized = [];
      var serializeWaypoint = function (location) {
        serialized.push({
          id: location.getId(),
          location: location.getLabel(),
          latitude: location.getLocation().lat(),
          longitude: location.getLocation().lng(),
          isPolyline: location.isPolyline
        });
      };
      serializeWaypoint(directions.getStartLocation());

      var wp = directions.getViaPoints();
      for (var i = 0; i < wp.length; i++) {
        serializeWaypoint(wp[i]);
      }

      var destination = directions.getEndLocation();
      if (destination) {
        serializeWaypoint(destination);
      }
      return serialized;
    }
  };
})(jQuery);
