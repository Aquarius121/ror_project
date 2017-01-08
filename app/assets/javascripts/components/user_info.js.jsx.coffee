# @cjsx React.DOM
{ div, a, img } = React.DOM

@UserInfo = React.createClass
  getDefaultProps: ->
    asLink: true

  render: ->
    div { className: 'b-user-info' },
      if @props.avatar_url
        div {className: 'avatar'},
          img { src: @props.avatar_url }

      div { className: 'content' },
        if @props.url and @props.asLink
          a { href: @props.url, className: 'title' }, @props.full_name
        else
          div { className: 'title' }, @props.full_name

        if @props.address or @props.bike
          div { className: 'description' },
            div { className: 'address' }, @props.address if @props.address
            div { className: 'bike' },    @props.bike    if @props.bike
