class D3Box
  constructor: (selector)->
    @area = d3.select(selector)

  del: (d)->
    _.remove @data, (o)-> o.href == d.href
    @update()
    @list.exit().remove()
