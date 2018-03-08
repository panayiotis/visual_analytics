import ActionCable from 'actioncable'
import { createAction } from 'redux-actions'
import dc from 'dc'
import get from 'lodash/get'
import colorbrewer from 'colorbrewer'
import { CROSSFILTER_FILTER, CROSSFILTER } from '../actions/action_types'
import { geojsonAction } from './geojson'

export const crossfilterFilter = data => {
  return function(dispatch) {
    dispatch({ type: CROSSFILTER_FILTER, payload: data })
    dispatch(updateElevations())
  }
}

export const crossfilterAction = data => {
  return function(dispatch) {
    dispatch({ type: CROSSFILTER, payload: data })
    dispatch(updateElevations())
  }
}

export const handleCrossfilterReset = () => {
  return function(dispatch) {
    dc.filterAll()
    dc.redrawAll()
    dispatch(updateElevations())
  }
}

export const updateElevations = () => {
  return function(dispatch, getState) {
    const group = get(App, 'groups.nuts')
    if (!group) {
      return null
    }
    const elevations = group.all().reduce((acc, val) => {
      acc[val.key] = val.value
      return acc
    }, {})

    const maxElevation = d3.max(Object.values(elevations))

    const total = group.size()
    var targetElevation
    if (total == 0) {
      targetElevation = 1000
    } else if (total <= 5) {
      targetElevation = 20000
    } else if (total <= 10) {
      targetElevation = 40000
    } else if (total < 15) {
      targetElevation = 60000
    } else {
      targetElevation = 80000
    }

    const elevationScale = d3.scale
      .linear()
      .domain([0, maxElevation])
      .range([1, targetElevation])

    const fillColor = d3.scale
      .quantile()
      .range([
        [1, 152, 189],
        [73, 227, 206],
        [216, 254, 181],
        [254, 237, 177],
        [254, 173, 84],
        [209, 55, 78]
      ])
      .domain(Object.values(elevations))

    const geojson = getState().geojson

    geojson.features.forEach(f => {
      const el = elevations[f.properties.NUTS_ID]
      if (el) {
        f.properties.elevation = Math.round(Number(elevationScale(el)))
        f.properties.fillColor = [...fillColor(el), 255]
        f.properties.lineColor = [0, 0, 0, 255]
        //console.log(f.properties.fillColor)
      } else {
        f.properties.elevation = 1
        f.properties.fillColor = [0, 0, 0, 0]
        f.properties.lineColor = [0, 0, 0, 0]
      }
    })

    const obj = Object.assign({}, geojson)
    obj.features = Object.assign([], geojson.features)

    dispatch(geojsonAction(obj))
    return geojsonAction(obj)
  }
}
