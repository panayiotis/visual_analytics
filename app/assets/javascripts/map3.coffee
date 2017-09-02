# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.Map = {} unless window.Map

Map.drawChoropleth3 = (element, dataset, geojson,names_map,groupname) ->
    log = (args...) -> console.log.apply this, args if true
    nut_level = 0
    esco_level = 1
    tiles = 'https://api.mapbox.com/styles/v1/mapbox/streets-v10/tiles/256/{z}/{x}/{y}'+
    '?access_token=pk.eyJ1IjoicGFuYXlpb3RpcyIsImEiOiJVdklrVkVZIn0.oBv4BqSOCz_xgiJh3lUadw'
    attributionText = '<a target="_blank" href="http://leafletjs.com">Leaflet</a>'+
    ' | <a target="_blank" href="https://www.mapbox.com/mapbox-studio">Mapbox</a>'+
    ' | <a target="_blank" href="https://www.openstreetmap.org">OpenStreetMap</a>'
    tiles= 'http://tile.stamen.com/watercolor/{z}/{x}/{y}.jpg'
    attributionText='Map tiles by <a href="http://stamen.com">Stamen Design</a>,'+
    ' under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>.'+
    ' Data by <a href="http://openstreetmap.org">OpenStreetMap</a>,'+
    ' under <a href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>'
    log "#{groupname}: start choropleth"
    
    #### Formatters
    dateFormat = d3.time.format('%Y-%m-%d')
    numberFormat = d3.format('d')
    
    #### Fix data
    dataset.rows.forEach (d) ->
      log "null date in data" if d.date == null
      d.date = dateFormat.parse d.date
      d.month = d3.time.month d.date
      d.count = +d.count
    
    filtered_features = geojson.features.filter (feature) ->
      Object.keys(names_map).indexOf(feature.properties.name) > -1
    
    geojson.features = filtered_features
    
    timeDomain = dataset.rows.reduce (acc,val) ->
      m = val.date
      acc[0] = m if m < acc[0]
      acc[1] = m if m > acc[1]
      acc
    ,[ Date.now(), 0 ]
   
    #### Create chart objects
    barChart = dc.barChart "#{element} .bar-chart", groupname
    lineChart = dc.lineChart "#{element} .line-chart", groupname
    pieChart = dc.pieChart "#{element} .pie-chart", groupname
    choroChart = dc_leaflet.choroplethChart "#{element} .map", groupname
    
    #### Create crossfilter dimensions and groups
    xf = crossfilter(dataset.rows)
    monthDimension = xf.dimension (d) -> d.month
    monthGroup = monthDimension.group().reduceSum (d) -> d.count
    nutDimension = xf.dimension (d) -> d.nut
    nutGroup = nutDimension.group().reduceSum (d) -> d.count
    escoDimension = xf.dimension (d) -> d.esco
    escoGroup = escoDimension.group().reduceSum (d) -> d.count
    
    #### Map chart 
    choroChart.mapOptions
      maxZoom: 5
      minZoom: 3
      maxBounds: L.latLngBounds(L.latLng(0, -40),L.latLng(60, 50))
      attributionControl: false
      doubleClickZoom: false
    .tiles (map) ->
      L.tileLayer(tiles,{opacity: 0.4}).addTo(map)
      L.control.attribution({position:'topright', prefix: attributionText}).addTo(map)
    .dimension nutDimension
    .group nutGroup
    .width -> $("#{element} .row").width()
    .height 700
    .center [35, 20 ]
    .zoom 4
    .geojson geojson
    .colors colorbrewer.Greens[6]
    .colorAccessor (d, i) -> d.value
    .calculateColorDomain()
    .featureKeyAccessor (feature) -> names_map[feature.properties.name]
    .renderPopup true
    .popup (d, feature) -> "#{d.value}"
    .legend(dc_leaflet.legend().position('topright'))
    .on 'preRedraw', (chart) -> chart.calculateColorDomain()
    
    window.c = choroChart
    #### Pie chart 
    pieChart
    .dimension escoDimension
    .group escoGroup
    .width -> $("#{element} .pie-chart").width()
    .height 300
    .ordering (p) ->  +p.value
    .renderLabel true
    
    #### Line chart
    lineChart.renderArea true
    .width -> $("#{element} .line-chart").width()
    .height 200
    .transitionDuration 200
    .margins { top: 30, right: 8, bottom: 25, left: 60 }
    .dimension monthDimension
    .mouseZoomable true
    .rangeChart barChart
    .x d3.time.scale().domain(timeDomain)
    .round d3.time.month.round
    .xUnits d3.time.months
    .elasticY true
    .renderHorizontalGridLines true
    .legend dc.legend().x(760).y(10).itemHeight(15).gap(5)
    .brushOn false
    .group monthGroup, 'Count'
    .valueAccessor (d) -> d.value
    .title (d) -> d.value
    
    #### Bar chart
    barChart
    .width -> $("#{element} .bar-chart").width()
    .height 60
    .margins { top: 0, right: 8, bottom: 20, left: 60 }
    .dimension monthDimension
    .group monthGroup
    .centerBar false
    .gap 1
    .x d3.time.scale().domain(timeDomain)
    .round d3.time.month.round
    .alwaysUseRounding true
    .xUnits d3.time.months
    .yAxis()
    .ticks 0

    #### Render all
    dc.renderAll groupname
    
    
    ## Update charts
    
    # Double click on pie chart
    pieChart.on "renderlet", (chart) ->
      pieChart.selectAll('path').on 'dblclick', (d) ->
        if dataset.schema.esco.levels[dataset.schema.esco.levels.length - 1] > dataset.levels.esco
          params = $.param( { query: esco: {key: d.data.key, level: dataset.levels.esco } } )
          json_url =  "#{dataset.url}?#{params}"
          page_url =  "?#{params}"
          history.pushState({}, "", page_url)
          d3.json json_url, (error,new_dataset) ->
            dataset = new_dataset
            log dataset.total_rows
            #### Fix data
            dataset.rows.forEach (d) ->
              log "null date in data" if d.date == null
              d.date = dateFormat.parse d.date
              d.month = d3.time.month d.date
              d.count = +d.count
            
            #resetData(ndx, [yearDim, spendDim, nameDim]);
            xf.remove()
            xf.add dataset.rows
            lineChart.rescale()
            barChart.rescale()
            dc.redrawAll groupname
            $("pre.debug").html("visualizing #{dataset.total_rows} rows")
        else
          log "maximum esco level"
    document.addEventListener 'diveIn', (e)->
      console.log e
    window.c = choroChart
    
    #### Resize window
    d3.select(window).on 'resize', ->
      log 'redraw'
      dc.renderAll groupname
      d3.select("#{element} .map .dc-leaflet").style 'width', (e) ->
        d3.select("#{element} .row").node().getBoundingClientRect().width - 2 + "px"

    #### Reset button
    $("#{element} .reset-all").on 'click',(event) ->
      event.preventDefault()
      dc.filterAll groupname
      dc.redrawAll groupname

    return

Map.summary_map3 = (element, file, names_map,groupname) ->
  log = (args...) -> console.log.apply this, args if true
  geojson = null
  
  if $(element).length == 1
  
    d3.json '/europe.geo.json', (error,data) ->
      log "#{groupname}: fetch geojson"
      alert 'reload page' if error
      geojson = data
      #log geojson.features.map  (f ) ->
      #  "\"#{f.properties.name}\": \"#{f.properties.name}\""
      #.join("\n")
      d3.json "#{file}?#{location.search.substr(1)}", (error,dataset) ->
        log "#{groupname}: fetch #{file}"
        alert 'reload page' if error
        
        Map.drawChoropleth3 element, dataset, geojson,names_map,groupname
        $("pre.debug").html("visualizing #{dataset.total_rows} rows")
