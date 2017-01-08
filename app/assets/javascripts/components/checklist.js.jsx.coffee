# @cjsx React.DOM
{ div, input, label } = React.DOM

@CheckList = React.createClass
  render: ->
    div { className: 'b-form' },
      input { type: 'hidden', name:'user_ids[]', value: ''}
      div { className: 'b-form-checkboxes' },
        _.map @props.items, (item, key)->
          div { className: 'b-form-row', key },
            label {},
              item.label
              input { type: 'checkbox', name: item.name, value: item.id }
