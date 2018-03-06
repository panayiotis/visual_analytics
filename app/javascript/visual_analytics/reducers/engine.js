import { handleActions } from 'redux-actions'
import { ENGINE_COMPUTATION, ENGINE_DRILL } from '../actions/action_types'

const initialState = { computation: { state: 'initial' } }

export default handleActions(
  {
    [ENGINE_COMPUTATION]: (state, action) => ({
      ...state,
      computation: { ...action.payload }
    }),
    [ENGINE_DRILL]: (state, action) => ({
      ...state,
      computation: { state: 'waiting' }
    })
  },
  initialState
)
