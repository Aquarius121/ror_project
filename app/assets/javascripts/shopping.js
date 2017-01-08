var premiumForm;
var num_card;
var customer;
var month;
var year;
var cvv;
var plan;
var coupon;
var card_error = false;
var formErrors = [];
var updateSubscription = false;
jQuery(function () {
  $("input[name='card-num']").validateCreditCard(function (e) {
    card_error = !e.luhn_valid;
  });
  $('#close_premium').click(function () {
    location.reload();
  });

  $('.upgrade-to-premium .sign-up, .map-legend-wrapper .sign-up').click(function () {
    $("#premium_popup").click();
  });

  $('#buy_premium').click(function () {
    var premium = function (e) {
      premiumForm = $(".popup-get-premium-form");
      updateSubscription = true;
      validation();
    };
    var free = function (e) {
      premiumForm = $(".popup-get-premium-form");
      validation();
    };
    isPremium(premium, free);
    return false;
  });

  $('.combined form.new_user').on('submit', function () {
    premiumForm = $(".combined .popup-get-premium-form");
    $("#error_list_payment").children().remove();
    var name = ['plan', 'customer', 'card-num', 'month', 'year', 'cvv'];
    var errorCount = 0;
    formErrors = [];
    for (var i = 0; i < name.length; i++) {
      if (!validationByType(name[i], i)) {
        errorCount++;
        console.log(name[i]);
      }
    }
    if (errorCount == 0) {
      $('input.make-payment').attr('disabled', 'disabled');
      $(".nav-wrapper .ajax-overlay").show();
      return true;
    } else {
      for (i = 0, l = formErrors.length; i < l; i++) {
        showUserAnError(formErrors[i].description);
      }
      (function () {
        var l = 20;
        for (var i = 0; i < 10; i++)
          $("#sign-div").animate({ 'margin-left': "+=" + ( l = -l ) + 'px' }, 50);
      })()
      return false;
    }
  });
});

function isPremium(callbackSuccess, callbackError) {
  $.ajax({
    type: "POST",
    url: 'is_premium',
    success: function (data) {
      if (data.premium) {
        if (typeof callbackSuccess === 'function') callbackSuccess(data);
      } else {
        if (typeof callbackError === 'function')
          callbackError(data);
        else
          getPremiumWindow();
      }
    },
    error: function (jqXHR, textStatus, errorThrown) {
      toastr.error('Oops, something was wrong');
    }
  });
}

function freeUserRideLimit() {
  getPremiumWindow('You have reached your 10 ride limit for the free account. Please either delete some rides in "My Rides" or upgrade your account for unlimited rides.');
}
function getPremiumWindow(title, message) {
  getPremiumColorbox(title, message);
  var closeColorBox = function () {
    stop_left_ajax_loader();
    stop_dashboard_ajax_loader();
    $.colorbox.close();
  };
  $('.toggle-sign-up-trip').click(function () {
    closeColorBox();
    $("#premium_popup").click();
  });
  $('.toggle-close-premium-trip').click(closeColorBox);
}

function getPremiumColorbox(title, message) {
  var freeUserText = 'The feature you requested is part of our premium packages. ' +
    'We would love to have you on board to enjoy all the best riding components possible. ' +
    'For just $49.99/year for the plus account or $89.99/year (or $8.99/month) for premium, you can be on your way. ' +
    'Just click the button below for more information or to signup.';
  var plusUserText = 'The feature you requested is part of our premium package. ' +
    'We would love to have you on board to enjoy all the best riding components possible. ' +
    'For just $89.99/year or $8.99/month for premium, you can be on your way. ' +
    'Just click the button below for more information or to upgrade.';

  var text = C7E1249F == 'ED908C23' ? freeUserText : plusUserText;

  var html = '<div>';
  if (title) {
    html = html + '<div class="cbox-payment-message-title">' + title + '<br/>' + '</div>';
  }
  if (message) {
    text = message + '<br/>' + text;
  }
  html = html + '<div class="cbox-payment-message">' + text + '</div>';
  html = html + '<div class="cbox-buttons-wrap"><a class="cbox-button-confirm toggle-sign-up-trip" href="#">Sign Up</a> <a class="close toggle-close-premium-trip" href="#">Close</a></div></div>';
  $.colorbox({html: html, width: 800, height: 200});
}

function showUserAnError(errorText) {
  $('ul.error-list-payment').append("<li class='error-payment'>" + errorText + "</li>");
  toastr.error(errorText, '', {timeOut: 30000});
}
function validation() {
  $("#error_list_payment").children().remove();
  var name = ['plan', 'customer', 'card-num', 'month', 'year', 'cvv'];
  var errorCount = 0;
  formErrors = [];
  for (var i = 0; i < name.length; i++) {
    if (!validationByType(name[i], i)) {
      errorCount++;
      console.log(name[i]);
    }
  }
  if (errorCount == 0) {
    start_dashboard_ajax_loader();
    payment();
  } else {
    for (i = 0, l = formErrors.length; i < l; i++) {
      showUserAnError(formErrors[i].description);
    }
  }
}

function payment() {
  $.ajax({
    type: "POST",
    url: updateSubscription ? 'update_subscription' : 'subscribe',
    data: {
      card_num: num_card,
      customer: customer,
      cvv: cvv,
      month: month,
      year: year,
      premium_plan: plan,
      coupon: coupon
    },
    success: function (data) {
      if (data.success) {
        $('.payment_wrapper').css('display', 'none');
        $('.popup-premium-account').css('display', 'block');
      } else {
        showUserAnError(data.error);
        $('.payment_wrapper').css('display', 'block');
        $('.popup-premium-account').css('display', 'none');
      }
      stop_dashboard_ajax_loader();
      console.log(data);
    },
    error: function (jqXHR) {
      if (jqXHR.status == 500 && jqXHR.responseJSON && jqXHR.responseJSON.error) {
        showUserAnError(jqXHR.responseJSON.error);
        stop_dashboard_ajax_loader();
      }
    }
  });
}

function validationByType(type, num) {
  var obj = premiumForm.find('input[name=' + type + ']');
  switch (type) {
    case 'plan':
      $('input[name=' + type + ']').each(function () {
        if (this.checked) {
          plan = this.value;
        }
      });
      if (typeof plan == 'undefined') {
        formErrors.push({elem: type, description: 'Select premium plan'});
        return false;
      }
      return true;
    case'card-num':
      if (!card_error && obj.val() > 0) {
        num_card = obj.val().replace(/\s+/g, '').replace(/[ -]/g, '');
        return true;
      } else {
        formErrors.push({elem: type, description: 'Enter correct card number'});
        return false;
      }
    case'customer':
      if (obj.val().length > 0 && obj.val().split(' ').length > 1) {
        customer = obj.val();
        return true;
      } else {
        formErrors.push({elem: type, description: 'Enter name on card'});
        return false;
      }
    case'month':
      if (obj.val().length == 2) {
        month = obj.val();
        return true;
      } else {
        formErrors.push({elem: type, description: 'Enter correct expiration month'});
        return false;
      }
    case'year':
      if (month) {
        if (obj.val().length == 2) {
          var today = new Date();
          var expiration_date = new Date("20" + obj.val(), month, '01');
          if (expiration_date > today) {
            year = obj.val();
            return true;
          } else {
            formErrors.push({elem: type, description: 'Card has expired'});
            return false;
          }
        } else {
          formErrors.push({elem: type, description: 'Enter correct expiration year'});
          return false;
        }
      }
      return false;
    case 'cvv':
      if (obj.val().length > 0) {
        cvv = obj.val();
        return true;
      } else {
        formErrors.push({elem: type, description: 'Enter correct CVV code'});
        return false;
      }
    case 'coupon':
      coupon = obj.val().length > 0 ? obj.val() : false;
      return true;
  }
}