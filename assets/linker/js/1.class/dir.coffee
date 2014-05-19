class DirTree extends D3Box
  constructor: (selector, root_path)->
    super

    margin =
      top: 30
      right: 20
      bottom: 30
      left: 20

    @area
    .append("svg")
    .attr
      width: 100
      height: window.innerHeight * 2
    .append("g")
    .attr
      transform: "translate(#{margin.left},#{margin.top})"
    @area = @area.select("svg")

    @tree = d3.layout.tree().nodeSize [
      0
      10
    ]
    @diagonal = d3.svg.diagonal().projection (d) -> [
      d.y
      d.x
    ]

    @root =
      x0: 0
      y0: 0
      href: root_path
      label: "(root)"
      children: []

    @nodes = [@root]

    @margin = margin

    @bar =
      height: 30
      width: 200

  push: (item)->
    base = _.find @nodes, (d)-> d.href == item.href_base
    if base
      has_child = _.find base.children, (d)-> d.href == item.href
      unless has_child
        item.x0 = base.x0
        item.y0 = base.y0
        base.children ||= []
        base.children.unshift item

  click: (d)=>
    if d.children
      d._children = d.children
      d.children = null
      @update d
    else if d._children
      d.children = d._children
      d._children = null

      get_dir d.href, ()=>
        @update d
      @update d
    else
      get_dir d.href, ()=>
        @update d
      @update d

  color: (d)->
    if d._children
      "#3182bd"
    else if d.children
      "#c6dbef"
    else
      "#fd8d3c"

  update: (source = @root)->
    # Compute the flattened node list. TODO use d3.layout.hierarchy.
    # Compute the "layout".
    @nodes = @tree.nodes @root
    for node, index in @nodes
      node.x = index * @bar.height


    @area.transition().duration(400).attr
      width: 200 - @margin.left - @margin.right
      height: Math.max(window.innerHeight, @nodes.length * @bar.height + @margin.top + @margin.bottom)


    # Update the nodes…
    nodes = @area.selectAll("g.node").data @nodes, (d)-> d.href
    nodes_enter = nodes.enter().append("g")
    .attr
      class: "node"
      transform: (d)-> "translate(#{d.y0},#{d.x0})"
    .style
      opacity: 1e-6

    nodes_enter.append("rect")
    .attr
      y: 0
      height: @bar.height
      width:  @bar.width
      fill: @color
    .on("click", @click)

    nodes_enter.append("text")
    .attr
      dy: 13.5
      dx: 5.5
    .on("click", @click)
    .text (d)-> d.label

    nodes_enter.transition().duration(400)
    .attr
      transform: (d)-> "translate(#{d.y},#{d.x})"
    .style
      opacity: 1

    nodes.transition().duration(400)
    .attr
      transform: (d)-> "translate(#{d.y},#{d.x})"
    .style
      opacity: 1
    .select("rect").style("fill", @color)

    nodes.exit().transition().duration(400)
    .attr
      transform: (d)-> "translate(#{d.y},#{d.x})"
    .style
      opacity: 1
    .select("rect")
    .style
      fill: @color

    nodes.exit().transition().duration(400)
    .attr
      transform: (d)-> "translate(#{source.y},#{source.x})"
    .style
      opacity: 1e-6
    .remove()

    link = @area.selectAll("path.link").data(@tree.links(@nodes), (d)-> d.target.id)
    link.enter().insert("path", "g").attr("class", "link").attr("d", (d)=>
      o =
        x: source.x0
        y: source.y0

      @diagonal
        source: o
        target: o
    ).transition().duration(400)
    .attr
      d: @diagonal

    link.transition().duration(400)
    .attr
      d: @diagonal

    link.exit().insert("path", "g").attr("class", "link").attr("d", (d)->
      o =
        x: source.x0
        y: source.y0

      @diagonal
        source: o
        target: o
    ).remove()

    for d in @nodes
      # Stash the old positions for transition.
      d.x0 = d.x
      d.y0 = d.y


