import { handleActions } from 'redux-actions'

const initialState = {}

export default handleActions(
  {
    DATA: (state, action) => ({ ...action.payload.schema })
  },
  initialState
)
