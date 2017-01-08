function showFriendsApproveTab() {
  var friendsApproveTab = $('div.popup-friends-tabs-section-a-wrapper.approve-friends > a');
  $('.navigation-wrapper').addClass('hidden');
  friendsApproveTab.parents('.navigation-toggler').children('.navigation-wrapper').removeClass('hidden');
  $('.navigation-toggler .a-wrapper').removeClass('active');
  friendsApproveTab.parents('.navigation-toggler').children('.a-wrapper').addClass('active');
  $('.popup-friends-tabs-section-a-wrapper .approve-friends').addClass('active');
  $('.popup-friends-wrapper-bg-friendships-approve').parents('.navigation-toggler').find('.a-wrapper').addClass('active');
  friendsApproveTab.click();
}

function friend_request_click() {
  //var leftMargin = parseInt($('.popup-friends-approve-link').parents('.popup-friends-tabs-section').offset().left) - parseInt($('.popup-friends-approve-link').parents('.popup-friends-tabs-section-a-wrapper').offset().left);
  $(".approve-popup-result-content-wrapper").html('');
  start_dashboard_ajax_loader();
  $.ajax({
    type: "POST",
    url: '/friendships/approve.json',
    success: function (data) {
      var friendLine;
      $('.popup-friends-tabs-content p.no-friends').toggle(data.length == 0);
      $.each(data, function (i, user) {
        friendLine = $(".approve-popup-result-hidden .result-wrapper").clone().appendTo($(".approve-popup-result-content-wrapper"));
        if (user.avatar.length) {
          friendLine.find('.club-img').attr('src', user.avatar);
        }
        friendLine
          .attr('data-user-id', user.id)
          .attr('data-friendship-id', user.friendship_id)
          .attr('data-url-add', user.add_url)
          .find('.name').html(user.firstname + ' ' + user.lastname);
        if (user.location) {
          friendLine.find('.location').html(user.location);
        }
      });
      $('.popup-friends-wrapper-bg-friendships-approve')/*.css({"margin-left": leftMargin + "px"})*/.removeClass('hidden').parents('.navigation-toggler').find('.a-wrapper').addClass('friendship-approve-active');
      $('.popup-friends-wrapper-bg').addClass('hidden');
      $(".approve-popup-result-content-wrapper").show();
      stop_dashboard_ajax_loader();
    },
    error: function (XMLHttpRequest, textStatus, errorThrown) {
      stop_dashboard_ajax_loader();
      ajax_error_msg();
    }
  });
}

function start_dashboard_ajax_loader() {
  $(".nav-wrapper .ajax-overlay").show();
}

function stop_dashboard_ajax_loader() {
  $(".nav-wrapper .ajax-overlay").hide();
}

function createFriendDiv(user) {
  var friendLine = $(".popup-friends-tabs-form-result-hidden .result-wrapper")
    .clone()
    .appendTo($(".popup-friends-tabs-form-result-content-wrapper"));
  if (user.avatar.length) {
    friendLine.find('.club-img').attr('src', user.avatar);
  }
  friendLine.attr('data-user-id', user.id)
    .attr('data-follower-id', user.follower_id)
    .attr('data-url-add', user.add_url)
    .find('.name').html(user.firstname + ' ' + user.lastname);
  if (user.location) {
    friendLine.find('.location').html(user.location);
  }
  if (user.friends) {
    friendLine.find('.add-friend').addClass('added');
    friendLine.find('.add-friend-text').html('Already Friends');
  }
  if (user.friend_request) {
    friendLine.find('.add-friend').remove();
    friendLine.find('.info-wrapper').append('<div class="allready-sent">friend request sent</div>');
  }
  friendLine.find('.rides .num').html(user.routes_count);
  friendLine.find('.miles .num').html(user.distance);
  if (user.club_name != null) {
    friendLine.find('.club').html(user.club_name);
  }
}

jQuery(function ($) {
  var $slideSpeed = 1000;
  var friendsToggler = $("#friends .toggler");
  var friendsContent = $("#friends .content");
  var friendsApproveTab = $('div.popup-friends-tabs-section-a-wrapper.approve-friends > a');
  var friendsRequestCount = $('.friend-request-count');
  var accordionLoaded = false;

  function afterApprove() {
    var countspan = $('.navigation .count-approve');
    var num = parseInt(countspan.text());
    if (num > 1) {
      countspan.text(num - 1);
      friendsRequestCount.text(num - 1);
    } else {
      countspan.remove();
      friendsRequestCount.remove();
    }
  }

  friendsToggler.click(function () {
    $("#friends").css('top', 'auto');
    friendsContent.height($(window).height() - friendsToggler.innerHeight() - 60 - friendsContent.innerHeight() + friendsContent.height());

    if (friendsToggler.hasClass("up")) {
      friendsContent.slideUp($slideSpeed, function () {
        friendsToggler.removeClass("up");
      });
    } else {
      friendsContent.slideDown($slideSpeed, function () {
        friendsToggler.addClass("up");
        $("#friends").css('top', '60px');
      });
    }
  });


  function showAccordion() {
    if (!$("#friends").data('showed')) {
      $("#friends").css('top', 'auto');
      friendsContent.height($(window).height() - friendsToggler.innerHeight() - 60 - friendsContent.innerHeight() + friendsContent.height());
      friendsContent.slideDown($slideSpeed, function () {
        friendsToggler.addClass("up");
        $("#friends").css('top', '60px').data('showed', true);
      });
    }
    $("#friends").toggle();
    $(this).parents('.friends').toggleClass('active');
  }

  $('.side-main-wrapper .friends .friends-link').click(function () {
    if (accordionLoaded) {
      showAccordion();
    } else {
      $("#friends .content").load('/friends/', function () {
        initAccordion($("#friends .content"));
        showAccordion();
        $('#friends .friends_routes_block a').click(function () {
          try {
            var route = routes.preLoad($(this).attr('data-routeid'));
            if (route !== false) {
              routes.load(route.id, route);
            }
          } catch (e) {
          }
          return false;
        });
        accordionLoaded = true;
      });
    }
  });

  $('.popup-friends-tabs-friends-form form').submit(function () {
    var submitBtn = $(this).find('input[type=submit]');
    submitBtn.attr("disabled", "disabled");
    $(".popup-friends-tabs-form-result-content-wrapper").html('');
    start_dashboard_ajax_loader();
    $.ajax({
      type: "GET",
      url: $(this).attr('action'),
      data: {
        name: $(this).find('input.name').val(),
        location: $(this).find('input.location').val(),
        club_id: $(this).find('select.club').val(),
        riding_preference: $(this).find('select.riding-preference').val(),
        bike_type: $(this).find('select.bike-type').val()
      },
      success: function (data) {
        $.each(data, function (i, user) {
          createFriendDiv(user);
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

  $('.popup-friends-wrapper-bg').on('click', '.add-friend:not(.added)', function () {
    start_dashboard_ajax_loader();
    var btn = $(this);
    if ($(this).hasClass('added')) return false;
    $.ajax({
      type: "POST",
      url: $(this).parents('.result-wrapper').attr('data-url-add') + '.json',
      data: {
        friendship: {
          user_id: $(this).parents('.result-wrapper').attr('data-user-id'),
          club_id: $(this).parents('.result-wrapper select.club').val()
        }
      },
      success: function () {
        btn.parents('.info-wrapper').append('<div class="allready-sent">friend request sent</div>');
        btn.remove();
        stop_dashboard_ajax_loader();
      }
    });
    return false;
  });
  friendsApproveTab.click(friend_request_click);
  friendsRequestCount.click(showFriendsApproveTab);

  friendsRequestCount.hover(
    function () {
      $(".friends-link").addClass("white");
    },
    function () {
      $(".friends-link").removeClass("white");
    }
  );


  $('.approve-popup-friends-result').on('click', '.add-friend', function () {
    start_dashboard_ajax_loader();
    var wrap = $(this).parents('.result-wrapper');
    wrap.find('.buttons').hide();
    $.ajax({
      type: "POST",
      url: wrap.attr('data-url-add') + '.json',
      data: {
        friendship: {
          user_id: wrap.attr('data-user-id')
        }
      },
      success: function (data) {
        wrap.find('.buttons').html('<div class="msg">Friend successfully added</div>').show();
        afterApprove();
        stop_dashboard_ajax_loader();
      }
    });
  });

  $('.approve-popup-friends-result').on('click', '.disapprove', function () {
    start_dashboard_ajax_loader();
    var wrap = $(this).parents('.result-wrapper');
    wrap.find('.buttons').hide();
    $.ajax({
      type: "PUT",
      url: wrap.attr('data-url-add') + '/' + $(this).parents('.result-wrapper').attr('data-friendship-id') + '.json',
      data: {
        friendship: {
          follower_id: wrap.attr('data-user-id'),
          active: false
        }
      },
      success: function (data) {
        wrap.find('.buttons').html('<div class="msg">This person has not been approved</div>').show();
        afterApprove();
        stop_dashboard_ajax_loader();
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        wrap.find('.buttons').show();
        stop_dashboard_ajax_loader();
        ajax_error_msg();
      }
    });
  });

  function initApprovecount() {
    if ($('body').hasClass('anonymous')) return;
    $.ajax({
      type: "POST",
      url: '/friendships/approvecount.json',
      success: function (data) {
        if (data.count > 0) {
          $('.navigation .count-approve').text(data.count).show();
          $('.friend-request-count').text(data.count).show();
        }
      }
    });
  }

  function initAccordion(elt) {
    var options = {
      header: ".friend-head",
      heightStyle: "content",
      active: false,
      collapsible: true
    };
    elt.accordion(options);
  }

  function init() {
    initApprovecount();
  }

  init();
});