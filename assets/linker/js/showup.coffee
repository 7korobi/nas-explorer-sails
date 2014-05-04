
parse =
  timestamp: d3.time.format("%d-%b-%Y %H:%M").parse

  line: new RegExp """
      <a href="([^>]+)">([^>]+)</a> +([0-9a-zA-Z-]+) +([0-9:]+) +([0-9A-Z.]+)
    """, "gi"

  path: new RegExp """
      <title>Index of /(.+)</title>
    """, "i"

  ext: (href)->
    ext = href.split(".").pop()
    switch ext.toLowerCase()
      when "jpg", "png"
        "image"
      when "mp4", "m4v", "mov", "wmv"
        "video"
      when "mp3", "3gp", "aac", "wav", "wma"
        "audio"
      else
        if href.match /// /$ ///
          "dir"
        else
          "file"

  size: (str)->
    [_, num, si] = str.match /// ([0-9,.]+)([^ ]?) ///
    si_size =
      switch si
        when "T"
          1000000000000
        when "G"
          1000000000
        when "M"
          1000000
        when "K"
          1000
        else
          1
    num * si_size

  cut_tags: (str, tags)->
    for tag_regexp in @tags_regexp
      str = str.replace tag_regexp, (__, str)->
        for tag in str.split(/・/gi)
          tags[tag] = true
        ""
    str

  tags_regexp: _.map [
    '\\.([^.]+)$'
    '（(.+)）'
    '\\[([^\\[\\]]+)\\]'
    '\\(([^\\(\\)]+)\\)'

    '-(\\d\\d\\d\\d.[a-z][a-z])'
#    '\\-([^\\[\\(-]+)$'
#    '^([^\\[\\(-]+)\\-'
  ], (str)-> new RegExp str, "gi"


groups =
  tag: {}
  dir: []
  file: []
  image: []
  video: []
  audio: []

show_tags = ->
  area = d3.select("#tag-list")
  list = area.selectAll("li").data _.sortBy Object.keys groups.tag
  list.enter().append("li")
  list.exit().remove()
  list.attr
    class: "btn btn-default"
  list.text (d)-> d

get_dir = (url, cb)->
  d3.text url, (err, text)->
    return console.warn error if err

    [__, pathname] = text.match parse.path

    text.replace parse.line, (__, href, filename, day, time, size)->
      tags = {}
      for dirname in pathname.split(/// [/ ] ///)
        parse.cut_tags dirname, tags
      groups[parse.ext href].push
        filename:  filename
        size_text: size
        href: href
        size: parse.size size
        timestamp: parse.timestamp "#{day} #{time}"
        label: parse.cut_tags filename, tags
        tags: _.sortBy Object.keys tags
      for tag, __ of tags
        groups.tag[tag] = true
    cb groups if cb

get_dir "/lib/testdata-m4v.html", (data)->
  area = d3.select("#video-list")
  refresh = (box)->
    list = area.selectAll("li").data(box)
    list.enter().append("li")
    list.exit().remove()
    list.text (d)->
      d.label

  data.video = _.sortBy data.video, (o)-> o.label
  refresh data.video
  show_tags()

get_dir "/lib/testdata-cinema.html", (data)->
  area = d3.select("#video-list")
  refresh = (box)->
    list = area.selectAll("li").data(box)
    list.enter().append("li")
    list.exit().remove()
    list.text (d)->
      d.label
    list.on "click", (d)->
      location.href = "http://utage.family.jp/media/iPad/Videos/%5B%E6%98%A0%E7%94%BB%5D%20BD-src/" + d.href

  data.video = _.sortBy data.video, (o)-> o.label
  refresh data.video
  show_tags()

get_dir "/lib/testdata-mp3.html", (data)->
  area = d3.select("#audio-list")
  refresh = (box)->
    list = area.selectAll("li").data(box)
    list.enter().append("li")
    list.exit().remove()
    list.text (d)->
      d.label
    list.on "click", (d)->
      list = d3.select("#audio-box").selectAll("audio").data([d])
      list.enter().append("audio")
      list.exit().remove()
      list.attr
        src: "http://utage.family.jp/media/Audio/%E8%B5%B0%E3%82%8C%E6%AD%8C%E8%AC%A1%E6%9B%B2/%E8%B5%B0%E3%82%8C%E6%AD%8C%E8%AC%A1%E6%9B%B2_%EF%BD%94%EF%BD%8D%EF%BD%90/" + d.href
        controls: "on"
        preload: "auto"
        autoplay: ""

  data.audio = _.sortBy data.audio, (o)-> o.label
  refresh data.audio
  show_tags()

get_dir "/lib/testdata-jpg.html", (data)->
  box = []
  area = d3.select("#image-list").attr
    style: "height: #{window.innerHeight}px; width: #{window.innerWidth}px; white-space: nowrap;"
  refresh = (box)->
    box.unshift data.image.shift()

    list = area.selectAll("img").data(box)
    list.enter().append('img')
    list.exit().remove()
    list.attr
      src: (d)-> "http://utage.family.jp/media/PDFbare/2013-01/%5BCLAMP%5D%20CLAMP%E5%AD%A6%E5%9C%92%E6%8E%A2%E5%81%B5%E5%9B%A3/CLAMP%E5%AD%A6%E5%9C%92%E6%8E%A2%E5%81%B5%E5%9B%A3-01/" + d.href
      height: -> window.innerHeight
    list.on "click", ->
      refresh box
    if window.innerWidth < _.reduce list[0], ((sum,data)-> sum + data.width), 0
      box.pop()

  data.image = _.sortBy data.image, (o)-> o.label
  refresh box
  show_tags()

