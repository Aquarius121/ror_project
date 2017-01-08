tracks = (function ($) {
  var ftId = '';
  var pmtFtId = '';
  var layer = null;
  var dirtLayer = null;
  var pmtLayer = null;
  var visible = {
    'track-g1': true,
    'track-g2': true,
    'track-g3': true,
    'track-lh': true,
    'track-pmt': true,
    'track-dirt': true,
    'track-unrated': false,
    'track-g1-markers': true
  };
  var styles = RidingSocial.Config.trackStyles;
  var layerStyle = null;
  var filterableColors = [
    'track-g1',
    'track-g2',
    'track-g3',
    'track-lh',
    'track-pmt',
    'track-dirt'
  ];
  var lines = {
    'track-lh': [],
    'track-pmt': [],
    'track-dirt': [],
    'track-g1-markers': []
  };

  var shouldLoad = function (type) {
    return visible[type] && lines[type].length == 0 && map.getZoom() > 7;
  };

  var reloadData = function () {
    shouldLoad('track-g1-markers') && loadG1();
  };

  var updateStylesWithVisibility = function () {
    layerStyle = [
      {
        polylineOptions: styles['invisible']
      },
      {
        polylineOptions: visible['track-g1'] ? styles['track-g1'] : styles['invisible'],
        where: "'type' in (1)"
      },
      {
        polylineOptions: visible['track-g2'] ? styles['track-g2'] : styles['invisible'],
        where: "'type' in (2)"
      },
      {
        polylineOptions: visible['track-g3'] ? styles['track-g3'] : styles['invisible'],
        where: "'type' in (3)"
      }
    ];
  };

  var newLayer = function (ftId, where, styles) {
    if (ftId === '') return null;

    return map.newLayer({
      clickable: false,
      suppressInfoWindows: true,
      query: {
        select: 'geometry',
        from: ftId,
        where: where
      },
      styles: styles
    });
  };

  var redraw = function () {
    // need this in case user switched on some layers that were not loaded before
    reloadData();

    updateStylesWithVisibility();
    layer && layer.getLayer().setOptions({styles: layerStyle});

    dirtLayer && dirtLayer.setMap(visible['track-dirt'] ? map : null);
    pmtLayer && pmtLayer.setMap(visible['track-pmt'] ? map : null);

    var markers = lines['track-g1-markers'];
    if (markers.length > 0) {
      for (var i in markers) {
        markers[i].setMap(visible['track-g1-markers'] ? map.getMap() : null);
      }
    }

    setLayersCookie();
  };

  var loadG1 = function () {
    if (lines['track-g1-markers'].length > 0) return;
    if (mapviewConf.g1MarkersUrl == '') return;
    $.ajax({
      url: mapviewConf.g1MarkersUrl,
      dataType: "json",
      success: function (g1Points) {
        _(g1Points).each(function (point) {
          var mapPoint = map.newG1Point(point.title, point.latitude, point.longitude);
          var marker = mapPoint.createMarker();
          marker.setDraggable(false);
          marker.events.addListener('click', function () {
            loadButlerRide(point.id);
          });
          lines['track-g1-markers'].push(marker.getMarker());
        });
      }
    });
  };

  var setLayersCookie = function () {
    var cookie = [];
    for (var i in visible) {
      if (!visible[i]) cookie.push(i.replace('track-', ''));
    }
    $.cookie('layers', cookie.join('|'), { expires: 365, path: '/' });
  };

  var readLayersCookie = function () {
    var cookie = $.cookie('layers');
    if (!cookie) return;
    cookie = cookie.split('|');
    _(cookie).each(function (i) {
      var trackId = 'track-' + i;
      visible[trackId] = false;
      $('[data-layer="' + trackId + '"]').removeClass('active');
    });
  };

  RidingSocial.MapTools.then(function () {
    ftId = mapviewConf.featureId;
    pmtFtId = mapviewConf.pmtFeatureId;
    tracks.load();
    $('.map-layers-wrapper a').click(function () {
      $(this).toggleClass('active');
      var layerId = $(this).data('layer');
      tracks.toggle(layerId, $(this).hasClass('active'));
      return false;
    });

    $('.layers-link').click(function () {
      leftPopupSlide($('.map-layers-wrapper'), $(this).parent());
      return false;
    });
    var handlerAdded = false;
    var previousVisible = null;

    map.events.addListener("zoom_changed", function (e) {
      if (!visible['track-g1-markers']) return;
      if (handlerAdded) return;

      google.maps.event.addListenerOnce(map.getMap(), 'idle', function () {
        var markers = lines['track-g1-markers'];
        var markersAreVisible = map.getZoom() > 7 && visible['track-g1-markers'];
        if (markersAreVisible === previousVisible) {
          handlerAdded = false;
          return;
        }
        markersAreVisible && (lines['track-g1-markers'].length == 0) && reloadData();
        for (var j in markers) markers[j].setMap(markersAreVisible ? map.getMap() : null);
        handlerAdded = false;
        previousVisible = markersAreVisible;
      });
      handlerAdded = true;
    });
  });

  return {
    load: function () {
      readLayersCookie();
      updateStylesWithVisibility();
      layer = newLayer(ftId, 'type > 0', layerStyle);
      dirtLayer = newLayer(ftId, 'subtype = 3', null);
      pmtLayer = newLayer(pmtFtId, 'subtype = 2', null);
      redraw();
    }, show: function (type) {
      visible[type] = true;
      redraw();
    }, hide: function (type) {
      visible[type] = false;
      redraw();
    }, toggle: function (type, show) {
      visible[type] = show == true;
      redraw();
    },
    getLayer: function () {
      return layer;
    },
    getLayerStyle: function () {
      return layerStyle;
    },
  };
})(jQuery);
