class RemovableItem
  constructor: (el, parent)->
    @el      = el.addClass 'b-removable-item'
    @handle  = el.find('[data-removable=handle]').addClass 'b-removable-handle'
    @destroy = el.find '[data-removable=destroy]'
    @parent  = parent
    @handle.on 'click', @remove

  remove: (e)=>
    @el.slideUp()
    @el.find(':input').not(@destroy).attr('disabled', 'disabled')
    @destroy.val '1'
    e.preventDefault()
    false

class Removable
  constructor: (el)->
    removable = @
    @items    = el.find('[data-removable=item]').map -> (new RemovableItem $(this), removable).el
    @template = el.find('[data-removable=template]').html()
    @addBtn    = $('<a><i class="icon-plus" />Add bike</a>')
      .addClass('b-removable-add')
      .on 'click', @add
      .appendTo el

  remove: ->

  add: =>
    item = $ @template.replace /%i%/img, @items.size()
    item.insertBefore @addBtn

    @items = @items.add (new RemovableItem item, @).el
    console.log 'add item'


$(document).on 'page:load ready', -> $('[data-behaviour=removable]').each -> new Removable $(this)



