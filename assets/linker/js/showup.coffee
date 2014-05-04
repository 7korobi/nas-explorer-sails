
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
        "Image"
      when "mp4", "m4v", "mov", "wmv"
        "Video"
      when "mp3", "3gp", "aac", "wav", "wma"
        "Audio"
      else
        if href.match /// /$ ///
          "Dir"
        else
          "File"

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


class Tag extends String

class Dir extends String

class File

class Image

class Video

class Audio

groups =
  Tag: {}
  Dir: []
  File: []
  Image: []
  Video: []
  Audio: []

prototypes =
  Tag: Tag.prototype
  Dir: Dir.prototype
  File: File.prototype
  Image: Image.prototype
  Video: Video.prototype
  Audio: Audio.prototype


add_item = (href, hash)->
  ext = parse.ext href
  hash.__proto__ = prototypes[ext]
  groups[ext].push hash

show_tags = ->
  area = d3.select("#tag-list")
  list = area.selectAll("li").data _.sortBy Object.keys groups.Tag
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
      add_item href,
        filename:  filename
        size_text: size
        href: href
        size: parse.size size
        timestamp: parse.timestamp "#{day} #{time}"
        label: parse.cut_tags filename, tags
        tags: _.sortBy Object.keys tags
      for tag, __ of tags
        groups.Tag[tag] = true
    cb groups if cb

get_dir "/lib/testdata-m4v.html", (data)->
  area = d3.select("#video-list")
  refresh = (box)->
    list = area.selectAll("li").data box, (d)-> d.href
    list.enter().append("li")
    list.exit().remove()
    list.text (d)->
      d.label

  data.Video = _.sortBy data.Video, (o)-> o.label
  refresh data.Video
  show_tags()

get_dir "/lib/testdata-cinema.html", (data)->
  area = d3.select("#video-list")
  refresh = (box)->
    list = area.selectAll("li").data box, (d)-> d.href
    list.enter().append("li")
    list.exit().remove()
    list.text (d)->
      d.label
    list.on "click", (d)->
      location.href = "http://utage.family.jp/media/iPad/Videos/%5B%E6%98%A0%E7%94%BB%5D%20BD-src/" + d.href

  data.Video = _.sortBy data.Video, (o)-> o.label
  refresh data.Video
  show_tags()


get_dir "/lib/testdata-mp3.html", (data)->
  playlist = new AudioPlayer "#audio-box"
  playlist.src = (d)-> "http://utage.family.jp/media/Audio/%E8%B5%B0%E3%82%8C%E6%AD%8C%E8%AC%A1%E6%9B%B2/%E8%B5%B0%E3%82%8C%E6%AD%8C%E8%AC%A1%E6%9B%B2_%EF%BD%94%EF%BD%8D%EF%BD%90/" + d.href

  area = d3.select("#audio-list")

  refresh = (box)->
    list = area.selectAll("li").data box, (d)-> d.href
    list.enter().append("li")
    list.exit().remove()
    list.text (d)->
      d.label
    list.on "click", (d)->
      playlist.push(d)

  data.Audio = _.sortBy data.Audio, (o)-> o.label
  refresh data.Audio
  show_tags()

get_dir "/lib/testdata-jpg.html", (data)->
  images = new ImageViewer "#image-list"
  images.src = (d)-> "http://utage.family.jp/media/PDFbare/2013-01/%5BCLAMP%5D%20CLAMP%E5%AD%A6%E5%9C%92%E6%8E%A2%E5%81%B5%E5%9B%A3/CLAMP%E5%AD%A6%E5%9C%92%E6%8E%A2%E5%81%B5%E5%9B%A3-01/" + d.href

  data.Image = _.sortBy data.Image, (o)-> o.label
  images.start data.Image
  show_tags()

