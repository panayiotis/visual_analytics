window.PresentationVisualizations = {} unless window.PresentationVisualizations 

PresentationVisualizations.cluster = (element) ->
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
    .attr 'transform', "translate(#{width-200}, 45) scale(0.2)"
  svg.append('path')
    .attr 'd', awspath
    .attr 'class', 'worker'
    .attr 'transform', "translate(#{width-200}, 75) scale(0.2)"

  svg.append('text')
    .attr 'class', 'master'
    .attr 'x', width-170
    .attr 'y', 60
    .attr 'font-size', 20
    .text 'master node'

  svg.append('text')
    .attr 'class', 'worker'
    .attr 'x', width-170
    .attr 'y', 90
    .attr 'font-size', 20
    .text 'worker node'
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
    console.log 'add one to master'
    b = id: "worker-" + Math.random().toString(36).substring(5)
    nodes.push b
    links.push({source: master,target: b})
    start()
    find = (i for i in links when (i.target is b))[0]

    setTimeout(->
      console.log 'add one to master'
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


```
// https://dc-js.github.io/dc.js/crime/index.html

PresentationVisualizations.canadaCrime = function() {
  var numberFormat = d3.format(".2f");

  var caChart = dc.bubbleOverlay("#ca-chart")
    .svg(d3.select("#ca-chart svg"));

  var incidentChart = dc.barChart("#incident-chart");

  var homicideChart = dc.lineChart("#homicide-chart");

  function isTotalCrimeRateRecord(v) {
    return v.type == "Total, all violations" && v.sub_type == "Rate per 100,000 population";
  }

  function isTotalCrimeIncidentRecord(v) {
    return v.type == "Total, all violations" && v.sub_type == "Actual incidents";
  }

  function isViolentCrimeRateRecord(v) {
    return v.type == "Total violent Criminal Code violations" && v.sub_type == "Rate per 100,000 population";
  }

  function isViolentCrimeIncidentRecord(v) {
    return v.type == "Total violent Criminal Code violations" && v.sub_type == "Actual incidents";
  }

  function isHomicideRateRecord(v) {
    return v.type == "Homicide" && v.sub_type == "Rate per 100,000 population";
  }

  function isHomicideIncidentRecord(v) {
    return v.type == "Homicide" && v.sub_type == "Actual incidents";
  }

  d3.csv("crime.csv", function(csv) {
    var data = crossfilter(csv);

    var cities = data.dimension(function(d) {
      return d.city;
    });
    var totalCrimeRateByCity = cities.group().reduce(
        function(p, v) {
          if (isTotalCrimeRateRecord(v)) {
            p.totalCrimeRecords++;
            p.totalCrimeRate += +v.number;
            p.avgTotalCrimeRate = p.totalCrimeRate / p.totalCrimeRecords;
          }
          if (isViolentCrimeRateRecord(v)) {
            p.violentCrimeRecords++;
            p.violentCrimeRate += +v.number;
            p.avgViolentCrimeRate = p.violentCrimeRate / p.violentCrimeRecords;
          }
          p.violentCrimeRatio = p.avgViolentCrimeRate / p.avgTotalCrimeRate * 100;
          return p;
        },
        function(p, v) {
          if (isTotalCrimeRateRecord(v)) {
            p.totalCrimeRecords--;
            p.totalCrimeRate -= +v.number;
            p.avgTotalCrimeRate = p.totalCrimeRate / p.totalCrimeRecords;
          }
          if (isViolentCrimeRateRecord(v)) {
            p.violentCrimeRecords--;
            p.violentCrimeRate -= +v.number;
            p.avgViolentCrimeRate = p.violentCrimeRate / p.violentCrimeRecords;
          }
          p.violentCrimeRatio = p.avgViolentCrimeRate / p.avgTotalCrimeRate * 100;
          return p;
        },
        function() {
          return {
            totalCrimeRecords:0,totalCrimeRate:0,avgTotalCrimeRate:0,
            violentCrimeRecords:0,violentCrimeRate:0,avgViolentCrimeRate:0,
            violentCrimeRatio:0
          };
        }
    );

    var years = data.dimension(function(d) {
      return d.year;
    });
    var crimeIncidentByYear = years.group().reduce(
        function(p, v) {
          if (isTotalCrimeRateRecord(v)) {
            p.totalCrimeRecords++;
            p.totalCrime += +v.number;
            p.totalCrimeAvg = p.totalCrime / p.totalCrimeRecords;
          }
          if (isViolentCrimeRateRecord(v)) {
            p.violentCrimeRecords++;
            p.violentCrime += +v.number;
            p.violentCrimeAvg = p.violentCrime / p.violentCrimeRecords;
          }
          if(isHomicideIncidentRecord(v)){
            p.homicide += +v.number;
          }
          p.nonViolentCrimeAvg = p.totalCrimeAvg - p.violentCrimeAvg;
          return p;
        },
        function(p, v) {
          if (isTotalCrimeRateRecord(v)) {
            p.totalCrimeRecords--;
            p.totalCrime -= +v.number;
            p.totalCrimeAvg = p.totalCrime / p.totalCrimeRecords;
          }
          if (isViolentCrimeRateRecord(v)) {
            p.violentCrimeRecords--;
            p.violentCrime -= +v.number;
            p.violentCrimeAvg = p.violentCrime / p.violentCrimeRecords;
          }
          if(isHomicideIncidentRecord(v)){
            p.homicide -= +v.number;
          }
          p.nonViolentCrimeAvg = p.totalCrimeAvg - p.violentCrimeAvg;
          return p;
        },
        function() {
          return {
            totalCrimeRecords:0,
            totalCrime:0,
            totalCrimeAvg:0,
            violentCrimeRecords:0,
            violentCrime:0,
            violentCrimeAvg:0,
            homicide:0,
            nonViolentCrimeAvg:0
          };
        }
    );

    caChart.width(600)
      .height(300)
      .dimension(cities)
      .group(totalCrimeRateByCity)
      .radiusValueAccessor(function(p) {
        return p.value.avgTotalCrimeRate;
      })
    .r(d3.scale.linear().domain([0, 200000]))
      .colors(["#ff7373","#ff4040","#ff0000","#bf3030","#a60000"])
      .colorDomain([13, 30])
      .colorAccessor(function(p) {
        return p.value.violentCrimeRatio;
      })
    .title(function(d) {
      return "City: " + d.key
        + "\nTotal crime per 100k population: " + numberFormat(d.value.avgTotalCrimeRate)
        + "\nViolent crime per 100k population: " + numberFormat(d.value.avgViolentCrimeRate)
        + "\nViolent/Total crime ratio: " + numberFormat(d.value.violentCrimeRatio) + "%";
    })
    .point("Toronto", 364, 400)
      .point("Ottawa", 395.5, 383)
      .point("Vancouver", 40.5, 316)
      .point("Montreal", 417, 370)
      .point("Edmonton", 120, 299)
      .point("Saskatoon", 163, 322)
      .point("Winnipeg", 229, 345)
      .point("Calgary", 119, 329)
      .point("Quebec", 431, 351)
      .point("Halifax", 496, 367)
      .point("St. John's", 553, 323)
      .point("Yukon", 44, 176)
      .point("Northwest Territories", 125, 195)
      .point("Nunavut", 273, 188)
      .debug(false);

    incidentChart
      .width(360)
      .height(180)
      .margins({top: 40, right: 50, bottom: 30, left: 60})
      .dimension(years)
      .group(crimeIncidentByYear, "Non-Violent Crime")
      .valueAccessor(function(d) {
        return d.value.nonViolentCrimeAvg;
      })
    .stack(crimeIncidentByYear, "Violent Crime", function(d){return d.value.violentCrimeAvg;})
      .x(d3.scale.linear().domain([1997, 2012]))
      .renderHorizontalGridLines(true)
      .centerBar(true)
      .elasticY(true)
      .brushOn(false)
      .legend(dc.legend().x(250).y(10))
      .title(function(d){
        return d.key
          + "\nViolent crime per 100k population: " + Math.round(d.value.violentCrimeAvg)
          + "\nNon-Violent crime per 100k population: " + Math.round(d.value.nonViolentCrimeAvg);
      })
    .xAxis().ticks(5).tickFormat(d3.format("d"));

    homicideChart
      .width(360)
      .height(150)
      .margins({top: 10, right: 50, bottom: 30, left: 60})
      .dimension(years)
      .group(crimeIncidentByYear)
      .valueAccessor(function(d) {
        return d.value.homicide;
      })
    .x(d3.scale.linear().domain([1997, 2012]))
      .renderHorizontalGridLines(true)
      .elasticY(true)
      .brushOn(true)
      .title(function(d){
        return d.key
          + "\nHomicide incidents: " + Math.round(d.value.homicide);
      })
    .xAxis().ticks(5).tickFormat(d3.format("d"));

    dc.renderAll();
  });

};
```
