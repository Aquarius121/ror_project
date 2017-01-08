# @cjsx React.DOM
{ div, form, button, input } = React.DOM
Modal = ReactBootstrap.Modal
Button = ReactBootstrap.Button

@FriendsCheckList = React.createClass
  render: ->
    items = _.map @props.friends, (item, key)->
      item = JSON.parse item
      label : item.full_name
      image : item.avatar_url
      name  : 'club[user_ids][]'
      id    : item.id

    CheckList { items: items }

@ModalFriendsCheckList = React.createClass
  render: ->
    hide = -> console.log 'hide'

    modalProps = _.extend { title: "Invite friends", animation: true, backdrop: true, closeButton: true, onRequestHide: hide}, @props

    Modal modalProps,
      form { action: @props.url, method: 'post' },
        input { type: 'hidden', name: @props.csrf_param,  value: @props.csrf_token }
        div { className: 'modal-body' },
          FriendsCheckList @props

        div { className: 'modal-footer'},
          button { type: 'submit', className: 'btn btn-orange' }, 'Invite friends!'

modal = @ModalFriendsCheckList

@ModalFriendsInviteTrigger = React.createClass
  render: ->
    ReactBootstrap.ModalTrigger { modal: (ModalFriendsCheckList @props) },
      div { className: 'btn btn-orange' }, 'invite friends'




