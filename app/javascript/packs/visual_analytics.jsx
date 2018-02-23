// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.
// See also https://github.com/rails/webpacker/blob/master/docs/props.md

import React from 'react'
import { render } from 'react-dom'
import { createStore, applyMiddleware, compose } from 'redux'
import { Provider } from 'react-redux'
import thunk from 'redux-thunk'
import App from '../visual_analytics'
import reducer from '../visual_analytics/reducers'

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__
    ? window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({})
    : compose

const store = createStore(reducer, composeEnhancers(applyMiddleware(thunk)))

// Render component with data
document.addEventListener('turbolinks:load', () => {
  const node = document.getElementById('app-root')
  //node.style.cssText = 'border:1px solid lightgrey;'

  if (node) {
    const data = JSON.parse(node.getAttribute('data'))
    console.log('react:render', data)
    render(
      <Provider store={store}>
        <App {...data} />
      </Provider>,
      node
    )
  }
})
