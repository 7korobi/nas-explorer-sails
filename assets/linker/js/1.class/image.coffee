class ImageViewer extends D3Box
  constructor: (selector)->
    super
    @elem = "img"

  push: (item)->
    @all.push item

  clean: ->
    @index = 0
    @data = []
    @all = []

  sort: ->
    @succ() if @data.length == 0 && @all.length > 0
    @all = _.sortBy @all, (o)-> o.href

  update: ->
    @list = @area.selectAll(@elem).data @data
    @list.enter().append @elem
    @list.exit().remove()
    @list.attr
      src: (d)-> d.href
      height: -> window.innerHeight

    @list.on "click", (d, idx)=>
      switch idx
        when 0
          @succ()
        else
          @back()

  succ: ->
    data = @all[@index++]
    if data
      @data.unshift data
      @reduce =>
        @data.pop()

  back: ->
    data = @all[@index - @data.length - 1]
    if data
      @data.push data
      @reduce =>
        @index--
        @data.shift()

    @succ()

  reduce: (cb)->
    @update()
    width = 0
    for dom in @list[0]
      if window.innerWidth < width
        cb()
      width += dom.width
    @update()




