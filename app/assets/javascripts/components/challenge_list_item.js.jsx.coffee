# @cjsx React.DOM
{div, a} = React.DOM

@ChallengeListItem = React.createClass
  links: ->
    links = []

    if !!(url = @props.join_group_url)
      links.push
        url:   url
        title: 'join a group'

    if !!(url = @props.accept_url)
      links.push
        url:   url
        title: 'do this challenge'

    if links.length > 0
      div { className: 'links links-plus'},
        links.map (i)->
          Link
            key:   i
            to:    i.url
            label: i.title

  render: ->
    div { className: 'b-challenge'},
      div { className: 'content' },
        a   { href: @props.url, className: 'title' }, @props.name
        div { className: 'desc' }, @props.description

      @links()




