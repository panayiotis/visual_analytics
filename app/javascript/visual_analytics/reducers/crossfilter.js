import { handleActions } from 'redux-actions'
import { CROSSFILTER, CROSSFILTER_FILTER } from '../actions/action_types'

const initialState = { count: 0, sum: 0, filters: {} }

export default handleActions(
  {
    [CROSSFILTER]: (state, action) => ({ ...initialState, ...action.payload }),
    [CROSSFILTER_FILTER]: (state, action) => ({
      ...state,
      sum: action.payload.sum,
      count: action.payload.count,
      filters: { ...state.filters, ...action.payload.filters }
    })
  },
  initialState
)
