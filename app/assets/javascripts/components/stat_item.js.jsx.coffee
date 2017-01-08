# @cjsx React.DOM
{ div, small } = React.DOM

@StatItem = React.createClass
  getDefaultProps: ->
    title: null
    units: null
    value: null

  render: ->
    div { className: 'b-stat' },
      div { className: 'heading' },
        @props.value
        small {}, @props.units if @props.units

      div { className: 'description' }, @props.title
