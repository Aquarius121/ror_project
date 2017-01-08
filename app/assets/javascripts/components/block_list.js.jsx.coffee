# @cjsx React.DOM
{div, h1, span, a} = React.DOM

Transition = React.addons.CSSTransitionGroup

root = @

@BlockList = React.createClass
  getInitialState: ->
    expanded: !!@props.expanded
    per_row:  @props.per_row || 3

  getDefaultProps: ->
    layout:  'table'

  componentWillReceiveProps: (props)->
    @setState expanded: props.expanded

  colWidth: (per_row)-> ['col', 'sm', Math.floor(12/@state.per_row)].join '-'

  itemsCount: ->
    if @state.expanded
      (@state.per_row * 3)
    else
      @state.per_row

  list: ->
    component = root[@props.component]

    if !!@props.items
      _.map @props.items, (params, index)=>
        (params = JSON.parse params).key = index
        component params

    else if !!@props.item
      params = JSON.parse @props.item
      component params

  table: ->
    per_row  = @state.per_row
    col      = @col

    rows = _.chain(@props.items)
      .take                 @itemsCount()
      .map         (item)-> JSON.parse item
      .groupBy (v, index)-> Math.floor(index/per_row)
      .value()

    _.map rows, (items, index)->
      div { className: 'row b-list', key: index },
        _.map items, (params, index)->
          col params, index

  col: (params, index)->
    i = params.id || index
    div { className: @colWidth(), key: i },
      root[@props.component] params

  render: ->
    div {},
      if (!!@props.items and @props.items.length) or !!@props.item
        Transition { transitionName: 'appear', transitionEnter: true, transitionLeave: true },
          if @props.layout == 'table'
              @table()
          else
              @list()
      else
        div { className: 'well' }, 'Nothing here..'

