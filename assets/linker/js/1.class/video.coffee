
class VideoList extends D3Box
  constructor: (selector, box_selector)->
    super

  push: (item)->
    @data.push item

  clean: ->
    @data = []

  sort: ->
    @data = _.sortBy @data, (o)-> o.label

  update: ->
    @list = @area.selectAll("li").data @data, (d)-> d.href
    @list.exit().remove()
    a = @list.enter().append("li").append("a")
    a.attr
      href: (d)-> d.href
      target: "_blank"
    a.text (d)->
      d.label
