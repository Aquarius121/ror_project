# @cjsx React.DOM
{div, h1, h2, span, a, ul, li} = React.DOM

cx         = React.addons.classSet
TabbedArea = ReactBootstrap.TabbedArea
TabPane    = ReactBootstrap.TabPane

@ExpandableBlock = React.createClass
  getDefaultProps: ->
    expandable: true
    sidebar:    false
    per_row:    3
    layout:     'table'

  getInitialState: ->
    activeTab: 0
    expanded:  false
    per_row:   @props.per_row

  activeTab: -> _.values(@props.tabs)[@state.activeTab] if !!@props.tabs

  canToggle: ->
    if @props.expandable
      items = if !!@props.items
                @props.items
              else if !!@props.tabs and (tab = @activeTab())
                tab.items

      items and items.length > @state.per_row

  toggle: (e)->
    @setState expanded: !@state.expanded
    e.preventDefault()

  toggleBtn:  ->
    span { className: 'links links-plus'},
      a  { href: "#", onClick: @toggle },
         (if @state.expanded then 'less' else 'more')

  allUrl:   -> @props.url || @activeTab().url
  allLabel: -> 'View all'
  all:      -> a { href: url, className: 'btn btn-orange' }, @allLabel() if !!(url = @allUrl())

  selectTab: (key)-> @setState activeTab: key

  pane: (key)->
    defaults = items: null, item: null
    tab = _.extend defaults, @props.tabs[key]

    if !!tab
      if tab.component and (tab.items or tab.item)
        BlockList
          component: tab.component
          items:     tab.items
          item:      tab.item
          expanded:  @state.expanded
          per_row:   tab.per_row || @props.per_row
          layout:    tab.layout  || @props.layout
      else
        div {}, tab


  tabs: ->
    labels = _.keys @props.tabs

    TabbedArea { activeKey: @state.activeTab, onSelect: @selectTab },
      _.map labels, (label, index)=>
        TabPane { eventKey: index, tab: label, key: ('tab' + index) }, @pane label

  actions: ->
    div { className: 'heading-actions' },
      _.map @props.actions, (url, label)->
        a { href: url, className: 'btn btn-orange', key: label }, label

  render: ->
    heading = if @props.sidebar then h2 else h1
    div {},
      heading {},
        @props.heading
        @actions() if @props.actions
        @toggleBtn() if @canToggle()

      if @props.tabs
        @tabs()

      if (@props.items or @props.item)
        BlockList
          component: @props.component
          expanded:  @state.expanded
          per_row:   @props.per_row
          layout:    @props.layout
          items:     @props.items

      @all() if @state.expanded and !!@props.url
