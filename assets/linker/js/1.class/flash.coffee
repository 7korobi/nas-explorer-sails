class FlashViewer extends D3Box
  constructor: (selector)->
    super
    @elem = "embed"

  update: (@data)->
    @list = @area.selectAll(@elem).data [@data], (d)-> d.href
    @list.enter().append(@elem)
    @list.exit().remove()
    @list.attr
      src: (d)-> d.href
      height: -> window.innerHeight
      width: -> window.innerWidth


class FlashList extends D3Box
  constructor: (selector, box_selector)->
    super
    @playlist = new FlashViewer box_selector

  push: (item)->
    @data.push item

  clean: ->
    @data = []

  sort: ->
    @data = _.sortBy @data, (o)-> o.label

  update: ->
    @list = @area.selectAll("li").data @data, (d)-> d.href
    @list.enter().append("li")
    @list.exit().remove()
    @list.text (d)->
      d.label
    @list.on "click", (d)=>
      @playlist.update(d)


