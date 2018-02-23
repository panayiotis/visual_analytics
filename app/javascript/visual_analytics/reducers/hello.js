import { handleActions } from 'redux-actions'
import { A_REDUX_ACTION } from '../actions/action_types'

const initialState = 'empty'

export default handleActions(
  {
    A_REDUX_ACTION: (state, action) => action.payload
  },
  initialState
)
