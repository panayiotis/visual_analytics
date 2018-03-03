import { handleActions } from 'redux-actions'
import { SIDEBAR } from '../actions/action_types'

const initialState = { sidebar: false }

export default handleActions(
  {
    SIDEBAR: (state, action) => ({ ...state, sidebar: !state.sidebar })
  },
  initialState
)
