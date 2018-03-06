import { handleActions } from 'redux-actions'

const initialState = { sidebar: false }

export default handleActions(
  {
    SIDEBAR: (state, action) => ({ ...state, sidebar: !state.sidebar }),
    LAYOUT: (state, action) => ({ ...state, ...action.payload })
  },
  initialState
)
