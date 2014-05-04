class AudioPlayer extends D3Box
  constructor: (selector)->
    super
    @elem = "audio"
    @data = []
    @update()

  update: ->
    @list = @area.selectAll(@elem).data @data, (d)-> d.href
    @list.attr
      src: @src
      controls: "on"
      preload: "auto"

    @list.on "ended", (d, idx)=>
      @index = idx
      @succ @data.length

  push: (d)->
    @data.push d
    @update()
    @list.enter().append @elem

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
