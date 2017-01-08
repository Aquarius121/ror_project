# @cjsx React.DOM
{ div, a, img } = React.DOM

@PopupStats = React.createClass
  render: ->
    div { className: 'b-stats' },
      @props.stats.map (stats, i)->
        StatItem _.extend key: i, stats
