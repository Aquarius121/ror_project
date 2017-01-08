function loadAnnouncements(club_id) {
  var announcement;
  $.ajax({
    type: "GET",
    url: '/announcements/show_for_club/' + club_id + '.json',
    success: function (data) {
      console.log(data);
      $('.popup-club-wrapper-bg-own-club .own-club-right-announcements-body').html('');
      data.forEach(function (ann) {
        announcement = $(".own-club-right-announcements-line .announcement-wrapper").clone().appendTo($(".own-club-right-announcements-body"));
        announcement.find('.title').html(ann.title);
        announcement.find('.body').html(ann.body);
      });
      stop_dashboard_ajax_loader();
    }
  });
}

function showClub(clubUrl){
  start_dashboard_ajax_loader();
  $.ajax({
    type: "GET",
    url: clubUrl,
    success: function (data) {
      var ownClubPopup = $('.popup-club-wrapper-bg-own-club');
      ownClubPopup.find('.own-club-left-bottom .club-img').attr('src', data.logo);
      ownClubPopup.find('.own-club-left-bottom .name').html(data.title);
      ownClubPopup.find('.own-club-left-bottom .location').html(data.location);
      ownClubPopup.find('.own-club-left-bottom .description').html(data.description);
      ownClubPopup.find('.own-club-left-bottom .riding-preferences').html(data.riding_preferences);
      ownClubPopup.find('.own-club-right-join-button').attr('data-club-id', data.id);
      ownClubPopup.find('.own-club-right-join span').remove();
      ownClubPopup.find('.approve-members').remove();

      var join_btn = ownClubPopup.find('.own-club-right-join-button');
      (data.in_club) ? join_btn.hide() : join_btn.show();

      $(".own-club-right-members").html('');
      var memberLine;
      _(data.members).each(function (member) {
        memberLine = $(".own-club-right-members-hidden .own-club-right-member-wrapper").clone().appendTo($(".own-club-right-members"));
        memberLine.find('.member-small-img').attr('src', member.avatar_small);
        memberLine.find('.member-big-img').attr('src', member.avatar_big);
        memberLine.find('.member-name').html(member.firstname + ' ' + member.lastname);
        if (member.location) {
          memberLine.find('.member-location').html(member.location);
        }
        if (!member.friends) {
          memberLine.find('.member-add-friend-button')
            .attr('data-id', member.id)
            .attr('data-url', data.add_to_friend_url);
        } else {
          memberLine.find('.member-add-friend').remove();
        }
      });

      ownClubPopup.find('.own-club-right-announcements .add-announcement').remove();
      if (data.owner) {
        if (data.approve_count > 0) {
          ownClubPopup.find('.own-club-right-members').append('<div class="approve-members"><a href="/members/listforapprove/' + data.id + '">Approve Members(<span>' + data.approve_count + '</span>)</a></div>');
        }
        ownClubPopup.find('.own-club-right-announcements').append('<div class="add-announcement"><a href="/announcements/new/' + data.id + '">Add Announcement</a></div>');
      }

      ownClubPopup.parents('.navigation-toggler').find('.a-wrapper').addClass('own-club-active');
      $('.popup-club-wrapper-bg').addClass('hidden');
      ownClubPopup.removeClass('hidden');

      if (data.approved) {
        loadAnnouncements(data.id);
      } else {
        if (data.in_club) {
          ownClubPopup.find('.own-club-right-join').prepend('<span>Your request was send.</span>');
        }
        ownClubPopup.find('.own-club-right-announcements-body').html('Only members can view group announcements.');
        stop_dashboard_ajax_loader();
      }
    },
    dataType: 'json'
  });
}


jQuery(function ($) {
  $('.popup-club-wrapper-bg-create-club .club-city').change(function () {
    $('.popup-club-wrapper-bg-create-club #club_location').val($('.popup-club-wrapper-bg-create-club .club-state').val() + ', ' + $(this).val());
  });

  $('.own-club-right').on('mouseenter', '.own-club-right-member', function () {
    $(this).find('.member-popup').show();
  });

  $('.own-club-right').on('mouseleave', '.own-club-right-member', function () {
    $(this).find('.member-popup').hide();
  });

  $('.own-club-right').on('click', '.member-add-friend-button', function () {
    var btn = $(this);
    $.ajax({
      type: "POST",
      url: btn.attr('data-url') + '.json',
      data: {
        friendship: { user_id: btn.attr('data-id') }
      },
      success: function () {
        btn.remove();
      }
    });
  });


  $('.own-club-right').on('click', '.own-club-right-join-button', function () {
    var btn = $(this);
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: '/members.json',
      data: {
        member: { club_id: btn.attr('data-club-id') }
      },
      success: function (data) {
        console.log(data);
        if (data.active) {
          loadAnnouncements(data.club_id);
          btn.parent().prepend('<span>Now you are in a group!</span>');
        } else {
          btn.parent().prepend('<span>Your request was send.</span>');
          stop_dashboard_ajax_loader();
        }
        btn.hide();
      }
    });
  });


  $('.popup-club-tabs-friends-form form').submit(function () {
    var submitBtn = $(this).find('input[type=submit]');
    submitBtn.attr("disabled", "disabled");
    $(".popup-club-tabs-form-result-content-wrapper").html('');
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: {
        title: $(this).find('input.name').val(),
        location: $(this).find('input.location').val(),
        club_type_id: $(this).find('select.club').val()
      },
      success: function (data) {
        console.log(data);
        var clubLine;
        $.each(data, function (i, club) {
          clubLine = $(".popup-club-tabs-form-result-hidden .result-wrapper").clone().appendTo($(".popup-club-tabs-form-result-content-wrapper"));
          clubLine.find('.club-img').attr('src', club.logo);
          clubLine.find('.name').html(club.title);
          clubLine.find('.location').html(club.location);
          clubLine.find('.members .num').html(club.users_count);
          clubLine.find('.rides .num').html(club.routes_count);
          clubLine.find('.type').html(club.club_type_name);
          clubLine.attr('data-url-json', club.url);
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

  $('.popup-club-wrapper-bg').on('click', '.result-wrapper .img-wrapper, .result-wrapper .name, .result-wrapper .location', function () {
    showClub($(this).parents('.result-wrapper').attr('data-url-json'));
  });

  $('.popup-club-create-link').click(function () {
    var $popup = $('.popup-club-wrapper-bg-create-club');
    $popup.parents('.navigation-toggler').find('.a-wrapper').addClass('own-club-active');
    $('.popup-club-wrapper-bg').addClass('hidden');
    $('.club-img', $popup).hide();
    $('.club-img-reserved', $popup).show();
    $('#club_location', $popup).val('');
    $('.club-city, .club-state', $popup).val('').trigger('render');
    $popup.removeClass('hidden');
  });

  $('.popup-club-wrapper-bg-create-club .club-state').change(function () {
    $('.popup-club-wrapper-bg-create-club #club_location').val($(this).val());
    var select = $('.popup-club-wrapper-bg-create-club .club-city');
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
      }
    });
  });


  $('.popup-club-wrapper-bg-create-club form').submit(function () {
    var form = $(this);
    start_dashboard_ajax_loader();
    $.ajax({
      type: "POST",
      url: $(this).attr('action') + '.json',
      data: $(this).serialize(),
      success: function (data) {
        var ownClubPopup = $('.popup-club-wrapper-bg-own-club');
        if (data.logo != '') {
          ownClubPopup.find('.own-club-left-bottom .club-img').attr('src', data.logo);
        } else {
          ownClubPopup.find('.own-club-left-bottom .club-img').attr('src', $(".popup-club-tabs-form-result-hidden .result-wrapper .club-img").attr('src'));
        }
        ownClubPopup.find('.own-club-left-bottom .name').html(data.title);
        ownClubPopup.find('.own-club-left-bottom .location').html(data.location);
        ownClubPopup.find('.own-club-left-bottom .description').html(data.description);
        ownClubPopup.find('.own-club-left-bottom .riding-preferences').html(data.riding_preferences);
        ownClubPopup.find('.own-club-right-join-button').attr('data-club-id', data.id).hide();
        ownClubPopup.find('.own-club-right-join span').remove();
        ownClubPopup.find('.approve-members').remove();

        $(".own-club-right-members").html('');
        var memberLine;
        data.members.forEach(function (member) {
          memberLine = $(".own-club-right-members-hidden .own-club-right-member-wrapper").clone().appendTo($(".own-club-right-members"));
          memberLine.find('.member-small-img').attr('src', member.avatar_small);
          memberLine.find('.member-big-img').attr('src', member.avatar_big);
          memberLine.find('.member-name').html(member.firstname + ' ' + member.lastname);
          if (member.location) {
            memberLine.find('.member-location').html(member.location);
          }
          if (!member.friends) {
            memberLine.find('.member-add-friend-button').attr('data-id', member.id).attr('data-url', data.add_to_friend_url);
          } else {
            memberLine.find('.member-add-friend').remove();
          }
        });
        ownClubPopup.find('.own-club-right-announcements .add-announcement').remove();
        ownClubPopup.find('.own-club-right-announcements').append('<div class="add-announcement"><a href="/announcements/new/' + data.id + '">Add Announcement</a></div>');
        loadAnnouncements(data.id);
        ownClubPopup.parents('.navigation-toggler').find('.a-wrapper').addClass('own-club-active');
        $('.popup-club-wrapper-bg-create-club').addClass('hidden');
        ownClubPopup.removeClass('hidden');
        form[0].reset();
        stop_dashboard_ajax_loader();
      },
      dataType: 'json'
    });
    return false;
  });
});
