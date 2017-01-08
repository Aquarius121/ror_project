if (typeof Spree === 'undefined') {
  Spree = {};
}
if (typeof Spree.translations === 'undefined') {
  Spree.translations = {};
}
if (typeof Spree.routes === 'undefined') {
  Spree.routes = {};
}

function userGarage(form) {
  if (form.find('#user_my_garage').length) {
    var inGarage = [];
    form.find('.garage-field-wrapper .garage-input-wrapper').each(function () {
      if ($(this).find('.garage-input').val() && $(this).find('.garage-input').val().trim()) {
        inGarage.push({
          id: $(this).find('.garage-id').val(),
          name: $(this).find('.garage-input').val().trim(),
          type: $(this).find('.bike-type').val()
        });
      }
    });
    form.find('#user_my_garage').val(JSON.stringify(inGarage));
  }
}

function walkThruSite() {

  function post(player, action, value) {
    var data = { method: action };
    if (value) {
      data.value = value;
    }
    var message = JSON.stringify(data);
    var url = window.location.protocol + player.attr('src').split('?')[0];
    player[0].contentWindow.postMessage(message, url);
  }

  function loadPlayer(id, videoId) {
    $('.joyride-tip-guide #' + id + '-videoholder').
      html('<iframe id="' + id + '-player" src="//player.vimeo.com/video/' + videoId + '?title=0&amp;byline=0&amp;portrait=0&amp;player_id=' + id + '-player&amp;api=1" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>');
  }

  function stopPlayer(elemId) {
    var $elem = $('.joyride-tip-guide #' + elemId + '-videoholder');
    var player = $elem.find('iframe');
    if (player.length == 0) return;
    post(player, 'pause');
    post(player, 'unload');
    $elem.empty();
  }

  $('#joyRideTipContent').joyride({
    autoStart: true,
    preStepCallback: function (index, tip) {
      if (index == 0) {
        loadPlayer('welcome', 105064579);
      }
      if (index == 1) {
        loadPlayer('plan-rides', 105198880);
      }
      if (index == 2) {
        loadPlayer('my-rides', 105198885);
      }
      if (index == 9) {
        loadPlayer('legend', 105198879);
      }
    },
    postStepCallback: function (index, tip) {
      if (index == 0) {
        stopPlayer('welcome');
      }
      if (index == 1) {
        stopPlayer('plan-rides');
      }
      if (index == 2) {
        stopPlayer('my-rides');
        $(this).joyride('set_li', false, 1);
      }
      if (index == 9) {
        stopPlayer('legend');
      }

    },
    postRideCallback: function () {
      var player = $('.joyride-tip-guide iframe');
      if (player.length == 0) return;
      post(player, 'pause');
      post(player, 'unload');

      if (window.walkThruRide) {
        location.hash = window.walkThruRide;
        var route = routes.preLoad();
        if (route) {
          routes.load(route.id, route);
          routes.setRouteType(route);
        }
      }
    },
    modal: true,
    expose: false,
    exposeCover: true
  });

}

function signFormPos() {
  if ($('.anonymous #sign-div, .anonymous #restore-div')) {
    var sign_restore_div = $('#sign-div, #restore-div');
    var screenHeight = $(window).height() - $('#user-nav').height() - $('#footer').height();
    if (sign_restore_div.height() < screenHeight) {
      var margin = ((screenHeight - sign_restore_div.height() - 20) / 2) + $('#user-nav').height();
      sign_restore_div.css('margin-top', margin);
    }
  }
}

jQuery(function ($) {

  var body = $('body');
  body.on('submit', '#edit_user, #new_user', function () {
    var form = $(this);
    userGarage(form);
    if (form.parents('.account-popup').length) {
      $.ajax({
        type: "POST",
        url: form.attr('action') + ".json",
        data: form.serialize(),
        complete: function (jqXHR, textStatus) {
          if (textStatus == 'success') {
            toastr.success('Profile successfully saved');
          } else {
            toastr.error('Access not granted');
//                        prependErrorMsg(form, jqXHR.responseJSON[0].text[0]);
          }
          $(".sign-div-wrapper").mCustomScrollbar("scrollTo", 0);
        }
      });
      return false;
    }
  });

  body.on('submit', '#sign-div.additional #edit_user, #sign-div.additional #new_user', function () {
    toggleAccountPopup();
  });

  body.on('click', '#edit_user .update-avatar, #new_user .update-avatar', function () {
    var form = $(this).parents('#edit_user, #new_user');
    $.ajax({
      type: "POST",
      url: '/avatars.json',
      success: function (data) {
        if (data.status) {
          form.find('.field-wrapper.avatar img').remove();
          form.find('#user_avatar_id').val(data.avatarid);
          form.find('.field-wrapper.avatar').prepend('<img src="' + data.url + '">');
          toastr.success('Avatar was updated.');
          $(".sign-div-wrapper").mCustomScrollbar("scrollTo", 0);
        } else {
          toastr.info('Failed to update avatar. Try again later.');
        }
      },
      dataType: 'json'
    });
    return false;
  });


  body.on('click', '.add-garage-input', function () {
    $(this).parents('.garage-input-wrapper').before($('.hidden-garage-input').html());
    $(this).parents('.garage-field-wrapper').find('select:not(.hasCustomSelect)').customSelect();
    return false;
  });

  body.on('click', '.plan-rides-help', function () {
    $.colorbox({
      iframe: true,
      innerWidth: '750px',
      innerHeight: '450px',
      scrolling: false,
      href: '//player.vimeo.com/video/105198880?title=0&amp;byline=0&amp;portrait=0'
    });
    return false;
  });

  body.on('click', '.account-popup .back-button', function () {
    $(this).parents('.account-popup').removeClass('active').hide();
    return false;
  });

  body.on('change', '#terms-and-cond-checkbox', function () {
    if ($(this).is(':checked')) {
      $('body').find('.sign-up-form-submit').removeAttr('disabled');
    } else {
      $('body').find('.sign-up-form-submit').attr('disabled', 'disabled');
    }
  });

  body.on('click', '.remove-garage-input', function () {
    $(this).parents('.garage-input-wrapper').remove();
    return false;
  });

  signFormPos();

});

