# @cjsx React.DOM
{ div, a, img } = React.DOM

@GroupRideListItem = React.createClass
  getDefaultProps: ->
    avatar_url : null
    date       : null
    title      : null

  render: ->
    a { href: @props.url, className: 'b-block' },
      if @props.avatar_url
        div { className: 'avatar' }, img { src: @props.avatar_url }

      if @props.date
        div { className: 'date'   }, @props.date

      if @props.title
        div { className: 'title'  }, @props.title
