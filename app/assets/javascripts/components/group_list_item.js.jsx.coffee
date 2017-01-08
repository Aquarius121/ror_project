# @cjsx React.DOM
{div, img, a} = React.DOM

cx = React.addons.classSet
Transition = React.addons.CSSTransitionGroup

@GroupListItem = React.createClass
  getDefaultProps: ->
    avatar_url   : null
    member_since : null
    title        : null
    popup        : null

  links: ->
    links = []

    if !!(url = @props.join_group_url)
      links.push
        url:   url
        title: 'join a group'

    if !!(url = @props.join_url)
      links.push
        url:   url
        title: 'do this challenge'

    if links.length > 0
      div { className: 'links links-plus'},
        links.map (i)->
          Link
            key:   i
            to:    i.url
            label: i.title

  getInitialState: -> popup: false

  showPopup: -> @setState popup: true
  hidePopup: -> @setState popup: false

  popup: ->
    if @state.popup
      classes = cx
        'b-group-popup'   : true
        'b-popup-compact' : @props.compact

      Popup { className: classes, key: 'popup'},
        GroupInfo _.extend { compact: true, asLink: false }, @props
        PopupStats { stats: @props.stats } if @props.stats

  render: ->
    div { onMouseOver: @showPopup, onMouseOut: @hidePopup },
      Transition { transitionName: 'popup', transitionEnter: true, transitionLeave: true },
        (@popup() if @props.popup)
      GroupInfo @props

@GroupListItemCompact = React.createClass
  render: ->
    props = _.extend { compact: true }, @props
    GroupListItem props

@GroupListItemWithPopup = React.createClass
  render: ->
    _.extend @props, { popup: true }
    GroupListItem @props

@GroupListItemCompactWithPopup = React.createClass
  render: ->
    props = _.extend { compact: true, popup: true }, @props
    GroupListItem props

@GroupListItemWithPopup = React.createClass
  render: ->
    _.extend @props, { popup: true }
    GroupListItem @props



