# @cjsx React.DOM
{ div } = React.DOM

@Popup = React.createClass
  getDefaultProps: ->
    position: 'top'

  render: ->
    position = [' b-popup', @props.position].join '-'

    @props.className = 'b-popup' unless !!@props.className
    @props.className += position

    div @props,
      div { className: 'b-popup-wrap' },
        div { className: 'b-popup-tip' }
        @props.children

