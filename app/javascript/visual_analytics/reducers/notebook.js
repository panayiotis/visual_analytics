import { handleActions } from 'redux-actions'
import { NOTEBOOK } from '../actions/action_types'

const initialState = 'empty'

export default handleActions(
  {
    NOTEBOOK: (state, action) => action.payload
  },
  initialState
)
