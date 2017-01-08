# @cjsx React.DOM
{ div, a, img } = React.DOM

cx = React.addons.classSet
Transition = React.addons.CSSTransitionGroup

@UserListItem = React.createClass
  getDefaultProps: ->
    url        : '#'
    avatar_url : null
    full_name  : null
    address    : null
    bike       : null
    popup      : null

  getInitialState: -> popup: false

  showPopup: -> @setState popup: true
  hidePopup: -> @setState popup: false
  popup:     ->
    if @state.popup
      Popup { className: 'b-user-popup' },
        UserInfo   _.extend asLink: false, @props
        PopupStats { stats: @props.stats } if @props.stats

  render: ->
    div { onMouseOver: @showPopup, onMouseOut: @hidePopup },
      Transition { transitionName: 'popup', transitionEnter: true, transitionLeave: true },
        @popup() if @props.popup
      UserInfo @props


@UserListItemWithPopup = React.createClass
  render: ->
    _.extend @props, { popup: true }
    UserListItem @props
