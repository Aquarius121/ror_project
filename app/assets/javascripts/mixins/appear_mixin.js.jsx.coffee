@AppearMixin =
  componentDidMount: ->
    popup = $ @refs.popup.getDOMNode()
    popup.addClass '__appear-enter'
    setTimeout -> popup.addClass '__appear-enter-active'

  componentWillUnmount: ->
    popup = $ @refs.popup.getDOMNode()
    popup.addClass '__appear-leave'

    setTimeout ->
      popup.addClass '__appear-leave-active'


