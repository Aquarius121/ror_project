# @cjsx React.DOM
{ div, a, img } = React.DOM

cx = React.addons.classSet

@GroupInfo = React.createClass
  getDefaultProps: ->
    asLink: true

  render: ->
    classes = cx
      'b-group-info': @props.compact
      'b-group':      !@props.compact

    div { className: classes },
      if @props.avatar_url
        div { className: 'avatar' }, img { src: @props.avatar_url }

      div { className: 'content' },
        div { className: 'date'   }, @props.member_since unless @props.compact

        if @props.url and @props.asLink
          a { href: @props.url, className: 'title' }, @props.title
        else
          div { className: 'title' }, @props.title

