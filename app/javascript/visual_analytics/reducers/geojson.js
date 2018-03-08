import { handleActions } from 'redux-actions'
import { GEOJSON } from '../actions/action_types'

const initialState = { type: 'FeatureCollection', features: [] }

export default handleActions(
  {
    [GEOJSON]: (state, action) => ({ ...action.payload })
  },
  initialState
)
