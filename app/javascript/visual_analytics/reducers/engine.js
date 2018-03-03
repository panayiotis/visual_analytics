import { handleActions } from 'redux-actions'

const initialState = {}

export default handleActions(
  {
    ENGINE_COMPUTATION: (state, action) => ({
      ...state,
      computation: { ...action.payload }
    })
  },
  initialState
)
