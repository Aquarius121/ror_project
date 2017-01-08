# @cjsx React.DOM
{ div, a, img, ul, li } = React.DOM

@RideListItem = React.createClass
  getDefaultProps: ->
    ridden_at  : null
    avatar_url : null
    edit_url   : null
    view_url   : null
    stats      : []
    title      : null

  render: ->
    div { className: 'b-ride' },
      if @props.avatar_url
        div { className: 'avatar' },
          if @props.stats
            ul { className: 'stats' }, @props.stats.map (p, i)-> li { key: i }, p
          img { src: @props.avatar_url }

      div { className: 'date'  }, @props.date
      div { className: 'title' },
        a { href: @props.url }, @props.title

      if @props.edit_url or @props.view_url
        div { className: 'actions' },
            a { href: @props.edit_url, className: 'btn btn-orange' }, 'Edit ride'
            a { href: @props.view_url, className: 'btn btn-link' }, 'View ride'

@SidebarRideListItem = React.createClass
  render: ->
    a { href: @props.url, className: 'b-ride' },
      div { className: 'title' }, @props.title
      div { className: 'date'  }, @props.date
