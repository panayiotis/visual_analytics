import { handleActions } from 'redux-actions'

const initialState = {
  server: { connected: false },
  engine: { total: 0, sessions: [], connected: false }
}

export default handleActions(
  {
    CHANNEL_CONNECTED: (state, action) => ({
      ...state,
      server: { ...state.server },
      server: { connected: true }
    }),
    CHANNEL_DISCONNECTED: (state, action) => ({
      ...state,
      server: { ...state.server },
      server: { connected: true }
    }),
    CHANNEL_RECEIVED: (state, action) => ({ ...state }),
    CHANNEL_PERFORM: (state, action) => ({ ...state }),
    CONNECTIVITY_ENGINE: (state, action) => ({
      ...state,
      engine: action.payload
    })
  },
  initialState
)
