import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Image, Button } from 'semantic-ui-react'
import SplitPane from 'react-split-pane'
import { connect } from 'react-redux'
import Menu from './menu'
import SidePane from './side_pane'
//import Map from './map'

class WorkPanes extends Component {
  render() {
    //console.log(this.props)
    return (
      <div>
        <SplitPane
          split="vertical"
          minSize={300}
          maxSize={800}
          defaultSize={400}
          className="primary"
          pane1Style={{
            backgroundColor: 'rgba(255,255,255,1.0)',
            overflow: 'hidden',
            maxHeight: '100vh',
            height: '100vh'
          }}
        >
          <SidePane />
          <SplitPane
            split="horizontal"
            defaultSize={800}
            pane1Style={{
              backgroundColor: 'rgba(255,255,255,0)'
            }}
            pane2Style={{
              overflow: 'auto',
              backgroundColor: 'rgba(255,255,255,1)'
            }}
          >
            <div style={{ border: '1px solid lightblue' }}>
              <h1>pane 2</h1>
            </div>
            <div style={{}}>
              <h3>pane</h3>
              <Image src="/assets/placeholder/paragraph.png" />
              <br />
              <Image src="/assets/placeholder/paragraph.png" />
              <br />
              <Image src="/assets/placeholder/paragraph.png" />
            </div>
          </SplitPane>
        </SplitPane>
      </div>
    )
  }
}

export default WorkPanes
