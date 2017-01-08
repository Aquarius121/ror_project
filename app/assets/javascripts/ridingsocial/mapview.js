RidingSocial = {};
RidingSocial.MapTools = { };
RidingSocial.MapTools.mapLoader = jQuery.Deferred();
RidingSocial.MapTools.then = function (cb) {
  if ($.isFunction(cb)) {
    RidingSocial.MapTools.mapLoader.then(cb);
  }
};
RidingSocial.getRating = function (type, attributes) {
  var textrating = 'Unrated';
  var texttype = '';
  var classname = 'track-unrated';
  var color = '#000000';

  switch (parseInt(type)) {
    case 1:
      color = '#ffff00';
      textrating = 'G1';
      classname = "track-g1";
      break;
    case 2:
      color = '#ff0000';
      textrating = 'G2';
      classname = "track-g2";
      break;
    case 3:
      color = '#ffa500';
      textrating = 'G3';
      classname = "track-g3";
      break;
  }
  if (parseInt(attributes) & 1) // lost highway
  {
    color = '#808080';
    texttype = ' Lost Highway';
    classname = "track-lh";
  }
  if (parseInt(attributes) & 2) // PMT
  {
    color = '#008000';
    texttype = ' Paved Mtn Trail';
    classname = "track-pmt";
  }
  if (parseInt(attributes) & 4) // Dirt
  {
    color = '#a52a2a';
    texttype = ' Dirt';
    classname = "track-dirt";
  }

  return { textrating: textrating + texttype, classname: classname, color: color };
};
RidingSocial.EventManager = function (_obj) {
  var _listeners = {};

  this.addListener = function (name, handler) {
    if (typeof _listeners[name] == 'undefined')
      _listeners[name] = [];

    _listeners[name].push(handler);

    return { name: name, id: _listeners[name].length };
  };

  this.removeListener = function (listener) {
    console.log("mapview\tremoveListener", listener);

    if (typeof _listeners[listener.name] == 'undefined' || _listeners[listener.name].length < listener.id)
      return;

    _listeners[listener.name].splice(listener.id, 1);
  };

  this.clearListeners = function () {
    var keys = [];
    $(_listeners).each(function (key, val) {
      keys.push(key);
    });

    for (var i = 0; i < keys.length; i++)
      this.removeListener(_listeners[keys[i]]);
  };

  this.fireEvent = function (name, callback) {
    if (typeof _listeners[name] == 'undefined')
      return;

    for (var i = 0; i < _listeners[name].length; i++)
      callback(_listeners[name][i]);
  };

  this.triggerEvent = function (name, value) {
  };
};
/*****************************************************************/
// ViaPoint
/*****************************************************************/
RidingSocial.MapTools.ViaPoint = function (_map) {
  var _type = '';
  var _location = null;
  var _textlocation = null;
  var _label = null;
  var _iconname = null;
  var _iconid = null;
  var _marker = null;

  this.events = new RidingSocial.EventManager();
  this.getType = function () {
    return _type;
  };
  this.getLocation = function () {
    return _location;
  };
  this.getTextLocation = function () {
    return _textlocation;
  };
  this.getLabel = function () {
    return _label;
  };

  this.setType = function (t) {
    _type = t;
  };
  this.setLocation = function (l) {
    _location = l;
  };
  this.setTextLocation = function (l) {
    _textlocation = l;
  };
  this.setLabel = function (l) {
    _label = l;
  };

  this.setIcon = function (name, id) {
    _iconname = name;
    _iconid = id;
  };

  this.getIcon = function () {
    var origin = [0, 10];
    if (_iconname == 'start')
      origin = [0, 760];
    else if (_iconname == 'end')
      origin = [0, 860];
    else
      origin = [0, 860 + ((_iconid + 1) * 50)];

    var icon = _map.newIcon(mapviewConf.markerUrl, [30, 40], origin, [15, 40]);
    var shape = _map.newPolyShape([1, 1, 1, 20, 15, 40, 30, 20, 30, 1]);

    return { shape: shape, icon: icon };
  };

  this.createMarker = function () {
    var icon = this.getIcon();
    if (_marker != null) {
      _marker.setPosition(this.getLocation());
      _marker.setIcon(icon.icon);
      return _marker;
    }

    var markerOptions = {
      map: _map,
      draggable: true,
      zIndex: 1000,
      position: this.getLocation(),
      shape: icon.shape,
      icon: icon.icon
    };
    _marker = _map.newMarker(markerOptions);
    return _marker;
  };

  this.getMarker = function () {
    return _marker;
  };

  this.updateIcon = function () {
    var icon = this.getIcon();
    _marker.setIcon(icon.icon);
  };

  this.getId = function () {
    if (_iconname != 'via') {
      return _iconname;
    }
    return _iconname + '-' + _iconid;
  };
};


/*****************************************************************/
// LatLngViaPoint
/*****************************************************************/
RidingSocial.MapTools.LatLngViaPoint = function (_map, _lat, _lng, _alt) {

  RidingSocial.MapTools.ViaPoint.call(this, _map);

  var parentSetLocation = this.setLocation;
  this.setLocation = function (lat, lng) {
    if (_map) parentSetLocation(_map.newLatLng(lat, lng));
  };

  this.setType('latlng');
  this.setLocation(_lat, _lng);
  this.setTextLocation(_lat + ' ' + _lng);
  this.setLabel(_lat + ' ' + _lng);
};

RidingSocial.MapTools.LatLngViaPoint.prototype = new RidingSocial.MapTools.ViaPoint();


/*****************************************************************/
// AddressViaPoint
/*****************************************************************/
RidingSocial.MapTools.AddressViaPoint = function (_map, _address) {

  RidingSocial.MapTools.ViaPoint.call(this, _map);

  this.setType('address');
  this.setLocation(_address);
  this.setTextLocation(_address);
  this.setLabel(_address);
};

RidingSocial.MapTools.AddressViaPoint.prototype = new RidingSocial.MapTools.ViaPoint();


/*****************************************************************/
// MtgViaPoint
/*****************************************************************/
RidingSocial.MapTools.MtgViaPoint = function (_map, _label, _lat, _lng, _alt, _id) {

  RidingSocial.MapTools.LatLngViaPoint.call(this, _map, _lat, _lng, _alt);

  this.setType('mtg');
  this.setLabel(_label);
  this.setLabel = function (l) {
    console.log('Mobile Tour Guide viapoint labels can not be changed');
  };
  //this.setLocation(_id);
};

RidingSocial.MapTools.MtgViaPoint.prototype = new RidingSocial.MapTools.LatLngViaPoint(null, null, null, null);


/*****************************************************************/
// G1Point
/*****************************************************************/
RidingSocial.MapTools.G1Point = function (_map, _label, _lat, _lng, _alt) {

  RidingSocial.MapTools.LatLngViaPoint.call(this, _map, _lat, _lng, _alt);

  this.setType('g1');
  this.setLabel(_label);
  this.getIcon = function () {
    var origin = [0, 0];
    var icon = _map.newIcon(mapviewConf.butlerRideMarkerUrl, [34, 50], origin, [15, 40]);
    icon['scaledSize'] = new google.maps.Size(30, 40);
    var shape = _map.newPolyShape([1, 1, 1, 20, 15, 40, 30, 20, 30, 1]);
    return { shape: shape, icon: icon };
  };
};

RidingSocial.MapTools.G1Point.prototype = new RidingSocial.MapTools.LatLngViaPoint(null, null, null, null);


//*******************************************************************
// Path
//*******************************************************************
RidingSocial.MapTools.Path = function () {

  var _path = [];
  var _self = this;
  var _insertAt = function (idx, val) {
    if (!(val instanceof RidingSocial.MapTools.LatLng) || idx > _path.length || idx < 0)
      return;

    if (idx == _path.length)
      _path.push(val);
    else
      _path.splice(idx, 0, val);

    _self.events.fireEvent('insert_at', function (handler) {
      handler.call(_self, idx);
    });
  };

  this.events = new RidingSocial.EventManager();

  this.getLength = function () {
    return _path.length;
  };
  this.getAt = function (idx) {
    return (idx < _path.length && idx >= 0) ? _path[idx] : null;
  };
  this.push = function (val) {
    _insertAt(_path.length, val);
  };
  this.insertAt = function (idx, val) {
    _insertAt(idx, val);
  };

  this.forEach = function (callback) {
    for (var i = 0; i < _path.length; i++) callback(path[i], i);
  };

  this.setAt = function (idx, val) {
    if (!(val instanceof RidingSocial.MapTools.LatLng) || idx >= _path.length || idx < 0)
      return;

    var oldval = _path[idx];
    _path[idx] = val;

    _self.events.fireEvent('set_at', function (handler) {
      handler.call(_self, idx, oldval);
    });
  };

  this.forEach = function (callback) {
    for (var i = 0; i < this.getLength(); i++)
      callback(this.getAt(i), i);
  };

  this.offset = function (miles) {
    var scale = 5000;
    var degToMiles = 60;
    var miles = (miles / degToMiles) * scale;
    var path = new ClipperLib.Paths();
    var solution = new ClipperLib.Paths();
    var co = new ClipperLib.ClipperOffset(2, 1);

    path[0] = [];
    for (var i = 0; i < this.getLength(); i++)
      path[0].push({'X': this.getAt(i).lat(), 'Y': this.getAt(i).lng()});

    ClipperLib.JS.ScaleUpPaths(path, scale);
    co.AddPaths(path, ClipperLib.JoinType.jtRound, ClipperLib.EndType.etOpenRound);
    co.Execute(solution, miles);
    ClipperLib.JS.ScaleDownPaths(solution, scale);

    return solution;
  };

  this.optimize = function (_map, distance_interval) {
    if (distance_interval !== null && distance_interval == 0) return this;

    var path = _map.newPath();
    var prevpoint = null;
    var path_dist = 0;
    if (distance_interval === null || distance_interval < 0) distance_interval = 175; // 575 feet

    var numPoints = this.getLength();
    for (var i = 0; i < numPoints; i++) {
      var latlng = this.getAt(i);
      if (prevpoint == null || i == (numPoints - 1)) {
        path.push(latlng);
      } else {
        path_dist += prevpoint.getDistance(latlng);
        if (path_dist >= distance_interval) {
          path_dist = 0;
          path.push(latlng);
        }
      }
      prevpoint = latlng;
    }
    return path;
  };

};


//*******************************************************************
// LatLng
//*******************************************************************
RidingSocial.MapTools.LatLng = function (_lat, _lng) {

  this.events = new RidingSocial.EventManager();

  this.lat = function () {
    return _lat;
  };
  this.lng = function () {
    return _lng;
  };
  this.getLatLng = function () {
    return this;
  };

  this.getDistance = function (toLatLng) {
    earthRadius = 6371000;
    var latFrom = _lat * (Math.PI / 180);
    var lonFrom = _lng * (Math.PI / 180);
    var latTo = toLatLng.lat() * (Math.PI / 180);
    var lonTo = toLatLng.lng() * (Math.PI / 180);

    var lonDelta = lonTo - lonFrom;
    var a = Math.pow(Math.cos(latTo) * Math.sin(lonDelta), 2) +
      Math.pow(Math.cos(latFrom) * Math.sin(latTo) - Math.sin(latFrom) * Math.cos(latTo) * Math.cos(lonDelta), 2);
    var b = Math.sin(latFrom) * Math.sin(latTo) + Math.cos(latFrom) * Math.cos(latTo) * Math.cos(lonDelta);

    var angle = Math.atan2(Math.sqrt(a), b);
    return angle * earthRadius;
  };
};


//*******************************************************************
// LatLngBounds
//*******************************************************************
RidingSocial.MapTools.LatLngBounds = function (_sw, _ne) {

  this.events = new RidingSocial.EventManager();

  this.getNorthEast = function () {
    return _ne;
  };
  this.getSouthWest = function () {
    return _sw;
  };
  this.setNorthEast = function (ne) {
    _ne = ne;
  };
  this.setSouthWest = function (sw) {
    _sw = sw;
  };
  this.extend = function (latlng) {
  };
};


//*******************************************************************
// Places
//*******************************************************************
RidingSocial.MapTools.Places = function () {

  this.events = new RidingSocial.EventManager();
  this.bindAutocompleteTo = function (element) {
  };
};


//*******************************************************************
// Directions
//*******************************************************************
RidingSocial.MapTools.Directions = function () {

  var _startLocation = null;
  var _startAddress = null;
  var _endLocation = null;
  var _endAddress = null;
  var _distance = 0;
  var _path = null;
  var _viaPoints = [];
  var _viaIdx = 0;
  var _isLast = true;
  var _isMetric = false;

  this.events = new RidingSocial.EventManager();

  this.route = function (viaIdx, isLast, onsuccess, onfail) {
    console.log('Can not route from base Directions class');
    if (onfail) onfail.call(this, -1);
  };

  this.getPath = function () {
    return _path;
  };
  this.getDistance = function () {
    return _distance;
  };
  this.getStartLocation = function () {
    return _startLocation;
  };
  this.getEndLocation = function () {
    return _endLocation;
  };
  this.getViaPoints = function () {
    return _viaPoints;
  };
  this.getViaPoint = function (idx) {
    return _viaPoints.length > idx ? _viaPoints[idx] : null;
  };
  this.getCount = function () {
    return _viaPoints.length;
  };
  this.getViaIdx = function () {
    return _viaIdx;
  };
  this.getIsLast = function () {
    return _isLast;
  };
  this.getMetric = function () {
    return _isMetric
  };
  this.setViaIdx = function (idx) {
    _viaIdx = (idx < 0 ? 0 : idx);
  };
  this.setIsLast = function (isLast) {
    _isLast = isLast;
  };
  this.setPath = function (path) {
    _path = path;
  };
  this.setDistance = function (distance) {
    _distance = distance;
  };
  this.setMetric = function (metric) {
    _isMetric = Boolean(metric) || false;
  };

  this.insertViaPoint = function (atIdx, loc) {
    var _viaPointsOrig = _.clone(_viaPoints);
    _viaPoints = [];

    for (var i = 0; i < _viaPointsOrig.length; i++) {
      if (i == atIdx) this.addViaPoint(loc);
      this.addViaPoint(_viaPointsOrig[i]);
    }
    if (i == atIdx) this.addViaPoint(loc);
  };

  this.setStartLocation = function (startLocation) {
    if (startLocation)
      startLocation.setIcon((_viaIdx > 1 ? 'via' : 'start'), _viaIdx);
    return _startLocation = startLocation;
  };

  this.setEndLocation = function (endLocation) {
    if (endLocation)
      endLocation.setIcon(_isLast ? 'end' : 'via', _viaIdx + _viaPoints.length);
    return _endLocation = endLocation;
  };
  this.setViaPoints = function (v) {
    _viaPoints = [];
    if (!v) return;

    for (var i = 0; i < v.length; i++) this.addViaPoint(v[i]);
  };

  this.addViaPoint = function (loc) {
    loc.setIcon('via', _viaIdx + _viaPoints.length);
    _viaPoints.push(loc);
  };

};


//*******************************************************************
// Geocoder
//*******************************************************************
RidingSocial.MapTools.Geocoder = function () {

  this.events = new RidingSocial.EventManager();
  this.geocode = function (address, onsuccess, onfail) {
    onfail(-1);
  };
};


//*******************************************************************
// Polyline
//*******************************************************************
RidingSocial.MapTools.Polyline = function (options) {
  var _path = [];

  this.events = new RidingSocial.EventManager();

  this.getPath = function () {
    return _path;
  };
  this.setPath = function (p) {
    if (p instanceof RidingSocial.MapTools.Path) _path = p;
  };
  this.setMap = function (m) {
    console.log('Can not add base polyline to a map');
  };
  this.setOptions = function (o) {
    console.log('Can set options of base polyline');
  };
};


//*******************************************************************
// Marker
//*******************************************************************
RidingSocial.MapTools.Marker = function (options) {

  var _position = new RidingSocial.MapTools.LatLng(0, 0);

  this.events = new RidingSocial.EventManager();
  this.getPosition = function () {
    return _position;
  };
  this.setPosition = function (latlng) {
    _position = latlng;
  };
  this.setMap = function (m) {
    console.log('Can not add base marker to a map');
  };
};


//*******************************************************************
// InfoBox
//*******************************************************************
RidingSocial.MapTools.InfoBox = function (options) {

  this.events = new RidingSocial.EventManager();

  this.close = function () {
  };
  this.open = function () {
  };
  this.setContent = function (c) {
  };
  this.setPosition = function (p) {
  };
};

RidingSocial.MapTools.Layer = function (map, options) {
  var _map = map;
  this.setMap = function (map) {
    _map = map;
  };
  this.getMap = function () {
    return _map;
  };
  this.getLayer = function () {
    return false;
  };
};
//*******************************************************************
// Map
//*******************************************************************
RidingSocial.MapTools.Map = function () {

  this.events = new RidingSocial.EventManager();

  this.getZoom = function () {
  };
  this.setZoom = function () {
  };
  this.getBounds = function () {
  };
  this.getCenter = function () {
  };
  this.setCenter = function (c) {
  };
  this.fitBounds = function (bounds) {
  };

  this.newIcon = function (url, size, offset, anchor) {
  };
  this.newPolyShape = function (coords) {
  };
  this.newViaPoint = function () {
    return new RidingSocial.MapTools.ViaPoint(this);
  };
  this.newLatLngViaPoint = function (lat, lng, alt) {
    return new RidingSocial.MapTools.LatLngViaPoint(this, lat, lng, alt);
  };
  this.newAddressViaPoint = function (address) {
    return new RidingSocial.MapTools.AddressViaPoint(this, address);
  };
  this.newMtgViaPoint = function (title, lat, lng, alt, id) {
    return new RidingSocial.MapTools.MtgViaPoint(this, title, lat, lng, alt, id);
  };
  this.newG1Point = function (title, lat, lng, alt) {
    return new RidingSocial.MapTools.G1Point(this, title, lat, lng, alt);
  };
  this.newDirections = function (options) {
    return new RidingSocial.MapTools.Directions(options);
  };
  this.newPlaces = function (options) {
    return new RidingSocial.MapTools.Places(options);
  };
  this.newGeocoder = function (options) {
    return new RidingSocial.MapTools.Geocoder(options);
  };
  this.newPath = function (options) {
    return new RidingSocial.MapTools.Path(options);
  };
  this.newPolyline = function (options) {
    return new RidingSocial.MapTools.Polyline(options);
  };
  this.newMarker = function (options) {
    return new RidingSocial.MapTools.Marker(options);
  };
  this.newInfoBox = function (options) {
    return new RidingSocial.MapTools.Infobox(options);
  };
  this.newLatLng = function (lat, lng) {
    return new RidingSocial.MapTools.LatLng(lat, lng);
  };
  this.newLatLngBounds = function (sw, ne) {
    return new RidingSocial.MapTools.LatLngBounds(sw, ne);
  };
  this.newElevationProfile = function () {
    return false;
  };
  this.newLayer = function (options) {
    return new RidingSocial.MapTools.Layer(this, options);
  };
};