import dc_leaflet from 'dc.leaflet'

export default class Visualization
  constructor: (data,geojson) ->
    console.log 'Visualization: object created'

    # leaflet tiles providers
    # https://leaflet-extras.github.io/leaflet-providers/preview/
    tiles = 'http://server.arcgisonline.com/ArcGIS/rest/services/'+
      'World_Topo_Map/MapServer/tile/{z}/{y}/{x}'

    map_tiles_attribution= 'Esri, DigitalGlobe, GeoEye, ' +
      'Earthstar Geographics, CNES/Airbus DS, USDA, USGS, ' +
      'AeroGRID, IGN, GIS User Community'

    # override use of tiles according to environment variables
    # when webpack bundles the pack
    if (process.env.NODE_ENV == 'production' &&
        process.env.MAP_TILES &&
        process.env.MAP_TILES_ATTRIBUTION)
      tiles = process.env.MAP_TILES
      map_tiles_attribution = process.env.MAP_TILES_ATTRIBUTION

    attributionText=
      'Εφαρμογή: <a target="_blank" '+
      'href="http://statistics.gr">statistics.gr</a> | ' +
      'Δεδομένα: <a target="_blank" href="http://ekt.gr">ΕΚΤ</a> | ' +
      'Χαρτογραφικά Δεδομένα: ' + map_tiles_attribution + ' | ' +
      'Μηχανή χαρτών: ' +
      '<a target="_blank" href="http://leafletjs.com">Leaflet</a><br/>' +
      'Για περισσότερες πληροφορίες σχετικά με τις οντότητες ' +
      'με τις οποίες η Ελλάδα έχει συνάψει διμερείς σχέσεις ' +
      'μπορείτε να ανατρέξετε στην ' +
      '<a target="_blank" ' +
      'href="http://www.mfa.gr/dimereis-sheseis-tis-ellados.html">' +
      'ιστοσελίδα του Υπουργείου Εξωτερικών' +
      '</a>'

    groupname = 'visualization'
    element = '#visualization'

    console.table geojson.features.map (f) ->
      [f.properties.admin,f.properties.iso_a2,f.properties.iso_a3]

    country_codes = data.map((d) -> d.country).filter (element, index, array) ->
      array.lastIndexOf(element) == index

    #geojson.features = geojson.features.filter (d) ->
    #  country_codes.includes(d.properties.iso_a2)

    #### Discover
    nut_field = 'country'

    #### Formatters
    dateFormat = d3.time.format.utc('%Y')
    numberFormat = d3.format('d')

    #### Fix data
    data.forEach (d) ->
      console.log "null date in data" if d.date == null
      d.date = dateFormat.parse d.year
      d.year = +d.year
      d.count =  +d.count
      # random count for testing
      #d.count =  Math.floor((Math.random() * 100) + 1)

    # print data head
    console.table data.slice(0,6)

    #### Extract time domain
    timeDomain = data.reduce (acc,val) ->
      m = val.date
      acc[0] = m if m < acc[0]
      acc[1] = m if m > acc[1]
      acc
    ,[ new Date(), 0 ]
    console.log timeDomain

    #### Create chart objects
    choroplethChart = dc_leaflet.choroplethChart "#{element} .map", groupname
    timelineChart = dc.barChart "#{element} .timeline", groupname
    rowChart = dc.rowChart "#{element} .row-chart", groupname

    #### Create crossfilter dimensions and groups
    xf = crossfilter(data)
    dateDimension = xf.dimension (d) -> d.date
    dateGroup = dateDimension.group().reduceSum (d) -> d.count
    nutDimension = xf.dimension (d) -> d[nut_field]
    nutGroup = nutDimension.group().reduceSum (d) -> d.count

    #### Color pallete
    # color pallete is based on Colorbrewer 9-class Reds
    colors = d3.scale.quantize().range([
      d3.rgb("#fff5f0").darker(0.0)
      d3.rgb("#fee0d2").darker(0.0)
      d3.rgb("#fcbba1").darker(0.0)
      d3.rgb("#fc9272").darker(0.0)
      d3.rgb("#fb6a4a").darker(0.0)
      d3.rgb("#ef3b2c").darker(0.0)
      d3.rgb("#cb181d").darker(0.0)
      d3.rgb("#a50f15").darker(0.0)
      d3.rgb("#67000d").darker(0.0)
      d3.rgb("#670000").darker(0.5)
      d3.rgb("#670000").darker(1.2)
      d3.rgb("#670000").darker(2.0)
    ])

    #### Timeline chart
    # centerBar, elasticX, round, xAxisPadding and xAxisPaddingUnit
    # align x-axis values to the center bottom the bar and also make the brush
    # selection align with the bar edges.
    # label and yAxisPadding are used to display labels above each bar.
    # Without yAxisPadding high bars get hidden.
    timelineChart
    .height -> $("#{element} .timeline").height()
    .width -> $("#{element} .timeline").width()
    .margins {top: 10, right: 30, bottom: 30, left: 50}
    .dimension dateDimension
    .group dateGroup
    .alwaysUseRounding(true)
    .barPadding 0.1
    .centerBar true
    .elasticX true
    .elasticY true
    .label (d) -> d.y
    .renderHorizontalGridLines true
    .round (date) -> d3.time.month.offset(d3.time.year(date),6)
    .transitionDuration 500
    .x(d3.time.scale().domain(timeDomain))
    .xAxisLabel "έτη"
    .xAxisPadding 6
    .xAxisPaddingUnit 'month'
    .xUnits d3.time.years
    .yAxisLabel "ακαδημαϊκή παρουσία"
    .yAxisPadding '8%'

    #### Row chart
    rowChart
    .height -> $("#{element} .row-chart").height()
    .width -> $("#{element} .row-chart").width()
    .margins { top: 10, right: 10, bottom: 20, left: 50 }
    .dimension nutDimension
    .group nutGroup
    .cap 8
    .colorAccessor (d, i) -> d.value
    .colors colors
    .elasticX true
    .gap 2
    .labelOffsetX -50
    .ordering (d)-> -d.value
    .transitionDuration 500
    .on 'renderlet', (chart) ->

      # add country flag on the left of each row
      chart.selectAll 'g.row'
      .append 'image'
      .attr 'xlink:href', (d) ->
        "/flags/4x3/#{d.key.toLowerCase()}.svg"
      .attr 'x',-28
      .attr 'y',0
      .attr 'height', 20
      .attr 'width', 25

      # add stroke on each row
      chart.selectAll 'rect'
      .style 'stroke-width', 1
      .style 'stroke', ->
        d3.rgb(d3.select(this).attr('fill')).darker(0.8)

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
      minZoom: 2
      trackResize: true
      worldCopyJump: true
    .tiles (map) ->
      L.control.attribution(
        { position:'bottomleft', prefix: attributionText }
      ).addTo(map)
      L.tileLayer(tiles, {opacity: 1.0}).addTo(map)
    .dimension nutDimension
    .group nutGroup
    .center [40, -20 ]
    .colors(colors)
    .colorAccessor (d, i) -> d.value
    .calculateColorDomain() # must be called after colors and colorAccessor
    .featureKeyAccessor (feature) -> feature.properties.iso_a2
    .featureOptions (feature) ->
      fillColor: 'white'
      color: 'grey',
      opacity: 0.2
      fillOpacity: 0.8
      weight: 1
    .geojson geojson
    .legend(dc_leaflet.legend().position('topright'))
    .zoom 3
    .on 'preRedraw', (chart) -> chart.calculateColorDomain()
    .on 'filtered', (chart) ->
      selectedCountries = chart.filters()
      text = "πατήστε μια χώρα για να φιλτράρετε τα αποτελέσματα"
      if selectedCountries.length == 1
        text = "έχετε επιλέξει τη χώρα: " + selectedCountries.join(", ")
      else if selectedCountries.length > 1
        text = "έχετε επιλέξει τις χώρες: " + selectedCountries.join(", ")
      $("#{element} .map-info-container .hint").text(text)
    .on 'postRender', (chart) ->
      # Leaflet makes map responsive with the trackResize option
      # but parent element must not have fixed dimensions
      chart.select('.dc-leaflet').style('width', '100%')
      chart.select('.dc-leaflet').style('height', '100%')

    #### Render charts
    $('document').ready ->
      if $('#visualization .map').length
        choroplethChart.render()
      if $('#visualization .row-chart').length
        rowChart.render()
      if $('#visualization .timeline').length
        timelineChart.render()

    #### Add Reset Button event
    $('document').ready ->
      $("#{element} .reset.button").on 'click',(event) ->
        event.preventDefault()
        dc.filterAll groupname
        dc.redrawAll groupname

    #### Render charts on window resize
    $(window).on 'orientationchange pageshow resize', (event) ->
      console.log "resize on " + event.type
      rowChart.render()
      timelineChart.render()
      # map chart is already responsive
