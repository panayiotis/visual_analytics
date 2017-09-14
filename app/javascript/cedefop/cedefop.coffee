# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

import {queue} from 'd3-queue'
import {json,csv} from 'd3-request'
import {timeFormat,timeParse,utcParse} from 'd3-time-format'
import dc_leaflet from 'dc.leaflet'
import colorbrewer from 'colorbrewer'
# https://github.com/sindresorhus/query-string
import queryString from 'query-string'

#TODO: replace d3.* functions with their imported counterparts
export default class Cedefop
  constructor: (element_data) ->
    console.log 'Cedefop: create'
    params = queryString.parse(location.search)
    console.log(params)
    @data=null
    @data_uri=element_data.data_uri + location.search
    @geojson=null
    @geojson_uri=element_data.geojson_uri
    console.log @geojson_uri
    @id=element_data.id

    loading.start('getting data from Apache Spark...')
    queue()
    .defer json, @data_uri
    .defer json, @geojson_uri
    .await (error, data, geojson) =>
      if error
        console.error "cedefop: can not get data"
      else
        loading.stop()
        @data = data
        @geojson = geojson
        @render()

  render: ->
    groupname = @id
    element = "##{@id}"

    # leaflet tiles providers
    # https://leaflet-extras.github.io/leaflet-providers/preview/
    tiles = 'https://server.arcgisonline.com/ArcGIS/rest/services/' +
      'World_Topo_Map/MapServer/tile/{z}/{y}/{x}'

    attributionText= 'Tiles: Esri &mdash; Esri, DeLorme, NAVTEQ, TomTom, ' +
      'Intermap, iPC, USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, ' +
      'Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), ' +
      'and the GIS User Community | ' +
      '<a target="_blank" href="http://leafletjs.com">Leaflet</a><br/>'

    #### Discover
    nut_field = 'nut'

    #### Formatters
    dateFormatter = utcParse('%Y-%m-%d')
    seasonFormatter = (date) ->
      month = date.getMonth() + 1
      switch month
        when 3,4,5 then 'spring'
        when 6,7,8 then 'summer'
        when 9,10,11 then 'autumn'
        when 12,1,2 then 'winter'
        else 'winter'

    #### Fix data
    @data.rows.forEach (d) ->
      log "null date in data" if d.date == null
      d.date = dateFormatter d.date
      d.season = seasonFormatter(d.date)
      d.count = (+d.count)
    console.table @data.rows.slice(0,6)

    # filter data before 2015
    # TODO: filtering should be done in the dataset
    d2015 = new Date(Date.UTC(2015, 3))
    @data.rows = @data.rows.filter (d) -> d.date >= d2015

    #### Extract time domain
    timeDomain = @data.rows.reduce (acc,val) ->
      m = val.date
      acc[0] = m if m < acc[0]
      acc[1] = m if m > acc[1]
      acc
    ,[ new Date(), 0 ]
    console.log timeDomain

    #### Create chart objects
    choroplethChart = dc_leaflet.choroplethChart "#{element} .map", groupname
    escoChart = dc.rowChart "#{element} .esco-chart", groupname
    nutChart = dc.rowChart "#{element} .nut-chart", groupname
    seasonChart = dc.pieChart "#{element} .season-chart", groupname
    timelineChart = dc.barChart "#{element} .timeline", groupname

    #### Create crossfilter dimensions and groups
    xf = crossfilter(@data.rows)
    dateDimension = xf.dimension (d) -> d.date
    dateGroup = dateDimension.group().reduceSum (d) -> d.count
    escoDimension = xf.dimension (d) -> d.esco
    escoGroup = escoDimension.group().reduceSum (d) -> d.count
    nutDimension = xf.dimension (d) -> d[nut_field]
    nutGroup = nutDimension.group().reduceSum (d) -> d.count
    seasonDimension = xf.dimension (d) -> d.season
    seasonGroup = seasonDimension.group().reduceSum (d) -> d.count

    #### Color pallete
    colors = d3.scale.quantize().range( colorbrewer.YlGnBu[9] )

    #### Timeline chart
    # centerBar, elasticX, round, xAxisPadding and xAxisPaddingUnit
    # align x-axis values to the center bottom the bar and also make the brush
    # selection align with the bar edges.
    # label and yAxisPadding are used to display labels above each bar.
    # Without yAxisPadding high bars get hidden.
    timelineChart
    .height -> $("#{element} .timeline").height()
    .width -> $("#{element} .timeline").width()
    .margins {top: 10, right: 10, bottom: 30, left: 60}
    .dimension dateDimension
    .group dateGroup
    .alwaysUseRounding(true)
    .barPadding 0.05
    .centerBar true
    .elasticX true
    .elasticY true
    #.label (d) -> d.y
    .renderHorizontalGridLines true
    .round (date) -> d3.time.day.offset(d3.time.month(date),15)
    .transitionDuration 500
    .x(d3.time.scale().domain(timeDomain))
    .xAxisLabel "months"
    .xAxisPadding 15
    .xAxisPaddingUnit 'day'
    .xUnits d3.time.months
    .yAxisLabel "vacancies"
    .yAxisPadding '8%'

    #### Nut chart
    nutChart
    .height -> $("#{element} .nut-chart").height()
    .width -> $("#{element} .nut-chart").width()
    .margins { top: 10, right: 10, bottom: 20, left: 30 }
    .dimension nutDimension
    .group nutGroup
    .colorAccessor (d, i) -> d.value
    .colors colors
    .elasticX true
    .gap 2
    .labelOffsetX 10
    .ordering (d)-> -d.value
    .transitionDuration 500
    .on 'renderlet', (chart) ->
      barHeight = chart.select('g.row rect').attr('height')

      # add country flag on the left of each row
      chart.selectAll 'g.row'
      .append 'image'
      .attr 'xlink:href', (d) ->
        "/flags/4x3/#{codes_map[d.key].toLowerCase()}.svg"
      .attr 'x',-28
      .attr 'y',barHeight/2 - 10
      .attr 'height', 20
      .attr 'width', 25

    #### Season chart
    seasonChart
    .dimension seasonDimension
    .group seasonGroup
    .colorAccessor (d, i) -> i
    .colors d3.scale.ordinal().range(colorbrewer.Spectral[4])
    .transitionDuration 500

    #### Esco chart
    escoChart
    .height -> $("#{element} .esco-chart").height()
    .width -> $("#{element} .esco-chart").width()
    .margins { top: 10, right: 10, bottom: 20, left: 30 }
    .dimension escoDimension
    .group escoGroup
    .colorAccessor (d, i) -> d.value
    .colors colors
    .elasticX true
    .gap 2
    .labelOffsetX 10
    .ordering (d)-> -d.value
    .transitionDuration 500
    .on 'renderlet', (chart) =>
      level = @data.levels.esco
      if level <= 3
        barHeight = chart.select('g.row rect').attr('height')

        # add country flag on the left of each row
        chart.selectAll 'g.row'
        .append 'a'
        .attr 'xlink:href', (d) ->
          "?query[esco][key]=#{d.key}&query[esco][level]=#{level}"
        .append 'image'
        .attr 'xlink:href', (d) ->
          "/enter.svg"
        .attr 'x',-30
        .attr 'y',barHeight / 2.0 - 10
        .attr 'height', 20
        .attr 'width', 25

    #### Choropleth Map chart
    choroplethChart
    .height -> $("#{element} .map").height()
    .width -> $("#{element} .map").width()
    .mapOptions
      attributionControl: false
      doubleClickZoom: false
      #maxBounds: L.latLngBounds(L.latLng( ↓ ,   ← ),L.latLng( ↑ ,  → ))
      maxBounds: L.latLngBounds(L.latLng( -150, -500),L.latLng(300, 500))
      maxZoom: 6
      minZoom: 3
      trackResize: true
      worldCopyJump: true
    .tiles (map) ->
      L.control.attribution(
        { position:'bottomright', prefix: attributionText }
      ).addTo(map)
      L.tileLayer(tiles, {opacity: .7}).addTo(map)
    .dimension nutDimension
    .group nutGroup
    .center [50, -20 ]
    .colors(colors)
    .colorAccessor (d, i) -> d.value
    .calculateColorDomain() # must be called after colors and colorAccessor
    .featureKeyAccessor (feature) -> names_map[feature.properties.name]
    .featureOptions (feature) ->
      fillColor: 'white'
      color: 'grey',
      opacity: 0.2
      fillOpacity: 0.8
      weight: 1
    .geojson @geojson
    .legend(dc_leaflet.legend().position('topright'))
    .zoom 4
    .on 'preRedraw', (chart) -> chart.calculateColorDomain()
    .on 'postRender', (chart) ->
      # Leaflet makes map responsive with the trackResize option
      # but parent element must not have fixed dimensions
      chart.select('.dc-leaflet').style('width', '100%')
      chart.select('.dc-leaflet').style('height', '100%')

    #### Render charts
    console.log "Cedefop: Render"
    choroplethChart.render()
    nutChart.render()
    escoChart.render()
    timelineChart.render()
    seasonChart.render()

    #### Add Reset Button event
    $("#{element} .reset.button").on 'click',(event) ->
      event.preventDefault()
      console.log('click')
      dc.filterAll groupname
      dc.redrawAll groupname

    #### Render charts on window resize
    $(window).on 'orientationchange pageshow resize', (event) ->
      console.log "resize on " + event.type
      nutChart.render()
      escoChart.render()
      timelineChart.render()
      seasonChart.render()
      # map chart is already responsive
    document.addEventListener 'turbolinks:before-render', ->
      console.log "Cedefop: Teardown"
      choroplethChart.map().remove()
      $("#{element} .map-container").empty()
      $("#{element} .map-container").append("<div class='map'></div>")
      dc.chartRegistry.clear groupname

# TODO: dataset should have an iso country identifier
names_map = {
  "United Kingdom": "UNITED KINGDOM"
  "Germany":  "DEUTSCHLAND"
  "Italy": "ITALIA"
  "Czech Rep.": "ČESKÁ REPUBLIKA"
  "Ireland": "IRELAND"
}

# TODO: dataset should have an iso country identifier
codes_map = {
  "UNITED KINGDOM": "GB"
  "DEUTSCHLAND": "DE"
  "ITALIA": "IT"
  "ČESKÁ REPUBLIKA":"CZ"
  "IRELAND":"IE"
}
