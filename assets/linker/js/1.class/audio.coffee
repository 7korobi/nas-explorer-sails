class AudioPlayer extends D3Box
  constructor: (selector)->
    super
    @elem = "audio"
    @data = []
    @update()

  push: (d)->
    @data.push d
    @update()
    @list.enter().append @elem

  update: ->
    @list = @area.selectAll(@elem).data @data, (d)-> d.href
    @list.attr
      src: (d)-> d.href
      controls: "on"
      preload: "auto"

    @list.on "ended", (d, idx)=>
      @index = idx
      @succ @data.length

  succ: (limit)->
    return unless limit
    @index += 1
    @index %= @data.length
    @current = @list[0][@index]
    if @current && 2 < @current.readyState
      @current.load()
      @current.play()
    else
      @succ(limit - 1)


class AudioList extends D3Box
  constructor: (selector, box_selector)->
    super
    @playlist = new AudioPlayer box_selector

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
      @playlist.push(d)

