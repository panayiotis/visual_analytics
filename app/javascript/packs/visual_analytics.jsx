// Run this pack by adding <%= javascript_pack_tag 'visual_analytics' %>
// to the head of your layout file, like app/views/layouts/application.html.erb.
// See also https://github.com/rails/webpacker/blob/master/docs/props.md

import React from 'react'
import { render } from 'react-dom'
import { createStore, applyMiddleware, compose } from 'redux'
import { Provider } from 'react-redux'
import thunk from 'redux-thunk'
import App from '../visual_analytics'
import reducer from '../visual_analytics/reducers'
import fetchMiddleware from '../visual_analytics/middleware/fetch_middleware'
import dataTransformMiddleware from '../visual_analytics/middleware/data_transform_middleware'

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__
    ? window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({})
    : compose

document.addEventListener('turbolinks:load', () => {
  // get initial state from dom element #state
  const stateNode = document.getElementById('state')
  var initialState = {}
  if (stateNode) {
    initialState = JSON.parse(stateNode.getAttribute('data'))
  }

  // create store with initial state from dom element
  const store = createStore(
    reducer,
    initialState,
    composeEnhancers(
      applyMiddleware(thunk, fetchMiddleware, dataTransformMiddleware)
    )
  )

  render(
    <Provider store={store}>
      <App />
    </Provider>,
    document.body.appendChild(document.createElement('div'))
  )
})
