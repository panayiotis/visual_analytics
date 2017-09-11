#d3 = require "d3"
import * as d3 from 'd3'

export default class FetchData
  constructor: ->
    console.log 'FetchData: object created'
    @data=null
    @geojson=null
    @geojson_fetched = false
    @data_fetched = false

  fetch: ->
    emit_event = =>
      if @geojson_fetched && @data_fetched
        event = new CustomEvent 'data_fetched', {detail: "hi"}
        console.log "FetchData: data fetched"
        document.dispatchEvent(event)

    geojson_uri = '/data/countries.geojson'
    data_uri = '/data/greek_publications.csv'

    #### Fetch geojson
    console.time 'fetch geojson'
    d3.json geojson_uri, (error,geojson) =>
      console.timeEnd 'fetch geojson'
      console.log "fetch geojson"
      alert 'reload page' if error
      @geojson_fetched = true
      @geojson=geojson
      emit_event()

    #### Fetch data
    console.time 'fetch data'
    d3.csv data_uri, (error,data) =>
      console.timeEnd 'fetch data'
      alert 'reload page' if error
      @data_fetched = true
      @data=data
      emit_event()
