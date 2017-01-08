RidingSocial.Config = (function ($) {
  return {
    routePolylineOptions: {
      strokeColor: '#D76020',
      strokeWeight: 8,
      strokeOpacity: 0.8
    },
    /*how to create dashed lines:
     * https://developers.google.com/maps/documentation/javascript/examples/overlay-symbol-dashed
     , icons: [{
     icon: {
     path: 'M 0,-1 0,1',
     strokeOpacity: 0.5,
     strokeColor: '#008000',
     scale: 4
     },
     offset: '0',
     repeat: '20px'
     }]*/
    trackStyles: {
      'track-g1': {
        strokeColor: '#FFFF00',
        strokeOpacity: 0.6,
        strokeWeight: 3
      },
      'track-g2': {
        strokeColor: '#FF0000',
        strokeOpacity: 0.6,
        strokeWeight: 3
      },
      'track-g3': {
        strokeColor: '#FFA500',
        strokeOpacity: 0.6,
        strokeWeight: 3
      },
      'track-lh': {
        strokeColor: '#808080',
        strokeOpacity: 0.6,
        strokeWeight: 3
      },
      'track-pmt': {
        strokeColor: '#008000',
        strokeOpacity: 0.6,
        strokeWeight: 3
      },
      'track-dirt': {
        strokeColor: '#A52A2A',
        strokeOpacity: 0.6,
        strokeWeight: 3
      },
      'invisible': {
        strokeColor: '#000000',
        strokeOpacity: 0.00001,
        strokeWeight: 0
      }
    },
    defaultZoom: 9
  };
})(jQuery);
