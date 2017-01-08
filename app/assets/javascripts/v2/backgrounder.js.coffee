class @Backgrounder
  change: (url)-> @el.css backgroundImage: 'url(' + url + ')'

  constructor: (el)->
    @el = el.addClass 'b-backgrounder'
    @change @el.data('bg')

$(document).on 'page:load ready', ->
  $('[data-bg]').each -> new Backgrounder $(this)
