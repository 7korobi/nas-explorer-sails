
parse =
  timestamp: d3.time.format("%d-%b-%Y %H:%M").parse

  line: new RegExp """
      <a href="([^>]+)">([^>]+)</a> +([0-9a-zA-Z-]+) +([0-9:]+) +(-|[0-9A-Z.]+)
    """, "gi"

  path: new RegExp """
      <title>Index of /(.+)</title>
    """, "i"

  ext: (href)->
    ext = href.split(".").pop()
    switch ext.toLowerCase()
      when "swf"
        "Flash"
      when "jpg", "png", "gif"
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
    matches = str.match /// ([0-9,.]+)([^ ]?) ///
    return 0 unless matches
    [_, num, si] = matches
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
    str.replace("/","")

  tags_regexp: _.map [
    '\\.([^./]+)$'
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

class Flash

class EventBox
  constructor: (hash)->
    @lists = []
    for key, list of hash
      @lists.push list

  clean: ->
    for d3box in @lists
      d3box.clean() if d3box.clean

  sort: ->
    for d3box in @lists
      d3box.sort() if d3box.sort


  update: ->
    for d3box in @lists
      d3box.update() if d3box.update

groups =
  Tag: new TagList "#tag-list"
  Dir: new DirTree "#dir-list", "http://utage.family.jp/media/"
  File: []
  Flash: new FlashList "#flash-list", "#flash-viewer"
  Image: new ImageViewer "#image-list"
  Video: new VideoList "#video-list"
  Audio: new AudioList "#audio-list", "#audio-box"

event_box = new EventBox groups

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


tag_list =

get_dir = (url, cb)->
  d3.text url, (err, text)->
    return console.warn err if err

    event_box.clean()

    [__, pathname] = text.match parse.path

    text.replace parse.line, (__, href, filename, day, time, size)->
      href = href.replace(/&amp;/g, "&")
      tags = {}
      for dirname in pathname.split(/// [/ ] ///)
        parse.cut_tags dirname, tags
      add_item href,
        filename:  filename
        size_text: size
        href: url + href
        href_base: url
        size: parse.size size
        timestamp: parse.timestamp "#{day} #{time}"
        label: parse.cut_tags filename, tags
        tags: _.sortBy Object.keys tags
      for tag, __ of tags
        groups.Tag.push tag
    event_box.sort()
    cb groups if cb
    event_box.update()


get_dir "http://utage.family.jp/media/", (data)->

