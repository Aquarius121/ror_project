# @cjsx React.DOM
{div, img,label} = React.DOM

@FriendsCheckList = React.createClass
  render: ->
    Checklist { items: @props.users }

@ModalFriendsCheckList = React.createClass
  render: ->
    FriendsCheckList @props




