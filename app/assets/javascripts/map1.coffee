# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  
  cedefop_names_map = {
    "United Kingdom": "UNITED KINGDOM"
    "Germany":  "DEUTSCHLAND"
    "Italy": "ITALIA"
    "Czech Rep.": "ČESKÁ REPUBLIKA"
    "Ireland": "IRELAND"
  }

  drawChoropleth = (data, geojson) ->
    dataP = []
    
    console.log geojson
    
    filtered_features = geojson.features.filter (feature) ->
      Object.keys(cedefop_names_map).indexOf(feature.properties.name) > -1
    
    geojson.features = filtered_features
    ### 
    data.forEach (d) ->
      d.sum = 0
      for p of d
        if p and p != 'country' and p != 'sum'
          dataP.push
            'country': d.country
            'esco': p
            'count': +d[p]
          d.sum += +d[p]
    ###
    console.log 'dataP ->'
    console.log dataP

    console.log 'data ->'
    console.log data

    xf = crossfilter(data)
    
    groupname = 'Choropleth'
    
    facilities = xf.dimension (d) ->
      #console.log d.country
      d.country
    
    facilitiesGroup = facilities.group()
    .reduceSum (d) ->
      d.count
    console.log facilitiesGroup

    choro = dc_leaflet.choroplethChart('#map-example-1 .map', groupname)
    .mapOptions
      maxZoom: 5.5
      minZoom: 3.5
    .dimension(facilities)
    .group(facilitiesGroup)
    .width(1000)
    .height(500)
    .center([
      50
      20
    ])
    .zoom(4)
    .geojson(geojson)
    .colors(colorbrewer.YlGnBu[7])
    .colorDomain([
      d3.min(facilitiesGroup.all(), dc.pluck('value'))
      d3.max(facilitiesGroup.all(), dc.pluck('value'))
    ])
    .colorAccessor((d, i) ->
      d.value
    )
    .featureKeyAccessor((feature) ->
      cedefop_names_map[feature.properties.name]
    )
    .renderPopup(true).popup((d, feature) ->
      console.log d
      feature.properties.name + ' : ' + d.value
    )
    .legend(dc_leaflet.legend().position('bottomright'))
    
    types = xf.dimension (d) -> d.esco

    typesGroup = types.group().reduceSum((d) -> d.count )

    pie = dc.pieChart('#map-example-1 .pie', groupname)
    .dimension(types)
    .group(typesGroup)
    .width(200)
    .height(200)
    .ordering((p) ->
      +p.value
    )
    .renderLabel(true)

    dc.renderAll groupname
    
    return { choro: choro, pie: pie }

  geojson = null
  
  if $('#map-example-1').length == 1
  
    d3.json 'europe.geo.json', (data) ->
      geojson = data
      #console.log geojson.features.map( (f ) -> f.properties.name).join(" ")

    d3.csv '/spark/1/data.csv', (data) ->
      if geojson
        drawChoropleth data, geojson
