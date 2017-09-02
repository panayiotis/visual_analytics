
window.PresentationVisualizations = {} unless window.PresentationVisualizations 

PresentationVisualizations.cluster2 = (element) ->
  width = $(element).width()
  height = $(element).height()

  if height < 300
    height = 300
  
  console.log "Cluster Visualization size: #{width}x#{height}"
  
  radius = 12
  awspath = 'm 50,1 -31.61,13.58 29.28,12.52 33.95,-12.52 '+
    'z m -47.53,16.98 -1.06,61.1 46.25,20.37 0,-63.44 z '+
    'm 95.05,0 -41.8,15.91 0,59.83 41.8,-16.97 z'

  tick = ->
    node.attr "transform", (d) ->
      d.x = Math.max(radius, Math.min(width - radius, d.x))
      d.y = Math.max(radius, Math.min(height - 25 - radius, d.y))
      "translate(#{d.x - 12}, #{d.y - 12}) scale(0.3)"

    link.attr 'x1', (d) ->
      d.source.x
    .attr 'y1', (d) ->
      d.source.y
    .attr 'x2', (d) ->
      d.target.x
    .attr 'y2', (d) ->
      d.target.y

  color = d3.scale.category10()
  master = id: 'master'
  nodes = [
    master
    {id: 'worker1'}
    {id: 'worker2'}
    {id: 'worker3'}
    {id: 'worker4'}
    {id: 'worker5'}
    {id: 'worker6'}
  ]
  links = [
    {source: master, target: nodes[1]}
    {source: master, target: nodes[2]}
    {source: master, target: nodes[3]}
    {source: master, target: nodes[4]}
    {source: master, target: nodes[5]}
    {source: master, target: nodes[6]}
  ]
  force = d3.layout.force()
    .nodes(nodes)
    .links(links)
    .charge -2000
    .friction 0.3
    .gravity 0.1
    .linkDistance 120
    .size([
      width
      height
    ])
    .on('tick', tick)

  svg = d3.select(element)
    .append('svg')
    .attr 'class', 'presentation-force-layout'
    .attr('width', width)
    .attr('height', height)

  svg.append('path')
    .attr 'd', awspath
    .attr 'class', 'master'
    .attr 'transform', "translate(#{width-230}, 45) scale(0.2)"
  svg.append('path')
    .attr 'd', awspath
    .attr 'class', 'worker'
    .attr 'transform', "translate(#{width-230}, 75) scale(0.2)"

  svg.append('text')
    .attr 'class', 'master'
    .attr 'x', width-200
    .attr 'y', 60
    .attr 'font-size', 22
    .text 'eurostat datalake'

  svg.append('text')
    .attr 'class', 'worker'
    .attr 'x', width-200
    .attr 'y', 90
    .attr 'font-size', 22
    .text 'data-scientist'
  node = svg.selectAll('.node')

  link = svg.selectAll('.link')
  # 1. Add three nodes and three links.

  start = ->
    link = link.data(force.links(), (d) ->
      d.source.id + '-' + d.target.id
    )

    link.enter()
      .insert('line', '.node')
      .attr 'class', 'master-worker-link'

    link.exit().remove()

    node = node.data(force.nodes(), (d) ->
      d.id
    )

    node.enter()
      .append('path')
      .attr 'd', awspath
      .attr 'class', (d) ->
        if d.id.startsWith("master")
          'node master'
        else if d.id.startsWith("worker")
          'node worker'
      .call(force.drag)

    node.exit().remove()

    force.start()

  start()

  add_one = ->
    #console.log 'add one to master'
    b = id: "worker-" + Math.random().toString(36).substring(5)
    nodes.push b
    links.push({source: master,target: b})
    start()
    find = (i for i in links when (i.target is b))[0]

    setTimeout(->
      #console.log 'add one to master'
      links.push({ source: master, target: b })
      start()

      setTimeout(->
        links.splice(links.indexOf(find),1)
        start()
      , 1200)
    , 3300)

  remove_one = ->
    if (nodes.length > 5)
      find = (i for i in links when (i.source is master))[0]
      target = find.target
      nodes.splice nodes.indexOf(target), 1
      links.splice links.indexOf(find), 1
      start()

  setInterval (->
    if (Math.random() < 0.2)
      add_one()
    if (Math.random() > 0.8 or nodes.length > 12)
      remove_one()
  ), 800

