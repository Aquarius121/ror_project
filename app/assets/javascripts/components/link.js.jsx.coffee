# @cjsx React.DOM
{div, a} = React.DOM

@Link = React.createClass
  render: ->
    a { href: @props.to }, @props.label
