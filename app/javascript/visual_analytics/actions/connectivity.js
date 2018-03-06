import ActionCable from 'actioncable'
import { createAction } from 'redux-actions'

import {
  CHANNEL_CONNECTED,
  CHANNEL_DISCONNECTED,
  CHANNEL_RECEIVED,
  CHANNEL_PERFORM
} from '../actions/action_types'

export const connected = createAction(CHANNEL_CONNECTED)

export const disconnected = createAction(CHANNEL_DISCONNECTED)

/**
 * Perform a channel action
 * The actual params object that the server will receive is the data object
 * with an extra key named action with the action name.
 *
 * @param {string} channel name.
 * @param {string} action name.
 * @param {object} data.
 * @return {action} a simple redux action.
 */
export const perform = (channel, action, data) => {
  return function(dispatch) {
    App.channels[channel].perform(action, data)
    dispatch({ type: CHANNEL_PERFORM, payload: data })
  }
}

export const establish = () => {
  return function(dispatch, getState) {
    console.debug('[ActionCable] Subscribe to : ChunksChannel, NotebookChannel')
    ActionCable.startDebugging()
    window.App = {}
    App.cable = ActionCable.createConsumer()
    App.channels = {}
    connectToNotebookChannel(dispatch, getState)
    connectToChunksChannel(dispatch, getState)
  }
}

const connectToNotebookChannel = (dispatch, getState) => {
  const channel = {
    channel: 'NotebookChannel',
    notebook: getState().notebook
  }
  const mixin = {
    connected: function() {
      dispatch(connected(channel.channel))
    },
    disconnected: function() {
      dispatch(disconnected(channel.channel))
    },
    received: function(action) {
      dispatch(action)
    }
  }
  App.channels.notebook = App.cable.subscriptions.create(channel, mixin)
}

const connectToChunksChannel = (dispatch, getState) => {
  const channel = {
    channel: 'ChunksChannel',
    notebook: getState().notebook
  }
  var mixin = {
    connected: function() {
      dispatch(connected(channel.channel))
    },
    disconnected: function() {
      dispatch(disconnected(channel.channel))
    },
    received: function(action) {
      dispatch(action)
    }
  }
  App.channels.chunks = App.cable.subscriptions.create(channel, mixin)
}

export const requestInitialData = () => {
  return function(dispatch, getState) {
    let sleepTime = 100

    function loop() {
      /* Here is your code. Balabala...*/
      let connected = getState().connectivity.engine.connected
      if (connected) {
        console.debug('request initial data...')
        dispatch(perform('chunks', 'request_initial_data', {}))
        clearInterval(handler)
      }
    }

    var handler = setInterval(loop, sleepTime)
  }
}
