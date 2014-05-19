class TagList extends D3Box
  constructor: (selector)->
    super
    @elem = "li"
    @data = []
    @switch = {}

  push: (item)->
    @switch[item] = true

  sort: ->
    @data = Object.keys @switch

  update: ->
    @list = @area.selectAll(@elem).data @data
    @list.enter().append @elem
    @list.exit().remove()
    @list.attr
      class: "btn btn-default"
    @list.text (d)-> d

    @list.on "click", (d, idx)->

