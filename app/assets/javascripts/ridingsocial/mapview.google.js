RidingSocial.MapTools.Google = { };


//*******************************************************************
// EventManager
//*******************************************************************
RidingSocial.MapTools.Google.EventManager = function (_obj) {

  RidingSocial.EventManager.call(this, _obj);

  this.addListener = function (name, handler) {
    return google.maps.event.addListener(_obj, name, handler);
  };
  this.removeListener = function (listener) {
    google.maps.event.removeListener(listener);
  };
  this.clearListeners = function () {
    google.maps.event.clearInstanceListeners(_obj);
  };
  this.fireEvent = function (name, value) { /* Do nothing, google handles event firing */
  };
  this.triggerEvent = function (name, value) {
    google.maps.event.trigger(_obj, name, value);
  };
};

RidingSocial.MapTools.Google.EventManager.prototype = new RidingSocial.EventManager();


//*******************************************************************
// Path
//*******************************************************************
RidingSocial.MapTools.Google.Path = function (options) {

  var _points = (options && typeof options.points != 'undefined') ? options.points : new google.maps.MVCArray();
  var _self = this;

  RidingSocial.MapTools.Path.call(this, options);

  _points.forEach(function (val, idx) {
    _self.push(new RidingSocial.MapTools.Google.LatLng(val.lat(), val.lng()));
  });

  this.events = new RidingSocial.MapTools.Google.EventManager(_points);

  this.getPath = function () {
    return _points;
  };

  this.push = function (val) {
    _points.push(val.getLatLng());  // this will fire the 'insert_at' event which will add the point to the base path in the event handler below
  };

  var _parentInsertAt = this.insertAt;
  this.insertAt = function (idx, val) {
    if (val instanceof RidingSocial.MapTools.LatLng)
      _points.insertAt(idx, val.getLatLng());  // this will fire the 'insert_at' event which will add the point to the base path in the event handler below
  };

  var _parentSetAt = this.setAt;
  this.setAt = function (idx, val) {
    if (val instanceof RidingSocial.MapTools.LatLng)
      _points.setAt(idx, val.getLatLng());  // this will fire the 'set_at' event which will add the point to the base path in the event handler below
  };

  this.events.addListener('set_at', function (number, oldval) {
    var newloc = _points.getAt(number);
    _parentSetAt.call(this, number, new RidingSocial.MapTools.Google.LatLng(newloc.lat(), newloc.lng()));
  });
  this.events.addListener('insert_at', function (number) {
    var newloc = _points.getAt(number);
    _parentInsertAt.call(this, number, new RidingSocial.MapTools.Google.LatLng(newloc.lat(), newloc.lng()));
  });
};

RidingSocial.MapTools.Google.Path.prototype = new RidingSocial.MapTools.Path();


//*******************************************************************
// LatLng
//*******************************************************************
RidingSocial.MapTools.Google.LatLng = function (_lat, _lng) {
  var _latlng = new google.maps.LatLng(_lat, _lng);
  RidingSocial.MapTools.LatLng.call(this, _lat, _lng, 0);
  this.events = new RidingSocial.MapTools.Google.EventManager(_latlng);
  this.getLatLng = function () {
    return _latlng;
  };
};

RidingSocial.MapTools.Google.LatLng.prototype = new RidingSocial.MapTools.LatLng();


//*******************************************************************
// LatLngBounds
//*******************************************************************
RidingSocial.MapTools.Google.LatLngBounds = function (_sw, _ne) {

  var _bounds = new google.maps.LatLngBounds(_sw, _ne);

  RidingSocial.MapTools.LatLngBounds.call(this, _sw, _ne);

  this.events = new RidingSocial.MapTools.Google.EventManager(_bounds);

  this.getBounds = function () {
    return _bounds;
  };
  this.extend = function (latlng) {
    _bounds.extend(latlng);
    this.setSouthWest(new RidingSocial.MapTools.Google.LatLng(_bounds.getSouthWest().lat(), _bounds.getSouthWest().lng()));
    this.setNorthEast(new RidingSocial.MapTools.Google.LatLng(_bounds.getNorthEast().lat(), _bounds.getNorthEast().lng()));
  };
};

RidingSocial.MapTools.Google.LatLngBounds.prototype = new RidingSocial.MapTools.LatLngBounds();


//*******************************************************************
// Marker
//*******************************************************************
RidingSocial.MapTools.Google.Marker = function (options) {

  var _googleOptions = {};
  if (options && typeof options.icon != 'undefined') _googleOptions.icon = options.icon;
  if (options && typeof options.shape != 'undefined') _googleOptions.shape = options.shape;
  if (options && typeof options.position != 'undefined') _googleOptions.position = options.position.getLatLng();
  if (options && typeof options.zIndex != 'undefined') _googleOptions.zIndex = options.zIndex;
  if (options && typeof options.draggable != 'undefined') _googleOptions.draggable = options.draggable;
  if (options && typeof options.map != 'undefined') _googleOptions.map = options.map.getMap();

  var _marker = (options && typeof options.marker != 'undefined') ? options.marker : new google.maps.Marker(_googleOptions);

  RidingSocial.MapTools.Marker.call(this, options);

  this.events = new RidingSocial.MapTools.Google.EventManager(_marker);
  this.getMarker = function () {
    return _marker;
  };
  this.setMap = function (m) {
    _marker.setMap(m ? m.getMap() : null);
  };
  this.getPosition = function () {
    return new RidingSocial.MapTools.Google.LatLng(_marker.getPosition().lat(), _marker.getPosition().lng());
  };
  this.setPosition = function (p) {
    if (p instanceof RidingSocial.MapTools.Google.LatLng) _marker.setPosition(p.getLatLng());
  };
  this.setDraggable = function (b) {
    _marker.setDraggable(b);
  };
  this.setIcon = function (i) {
    _marker.setIcon(i);
  };
};

RidingSocial.MapTools.Google.Marker.prototype = new RidingSocial.MapTools.Marker();


//*******************************************************************
// Polyline
//*******************************************************************
window._polylines = [];
RidingSocial.MapTools.Google.Polyline = function (options) {
  var _polyline = new google.maps.Polyline();
  window._polylines.push(_polyline);
  var _path = new RidingSocial.MapTools.Google.Path({ points: _polyline.getPath() });

  RidingSocial.MapTools.Polyline.call(this, options);

  this.events = new RidingSocial.MapTools.Google.EventManager(_polyline);

  this.setPath = function (p) {
    if (p instanceof RidingSocial.MapTools.Google.Path) {
      _polyline.setPath(p.getPath());
      _path = new RidingSocial.MapTools.Google.Path({ points: _polyline.getPath() });
    }
  };
  this.setMap = function (m) {
    _polyline.setMap(m ? m.getMap() : null);
  };
  this.getPath = function () {
    return _path;
  };
  this.setOptions = function (options) {
    var googleOptions = {geodesic: true};
    if (options && typeof options.editable != 'undefined') googleOptions.editable = options.editable;
    if (options && typeof options.strokeColor != 'undefined') googleOptions.strokeColor = options.strokeColor;
    if (options && typeof options.rating != 'undefined') googleOptions.rating = options.rating;
    if (options && typeof options.strokeOpacity != 'undefined') googleOptions.strokeOpacity = options.strokeOpacity;
    if (options && typeof options.strokeWeight != 'undefined') googleOptions.strokeWeight = options.strokeWeight;
    if (options && typeof options.clickable != 'undefined') googleOptions.clickable = options.clickable;
    if (options && typeof options.path != 'undefined') googleOptions.path = options.path.getPath();

    _polyline.setOptions(googleOptions);
    this.setPath(options.path);
  };

  this.setOptions(options);
};

RidingSocial.MapTools.Google.Polyline.prototype = new RidingSocial.MapTools.Polyline();


//*******************************************************************
// Places
//*******************************************************************
RidingSocial.MapTools.Google.Places = function (options) {

  RidingSocial.MapTools.Places.call(this, options);
  var ac = new google.maps.places.Autocomplete(options.element);
  options.map && ac.bindTo('bounds', options.map.getMap());

  this.events = new RidingSocial.MapTools.Google.EventManager(ac);

  this.getPlace = function () {
    return ac.getPlace();
  }
};

RidingSocial.MapTools.Google.Places.prototype = new RidingSocial.MapTools.Places();


//*******************************************************************
// Directions
//*******************************************************************

RidingSocial.MapTools.Google.Directions = function (_map, options) {
  var _directionsDisplays = [];
  var _self = this;

  // events definitions
  var onRouteChanged = function (event) {
    if (!_self.getDistance()) {
      /* Calculate distance */
      var distance = 0;
      for (var path = _self.getPath().getPath(), i = 0; i < path.length - 1; i++) {
        distance += google.maps.geometry.spherical.computeDistanceBetween(path[i], path[i + 1]);
      }
      _self.setDistance(distance);
    }
    if (!_self.getDuration()) {
      _self.setDuration(distance / 30);
    }
  };
  var onDirectionsChanged = function (event) {
    if (!_readyForReroute) return;

    _readyForReroute = false;
    var wpOffset = -1; //  = (directionStart + 1) + insertedCount + i + j
    var insertedCount = 0;  // number of inserted via_waypoints (probably it will be always 0)
    var route = this.directions.routes[0];

    /* save current state */
    waypoints.addState();

    /* get direction start point */
    var origin = this.get("origin");
    if (origin && origin.lat() == _self.getStartLocation().getLocation().lat() && origin.lng() == _self.getStartLocation().getLocation().lng()) {
      wpOffset = 0;
    } else {
      _.each(_self.getViaPoints(), function (vp, i) {
        if (vp.getLocation().lat() == origin.lat() && vp.getLocation().lng() == origin.lng()) {
          wpOffset = i + 1;
        }
      });
    }

    if (wpOffset == -1) {
      console.warn("Unable to find starting point of current direction");
      routes.build();
      return;
    }

    for (var i = 0; i < route.legs.length; i++) {
      for (var j = 0; j < route.legs[i].via_waypoints.length; j++, insertedCount++) {
        waypoints.add({
          supressAddState: true,  // we already saved state
          id: wpOffset + insertedCount + i + j,
          insert: true,
          latlng: map.newLatLng(route.legs[i].via_waypoints[j].lat(), route.legs[i].via_waypoints[j].lng()),
          geocode: true,
          isPolyline: false
        });
      }
    }

    routes.build();
    _.each(_self.getViaPoints(), function (vp) {
      vp.updateIcon()
    });
  };

  var onPolylineChange = function (id, latLng) {
    var startOfPath = this.getArray()[0];
    // first of all: add state to undo/redo
    waypoints.addState();

    var check = id == 0 ? latLng : startOfPath;
    // get starting point of current polyline
    var startOfPolyline = _.find(waypoints.getWaypoints(), function (wp) {
      return wp.latitude == check.lat() && wp.longitude == check.lng();
    });

    if (startOfPolyline)
    // get related direction ViaPoint
      switch (startOfPolyline.id) {
        case 'start':
          startOfPolyline = _self.getStartLocation();
          break;
        case 'end':
          startOfPolyline = _self.getEndLocation();
          break;
        default:
          startOfPolyline = _self.getViaPoint(1 * startOfPolyline.id.split("-")[1]);
      }

    if (!startOfPolyline) {
      console.warn("Unable to get start point of polyline");
      routes.build();
      return;
    }

    var wpAtId = this.getAt(id);
    var _setLocationAndMarkerPosition = function (wp) {
      wp.setLocation(wpAtId.lat(), wpAtId.lng());
      wp.getMarker().getMarker().setPosition(wpAtId);

    };
    var whatToUpdate;
    // if latLng exists - we update already existing waypoint (if user unable to drag marker)
    if (latLng !== undefined) { // this latLng is prev. point
      if (startOfPolyline.getId() == "start") {
        // startLocation and draggable point are the same
        if (id == 0) whatToUpdate = _self.getStartLocation();

        // case when draggable point is endpoint
        else if (id == this.length - 1 && waypoints.getWaypoints().length == this.length) {
          whatToUpdate = _self.getEndLocation();
          // we drag some other polyline point
        } else {
          whatToUpdate = _self.getViaPoint(id - 1);
        }
      }
      // case when polyline starts after direction
      else if (startOfPolyline.getId() !== "end") {
        var _id = 1 * startOfPolyline.getId().split("-")[1];
        whatToUpdate = _id + id == waypoints.getWaypoints().length - 1 ? _self.getEndLocation() : _self.getViaPoint(_id + id);
      } else {
        console.warn("Route waypoint can't be polyline start point");
      }

      whatToUpdate && _setLocationAndMarkerPosition(whatToUpdate);
      routes.build();
    } else {
      // if latLng == undefined - we insert new one with index "via-[startWaypoint + id]"
      if (startOfPolyline.getId() == "start") {
        var newId = id - 1;
        directions.setPathMode(0);
        waypoints.add({
          supressAddState: true,  // we already save state
          id: newId,
          insert: true,
          latlng: map.newLatLng(wpAtId.lat(), wpAtId.lng()),
          geocode: true,
          isPolyline: true
        });
      } else if (startOfPolyline.getId() !== "end") {
        var _id = 1 * startOfPolyline.getId().split("-")[1];
        var newId = _id + id;
        waypoints.add({
          supressAddState: true,  // we already save state
          id: newId,
          insert: true,
          latlng: map.newLatLng(wpAtId.lat(), wpAtId.lng()),
          geocode: true,
          isPolyline: true
        });
      } else {
        console.warn("Route waypoint can't be polyline start point");
      }

      routes.build();
      _.each(_self.getViaPoints(), function (vp) {
        vp.updateIcon()
      });
    }
  };


  if (!options) options = {};
  if (typeof options.polylineOptions == 'undefined') options.polylineOptions = null;
  var rendererOptions = {
    draggable: true,
    preserveViewport: true,
    markerOptions: { draggable: true, visible: false },
    polylineOptions: options.polylineOptions
  };
  this.getDirectionsDisplay = function () {
    var directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
    google.maps.event.addListener(directionsDisplay, "directions_changed", onDirectionsChanged);
    return directionsDisplay;
  };

  var _directionsDisplay = _self.getDirectionsDisplay();
  _directionsDisplays.push(_directionsDisplay);

  var _directionsService = new google.maps.DirectionsService();
  var _markers = [];
  var _startMarker = null; // a temporary marker used to show the starting point of the route when no ending point is specified
  var _readyForReroute = false;
  var _pathMode = 0;
  var _duration;
  var _polyline = null;

  var prepareRequest = function (routePart) {
    var request = {
      origin: new google.maps.LatLng(routePart.origin.latitude, routePart.origin.longitude),
      destination: new google.maps.LatLng(routePart.destination.latitude, routePart.destination.longitude),
      travelMode: google.maps.TravelMode.DRIVING,
      avoidHighways: $('#avoid-highways').is(':checked'),
      avoidTolls: $('#avoid-toll-ways').is(':checked')
    };

    request.waypoints = [];
    for (var i = 0; i < routePart.waypoints.length; i++) {
      request.waypoints.push({
        location: new google.maps.LatLng(routePart.waypoints[i].latitude, routePart.waypoints[i].longitude)
      });
    }
    return request;
  };

  RidingSocial.MapTools.Directions.call(this, options);

  this.events = new RidingSocial.MapTools.Google.EventManager(_directionsDisplay);
  this.events.addListener('directions_changed', onRouteChanged);

  this.setMap = function (m) {
    _directionsDisplay.setMap(m ? m.getMap() : null);
  };
  this.setDuration = function (d) {
    _duration = d;
  };
  this.getDuration = function () {
    return _duration;
  };
  this.getDirectionsRenderer = function () {
    return _directionsDisplay;
  };
  this.route = function (routeParts, index, onsuccess, onfail) {
    if (_pathMode == 1) {
      _self.reset();
      if (_polyline !== null) _polyline.setMap(null);
      _polyline = this.getPolyLine();
      _polyline.setOptions({editable: false});
      _polyline.setPath(_self.getPath());
      _polyline.setMap(map);

      if (onsuccess) onsuccess.call(_self, _self.getPath());

      _readyForReroute = false;
      _self.events.triggerEvent("directions_changed");
      return;
    }

    if (index == routeParts.length) {
      // Get whole route path: _PATH_
      if (onsuccess) onsuccess.call(_self, _self.getPath());

      _self.events.triggerEvent("directions_changed");
      _readyForReroute = true;
      return;
    }

    if (index == 0) {
      /*** reset path, distance and duration on first call */
      _self.reset();
      _self.setPath(null);
      _readyForReroute = false;
    }

    var routePart = routeParts[index];
    var _PATH = _self.getPath() || map.newPath({points: []});

    if (routePart.isPolyline) {
      var points = [new google.maps.LatLng(routePart.origin.latitude, routePart.origin.longitude)];
      _PATH.push(map.newLatLng(routePart.origin.latitude, routePart.origin.longitude));

      for (var i = 0; i < routePart.waypoints.length; i++) {
        var wp = routePart.waypoints[i];
        _PATH.push(map.newLatLng(wp.latitude, wp.longitude));
        points.push(new google.maps.LatLng(wp.latitude, wp.longitude));
      }

      _PATH.push(map.newLatLng(routePart.destination.latitude, routePart.destination.longitude));
      points.push(new google.maps.LatLng(routePart.destination.latitude, routePart.destination.longitude));

      var duration = _self.getDuration() || 0;
      duration += google.maps.geometry.spherical.computeLength(points) / 30;
      _self.setDuration(duration);
      _self.setPath(_PATH);

      /*** create new instance of polyline */
      var __path = map.newPath({points: points});  // path just for this instance
      _polyline = this.getPolyLine();
      _polyline.setOptions({editable: true});
      _polyline.setPath(__path);
      _polyline.setMap(map);
      var pp = _polyline.getPath().getPath();
      _(["insert_at", "set_at", "remove_at"]).each(function (eventName) {
        google.maps.event.addListener(pp, eventName, onPolylineChange);
      });


      /*** Call for next route part ***/
      return _self.route(routeParts, ++index, onsuccess, onfail);
    } else {
      /*** Prepare request to direction service */
      var request = prepareRequest(routePart);

      /*** Make request and display as independent part of map */
      _directionsService.route(request, function (results, status) {
        if (status != google.maps.DirectionsStatus.OK) {
          if (onfail) onfail.call(_self, status);
        } else {
          /*** Create new instance of directionDisplay */
          _directionsDisplay = _self.getDirectionsDisplay();
          _directionsDisplay.setMap(_map.getMap());
          _directionsDisplay.setDirections(results);

          _directionsDisplay.set("origin", request.origin);
          _directionsDisplays.push(_directionsDisplay);

          /*** Extend "global" path */
          //for (var i = 0; i < results.routes[0].overview_path.length; i++)
          //  _PATH.push(map.newLatLng(results.routes[0].overview_path[i].lat(), results.routes[0].overview_path[i].lng()));
          //_self.setPath(_PATH);

          for (var i = 0; i < results.routes[0].legs.length; i++) {
            var leg = results.routes[0].legs[i];
            for (var j = 0; j < leg.steps.length; j++) {
              var step = leg.steps[j];
              var stepPath = step.path;
              for (var k=0; k < stepPath.length; k++){
                var lat = stepPath[k].lat();
                var lng = stepPath[k].lng();
                _PATH.push(map.newLatLng(lat, lng));
              }
            }
          }
          _self.setPath(_PATH);

          /*** Calculate distance and duration, then avgSpeed m/s */
          var duration = _self.getDuration() || 0;
          for (var i = 0, r = results.routes[0]; i < r.legs.length; i++) {
            duration += r.legs[i].duration.value;
          }
          _self.setDuration(duration);

          return _self.route(routeParts, ++index, onsuccess, onfail);
        }
      });
    }
  };

  this.getMarker = function (idx) {
    if (_markers.length == 0 && typeof _directionsDisplay.j.markers != 'undefined' && _directionsDisplay.j.markers.length > 0) {
      for (var i = 0; i < _directionsDisplay.j.markers.length; i++) {
        var m = _map.newMarker({ marker: _directionsDisplay.j.markers[i] });
        m.events.addListener('dragstart', function () {
          _readyForReroute = true;
          _self.setPathMode(0);
        });
        _markers.push(m);
      }
    }

    return (idx <= _markers.length && idx > 0) ? _markers[idx - 1] : null;
  };

  this.getPolyLine = function () {
    var path = this.getPath();
    if (path == null) return null;

    var polyOptions = _.extend({}, RidingSocial.Config.routePolylineOptions,
      { editable: false, clickable: false, path: path }
    );

    return _map.newPolyline(polyOptions);
  };

  this.reset = function () {
    _self.setDuration(0);
    _self.setDistance(0);
    _.each(window._polylines, function (poly) {
      poly.setMap(null);
      _(["insert_at", "set_at", "remove_at"]).each(function (eventName) {
        google.maps.event.clearListeners(poly.getPath(), eventName);
      });
    });
    _.each(_directionsDisplays, function (dd) {
      dd.setMap(null);
      dd.unbindAll();
      dd = null;
    });
    window._polylines = [];
    _directionsDisplays = [];

    if (_polyline !== null) _polyline.setMap(null);
    if (_directionsDisplay !== null) _directionsDisplay.setMap(null);

    _directionsDisplay = _self.getDirectionsDisplay();
  };

  this.setPathMode = function (mode) {
    _pathMode = mode;
  };
  this.getPathMode = function () {
    return _pathMode;
  };
};

RidingSocial.MapTools.Google.Directions.prototype = new RidingSocial.MapTools.Directions();


//*******************************************************************
// Geocoder
//*******************************************************************
RidingSocial.MapTools.Google.Geocoder = function (options) {

  var _geocoder = new google.maps.Geocoder();
  var _self = this;

  RidingSocial.MapTools.Geocoder.call(this, options);

  this.events = new RidingSocial.MapTools.Google.EventManager(_geocoder);

  this.geocode = function (address, onsuccess, onfail) {
    var deferred = jQuery.Deferred();
    _geocoder.geocode({ address: address }, function (results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        onsuccess.call(_self, results);
        deferred.resolve();
      } else {
        onfail.call(_self, status);
        deferred.reject();
      }
    });
    return deferred.promise();
  };

  this.reverse = function (location, onsuccess, onfail) {
    var deferred = $.Deferred();
    _geocoder.geocode({ location: location.getLatLng() }, function (results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        onsuccess.call(_self, results);
        deferred.resolve();
      } else {
        onfail.call(_self, status);
        deferred.reject();
      }
    });
    return deferred.promise();
  };
};

RidingSocial.MapTools.Google.Geocoder.prototype = new RidingSocial.MapTools.Geocoder();


//*******************************************************************
// InfoBox
//*******************************************************************
RidingSocial.MapTools.Google.InfoBox = function (options) {

  var _googleOptions = {};
  var _map = null;
  if (options && typeof options.content != 'undefined') _googleOptions.content = options.content;
  if (options && typeof options.pixelOffset != 'undefined') _googleOptions.pixelOffset = new google.maps.Size(options.pixelOffset[0], options.pixelOffset[1]);
  if (options && typeof options.map != 'undefined') _map = options.map;

  var _infobox = new google.maps.InfoWindow(_googleOptions);

  RidingSocial.MapTools.InfoBox.call(this, options);

  this.events = new RidingSocial.MapTools.Google.EventManager(_infobox);

  this.getInfoBox = function () {
    return _infobox;
  };
  this.close = function () {
    _infobox.close();
  };
  this.open = function () {
    _infobox.open(_map ? _map.getMap() : null);
  };
  this.setContent = function (c) {
    _infobox.setContent(c);
  };
  this.setPosition = function (latlng) {
    if (latlng instanceof RidingSocial.MapTools.LatLng) _infobox.setPosition(latlng.getLatLng());
  };
};

RidingSocial.MapTools.Google.InfoBox.prototype = new RidingSocial.MapTools.InfoBox();


//*******************************************************************
// Elevation Profile
//*******************************************************************
RidingSocial.MapTools.Google.ElevationProfile = function (options) {
  var elevator = false;
  var samplingPointCount = 199;
  var _self = this;

  var dom = document.getElementById('ElevationsProfileChart');

  _self.hoverMarker = undefined;
  _self.selectedMarkers = [];
  _self.markerImage = {
    url: mapviewConf.waypointMarkerUrl,
    size: new google.maps.Size(20, 20),   // This marker is 20 pixels wide by 20 pixels tall.
    origin: new google.maps.Point(0, 0),   // The origin for this image is 0,0.
    anchor: new google.maps.Point(10, 10)  // The anchor for this image is the base of the flagpole at 10,10.
  };

  var sampleDown = function (paths) {
    if (paths.length < samplingPointCount) {
      return paths;
    }
    var step = (paths.length - 1) / samplingPointCount;
    var ret = [];
    for (var i = 0.0; i < paths.length - 1; i += step) {
      ret.push(paths[Math.floor(i)]);
    }
    ret.push(paths[paths.length - 1]);
    return ret;
  };
  this.init = function () {
    var deferred = jQuery.Deferred();
    google.load("visualization", "1", {
      packages: ['corechart'],
      callback: function () {
        if (elevator === false) {
          elevator = new google.maps.ElevationService();
        }
        deferred.resolve();
      }
    });
    return deferred.promise();
  };

  this.clear = function () {
    $(dom).html('');
  };

  function plotElevation(results, status) {
    if (status != google.maps.ElevationStatus.OK) return;

    var elevations = results;
    var elevationPath = [];
    var distance = directions.getDistance();  // meters
    var resultsLength = results.length;
    if (distance == 0) {
      for (var i = 1; i < resultsLength; i++) {
        distance += google.maps.geometry.spherical.computeDistanceBetween(elevations[i - 1].location, elevations[i].location)
      }
    }
    var increment = Math.round(distance / resultsLength);
    var dist = 0;
    var elevation = 0;

    for (var i = 0; i < resultsLength; i++) {
      elevationPath.push(elevations[i].location);
    }

    var pathOptions = {
      path: elevationPath,
      strokeColor: '#0000CC',
      opacity: 0.4,
      map: map.getMap()
    };

    var data = new google.visualization.DataTable();
    data.addColumn('number', 'Distance');
    data.addColumn('number', 'Elevation');
    data.addColumn('number', 'lat');
    data.addColumn('number', 'lng');
    for (var i = 0; i < resultsLength; i++) {
      dist = increment * i;                 // meters
      elevation = elevations[i].elevation;  // meters

      if (directions.getMetric()) {
        dist /= 1000;                       // kilometers
      } else {
        dist /= 1609.344;                   // miles
        elevation *= 3.2808399;             // feets
      }
      data.addRow([
        parseFloat(dist.toFixed(2)),
        Math.floor(elevation),
        elevations[i].location.lat(),
        elevations[i].location.lng()
      ]);
    }
    data.addRow([null, null, null, null]);

    var view = new google.visualization.DataView(data);
    view.setColumns([0, 1]);

    var hAxisOptions = {
      gridlines: {
        color: "#s2f1a1a",
        count: 12
      },
      textStyle: {
        fontName: "Open Sans",
        fontSize: 14
      }
    };
    var vAxisOptions = {
      textStyle: {
        fontName: "Open Sans",
        fontSize: 14
      }
    };
    var seriesOptions = {0: {
      color: "#E67225",
      areaOpacity: 0.65
    }};

    dom.style.display = 'block';
    wrapper.setDataTable(data);
    wrapper.setView(view.toJSON());
    wrapper.setOptions({
      height: 150,
      width: 900,
      legend: 'none',
      tooltip: {trigger: 'none'},
      titleY: directions.getMetric() ? 'Elevation (m)' : 'Elevation (ft)',
      hAxis: hAxisOptions,
      vAxis: vAxisOptions,
      series: seriesOptions,
      crosshair: {trigger: 'both', orientation: 'vertical', color: "gray" },
      focusTarget: 'category'
    });
    wrapper.draw();
  }

  this.displayProfileChart = function (path) {
    if (!dom) return;
    wrapper = new google.visualization.ChartWrapper({
      chartType: 'AreaChart',
      containerId: dom.id
    });

    var runOnce = google.visualization.events.addListener(wrapper, 'ready', function () {
      google.visualization.events.removeListener(runOnce);
      var data = wrapper.getDataTable();
      var _template = _.template("<strong>Dist</strong>: <%= dist %></br>" +
        "<strong>Elev</strong>: <%= elevation %>");

      $(dom).append("<div id='PopupTooltip'></div>");

      $(dom).mousemove("mousemove", function (e) {
        var xPos = e.pageX - dom.offsetLeft;
        var yPos = e.pageY - dom.offsetTop;
        var cli = wrapper.getChart().getChartLayoutInterface();
        var xBounds = cli.getBoundingBox('hAxis#0#gridline');
        var yBounds = cli.getBoundingBox('vAxis#0#gridline');

        if (
          (xPos >= xBounds.left || xPos <= xBounds.left + xBounds.width) &&
          (yPos >= yBounds.top || yPos <= yBounds.top + yBounds.height)
          ) {
          xPos -= $("#ElevationsProfileChartHolder").position().left;

          var xVal = cli.getHAxisValue(xPos);
          var rowIndexes = data.getFilteredRows([
            {column: 0, minValue: parseFloat(xVal.toFixed(2))}
          ]);
          if (rowIndexes.length) {
            var value = data.getValue(rowIndexes[0], 1);
            // add floating popUp tooltip
            $("#PopupTooltip").show().html(_template({dist: xVal.toFixed(2), elevation: value})).css("left", xPos + 5);
            var lat = data.getValue(rowIndexes[0], 2);
            var lng = data.getValue(rowIndexes[0], 3);
            if (!_self.hoverMarker) {
              _self.hoverMarker = new google.maps.Marker({
                position: new google.maps.LatLng(lat, lng),
                map: map.getMap(),
                icon: _self.markerImage
              });
            } else {
              _self.hoverMarker.setPosition(new google.maps.LatLng(lat, lng));
            }
          }
          if (xVal < 0 || !rowIndexes.length || !value) $("#PopupTooltip").hide();
        }
      });
      $(dom).mouseleave(function (e) {
        _self.hoverMarker && _self.hoverMarker.setMap(null);
      });
      $(dom).mouseenter(function (e) {
        _self.hoverMarker && _self.hoverMarker.setMap(map.getMap());
      });

    });

    var __path = [];
    try {
      __path = path.getPath().getArray();
    }
    catch (e) {
      __path = path.getPath();
    }

    var pathRequest = {
      'path': sampleDown(__path),
      'samples': samplingPointCount
    };

    elevator && elevator.getElevationAlongPath(pathRequest, plotElevation);
  };
};

RidingSocial.MapTools.Google.LatLngViaPoint = function (_map, _lat, _lng, _alt) {

  RidingSocial.MapTools.LatLngViaPoint.call(this, _map, _lat, _lng, _alt);
  var _self = this;
  var _marker;
  var onDragEnd = function (event) {
    _marker.getMarker().setPosition(event.latLng);
    _self.setLocation(event.latLng.lat(), event.latLng.lng());
    directions.setPathMode(0);
    routes.build();
  };
  var onDragStart = function (event) {
    waypoints.addState();
  };

  var _parentCreateMarker = this.createMarker;
  this.createMarker = function () {
    _marker = _parentCreateMarker.call(this);
    this.events = new RidingSocial.MapTools.Google.EventManager(_marker.getMarker());
    this.events.addListener('dragend', onDragEnd);
    this.events.addListener('dragstart', onDragStart);
    return _marker;
  };
  this.hide = function () {
    _marker.setMap(null);
  };
};
RidingSocial.MapTools.Google.LatLngViaPoint.prototype = new RidingSocial.MapTools.LatLngViaPoint();

RidingSocial.MapTools.Google.FusionLayer = function (map, options) {
  this.setMap(map);
  options.map = map.getMap();
  var _layer = new google.maps.FusionTablesLayer(options);
  this.getLayer = function () {
    return _layer;
  };
  _parentSetMap = this.setMap;
  this.setMap = function (map) {
    _parentSetMap(map);
    _layer.setMap(map == null ? null : map.getMap());
  };
};
RidingSocial.MapTools.Google.FusionLayer.prototype = new RidingSocial.MapTools.Layer();

//*******************************************************************
// Map
//*******************************************************************
RidingSocial.MapTools.Google.Map = function (options) {
  var _self = this;

  var mapOptions = {
    zoom: options.zoom,
    center: new google.maps.LatLng(options.center.lat(), options.center.lng()),
    mapTypeControl: true,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };
  isEmbed && _(mapOptions).extend(
    {
      panControl: false,
      zoomControl: true,
      zoomControlOptions: {
        style: google.maps.ZoomControlStyle.SMALL,
        position: google.maps.ControlPosition.LEFT_TOP
      },
      scaleControl: false,
      streetViewControl: false
    }
  );

  var _map = new google.maps.Map(document.getElementById(options.domNode), mapOptions);
  google.maps.event.addListenerOnce(_map, 'idle', function () {
    RidingSocial.MapTools.mapLoader.resolve();
  });

  RidingSocial.MapTools.Map.call(this, options);

  this.events = new RidingSocial.MapTools.Google.EventManager(_map);

  this.getMap = function () {
    return _map;
  };
  this.getZoom = function () {
    return _map.getZoom();
  };
  this.setZoom = function (z) {
    _map.setZoom(z);
  };
  this.getBounds = function () {
    var b = _map.getBounds();
    return this.newLatLngBounds(this.newLatLng(b.getSouthWest().lat(), b.getSouthWest().lng()), this.newLatLng(b.getNorthEast().lat(), b.getNorthEast().lng()));
  };
  this.getCenter = function () {
    var c = _map.getCenter();
    return this.newLatLng(c.lat(), c.lng());
  };
  this.setCenter = function (c) {
    _map.setCenter(c.getLatLng());
  };
  this.fitBounds = function (bounds) {
    _map.fitBounds(bounds.getBounds());
  };

  this.newIcon = function (url, size, offset, anchor) {
    return {
      url: url,
      size: new google.maps.Size(size[0], size[1]),
      origin: new google.maps.Point(offset[0], offset[1]),
      anchor: new google.maps.Point(anchor[0], anchor[1])
    };
  };

  this.newPolyShape = function (coords) {
    return {
      coord: coords,
      type: 'poly'
    };
  };

  this.newDirections = function (options) {
    return new RidingSocial.MapTools.Google.Directions(_self, options);
  };
  this.newPlaces = function (options) {
    return new RidingSocial.MapTools.Google.Places(options);
  };
  this.newGeocoder = function (options) {
    return new RidingSocial.MapTools.Google.Geocoder(options);
  };
  this.newPath = function (options) {
    return new RidingSocial.MapTools.Google.Path(options);
  };
  this.newPolyline = function (options) {
    return new RidingSocial.MapTools.Google.Polyline(options);
  };
  this.newMarker = function (options) {
    return new RidingSocial.MapTools.Google.Marker(options);
  };
  this.newInfoBox = function (options) {
    return new RidingSocial.MapTools.Google.InfoBox(options);
  };
  this.newLatLng = function (lat, lng) {
    return new RidingSocial.MapTools.Google.LatLng(lat, lng);
  };
  this.newLatLngViaPoint = function (lat, lng, alt) {
    return new RidingSocial.MapTools.Google.LatLngViaPoint(this, lat, lng, alt);
  };
  this.newLatLngBounds = function (sw, ne) {
    return new RidingSocial.MapTools.Google.LatLngBounds(sw, ne);
  };
  this.newElevationProfile = function () {
    return new RidingSocial.MapTools.Google.ElevationProfile({map: _self});
  };
  this.newLayer = function (options) {
    return new RidingSocial.MapTools.Google.FusionLayer(this, options);
  };
  this.newBoundsFromRoute = function (route) {
    var bounds;
    bounds = new google.maps.LatLngBounds();
    route.getPath().forEach(function (e) {
      bounds.extend(e);
    });

    return this.newLatLngBounds(bounds.getSouthWest(), bounds.getNorthEast());
  };
  this.newPathFromArray = function (a) {
    var path = this.newPath({points: []});
    for (var i = 0; i < a.length; i++) {
      path.push(map.newLatLng(a[i][0], a[i][1]));
    }
    return path;
  };


};

RidingSocial.MapTools.Google.Map.prototype = new RidingSocial.MapTools.Map();

google.maps.event.addDomListener(window, 'load', function () {
  if (document.getElementById('butler-map') != null) {

    var $h = $('.logged-in #butler-map-holder');
    var width = $h.width() - 110;
    $h.width(width);
    $('.logged-in #butler-map').width(width);
    map = new RidingSocial.MapTools.Google.Map({
      domNode: 'butler-map',
      center: new RidingSocial.MapTools.Google.LatLng(37.46603, -107.46670),
      zoom: 5
    });
    if (mapviewConf.userInfo != '') {
      var geocoder = map.newGeocoder();
      geocoder.geocode(mapviewConf.userInfo, function (result) {
        if (result.length == 0 || typeof result[0].geometry.location === "undefined") {
          return;
        }
        var l = result[0].geometry.location;
        var latlng = map.newLatLng(l.lat(), l.lng());
        map.setCenter(latlng);
        map.setZoom(5);
      });
    }
  }
});
