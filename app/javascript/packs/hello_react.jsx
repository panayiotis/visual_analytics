// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.
// See also https://github.com/rails/webpacker/blob/master/docs/props.md

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

const Hello = props => (
  <span className='hello-react'>
    {props.message} {props.name}!
  </span>
)

// Render component with data
document.addEventListener('turbolinks:load', () => {
  const node = document.getElementById('hello-react')
  if(node){
    const data = JSON.parse(node.getAttribute('data'))
    console.log('react:render');
    ReactDOM.render(<Hello {...data} />, node)
  }
})
