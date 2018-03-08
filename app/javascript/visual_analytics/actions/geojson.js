import { GEOJSON } from './action_types'
import { createAction } from 'redux-actions'
export const geojsonAction = createAction(GEOJSON)

export const fetchGeojson = () => {
  return function(dispatch, getState) {
    console.log('fetch geojson')
    fetch('/geojson/nuts/3/UK.json')
      .then(response => response.json())
      .then(json => dispatch(geojsonAction(json)))
  }
}
