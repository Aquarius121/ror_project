module LayoutHelper
  
  def copyright_bounds(start_year)
    [start_year, Time.now.year].uniq.compact.join ' - '
  end


  def sidebar
    render 'template/layout/sidebar'
  end

  def premium_popup
    render 'template/layout/popup_premium'
  end

  def payment_popup(title, button_text)
    render 'template/layout/payment_popup', title: title, button_text: button_text
  end

  def premium_plan
    str = ''
    PremiumPlan.active.each do |plan|
      str += content_tag 'li', :class => 'payment-rate' do
        content_tag :label, :class => 'payment-rate-label' do
          (radio_button_tag 'plan', plan.id) + plan.label
        end
      end
    end
    str
  end

  def saved_routes_select
    select_options = options_for_select(
      Route.own_for_user(current_user.id).order('created_at desc').pluck(:title, :id)
    )
    unless current_user.route_count_exceeded?
      select_options = content_tag(:option, 'New route', :value => '') + select_options
    end
    select_tag 'saved_routes', select_options, :class => 'add-custom-select'
  end

  def get_premium_form
    render partial: 'template/layout/premium_form', locals:{customer: nil, cvv: nil, card_num: nil, expiration: nil}
  end

  def premium_plan_checked?(plan_id)
    current_user && current_user.subscription &&
        current_user.subscription.premium_plan_id == plan_id
  end

  def link_to_facebook(route)
    # <a href="http://www.facebook.com/sharer.php?&amp;p[summary]=Want to acquire an app? (i.e. ownership, users, IP, etc) you should check out Outlook Web Mobile (OWA Email) via @apptopia!&amp;p[title]=Outlook Web Mobile (OWA Email) is on sale&amp;p[url]=http://www.apptopia.com/listings/outlook-web-mobile-owa-email&amp;s=100" class="fb" target="_blank">Share on Facebook</a>

    address_facebook = 'https://www.facebook.com/sharer/sharer.php?'
    images = "&p[images][]=https://maps.ridingsocial.com/system/routes/fb-#{route.id}.png"
    summary = "&p[summary]=#{strip_tags route.description}"
    url = "&p[url]=https://maps.ridingsocial.com/embed/#{route.id}"
    title = "p[title]=#{route.title}"
    param_str = title + images + summary + url + '&s=100'
    facebook = content_tag :a, "<img src='/assets/fb-share-icon.png'>Share this route on facebook".html_safe,
                           :href => address_facebook + param_str, :target => '_blank'
  end
  
end
