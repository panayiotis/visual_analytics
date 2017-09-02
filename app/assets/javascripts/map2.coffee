# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.Map = {}

Map.drawChoropleth = (element, data, geojson,names_map,groupname) ->
    console.log "#{groupname}: start choropleth"
    #console.log geojson
    
    filtered_features = geojson.features.filter (feature) ->
      Object.keys(names_map).indexOf(feature.properties.name) > -1
    
    geojson.features = filtered_features
    
    dateFormat =d3.time.format('%Y-%m-%d')
    
    numberFormat = d3.format('d')
    
    data.forEach (d) ->
      if d.date == null
        alert 'hi'
      d.date = dateFormat.parse(d.date)
      d.month = d3.time.month(d.date)
      d.count = +d.count
    
    timeDomain = data.reduce (acc,val) ->
      m = val.date
      acc[0] = m if m < acc[0]
      acc[1] = m if m > acc[1]
      acc
    ,[ Date.now(), 0 ]
   
    #console.log 'timeDomain ->'
    #console.log timeDomain

    #console.log 'data ->'
    #console.log data

    xf = crossfilter(data)

    moveMonths = xf.dimension (d) ->
      d.month

    volumeByMonthGroup = moveMonths.group().reduceSum (d) ->
      d.count
    
    volumeChart = dc.barChart("#{element} .monthly-volume-chart", groupname)
    
    moveChart = dc.lineChart("#{element} .monthly-move-chart", groupname)

    facilities = xf.dimension (d) ->
      d.country
    
    facilitiesGroup = facilities.group()
    .reduceSum (d) ->
      d.count
    
    width = $("#{element} .map").width()
    console.log "#{groupname}: width: " +width
    choro = dc_leaflet.choroplethChart("#{element} .map", groupname)
    .mapOptions
      maxZoom: 5
      minZoom: 3
    .dimension(facilities)
    .group(facilitiesGroup)
    .width( width )
    .height(350)
    .center([
      50
      20
    ])
    .zoom(4)
    .geojson(geojson)
    .colors(colorbrewer.YlGnBu[7])
    .colorDomain [
      d3.min(facilitiesGroup.all(), dc.pluck('value'))
      d3.max(facilitiesGroup.all(), dc.pluck('value'))
    ]
    .colorAccessor (d, i) ->
      d.value
    .featureKeyAccessor (feature) ->
      names_map[feature.properties.name]
    .renderPopup true
    .popup (d, feature) ->
      "#{d.value}"
    .legend(dc_leaflet.legend().position('bottomright'))
    
    types = xf.dimension (d) -> d.esco

    typesGroup = types.group().reduceSum((d) -> d.count )

    pie = dc.pieChart("#{element} .pie", groupname)
    .dimension(types)
    .group(typesGroup)
    .width($("#{element} .pie").width())
    .height(300)
    .ordering((p) ->
      +p.value
    )
    .renderLabel(true)
    
    monthlyMoveGroup = moveMonths.group().reduceSum (d) ->
      d.count
    
    #console.log moveMonths.group()

    moveChart.renderArea(true)
    .width($("#{element} .monthly-move-chart").width())
    .height(200)
    .transitionDuration(200)
    .margins(
      top: 30
      right: 5
      bottom: 25
      left: 60)
    .dimension(moveMonths)
    .mouseZoomable(true)
    .rangeChart(volumeChart)
    .x(d3.time.scale().domain(timeDomain))
    .round(d3.time.month.round)
    .xUnits(d3.time.months)
    .elasticY true
    .renderHorizontalGridLines true
    .legend dc.legend().x(800).y(10).itemHeight(13).gap(5)
    .brushOn false
    .group volumeByMonthGroup, 'Volume'
    .valueAccessor (d) ->
      d.value
    .title (d) ->
      d.value

    volumeChart
    .width($("#{element} .monthly-volume-chart").width())
    .height(60)
    .margins({top: 0, right: 0, bottom: 20, left: 60})
    .dimension(moveMonths)
    .group(volumeByMonthGroup)
    .centerBar(false)
    .gap(1)
    .x(d3.time.scale().domain(timeDomain))
    .round(d3.time.month.round)
    .alwaysUseRounding(true)
    .xUnits(d3.time.months)
    .yAxis().ticks(0)

    dc.renderAll groupname
    
    return { choro: choro, pie: pie }

Map.summary_map = (element, file, names_map,groupname) ->
  geojson = null
  
  if $(element).length == 1
  
    d3.json '/europe.geo.json', (error,data) ->
      console.log "#{groupname}: fetch geojson"
      alert 'reload page' if error
      geojson = data
      #console.log geojson.features.map  (f ) ->
      #  "\"#{f.properties.name}\": \"#{f.properties.name}\""
      #.join("\n")
      
      if file.endsWith(".csv")
        d3.csv file, (error,data) ->
          console.log "#{groupname}: fetch #{file}"
          alert 'reload page' if error
          Map.drawChoropleth element, data, geojson,names_map,groupname

      else
        d3.json file, (error,data) ->
          console.log "#{groupname}: fetch #{file}"
          alert 'reload page' if error
          new_data = data.response.docs.reduce (acc,val) ->
            a = {}
            a["count"] = val.count_s
            a["date"] = val.date_s
            a["country"] = val.country_s
            a["esco"] = val.esco_s
            acc.push a
            acc
          ,[]
          
          Map.drawChoropleth element, new_data, geojson,names_map,groupname
