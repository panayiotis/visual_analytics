import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Image, Button } from 'semantic-ui-react'
import SplitPane from 'react-split-pane'
import { connect } from 'react-redux'
import Menu from './menu'
import SidePane from './side_pane'
import DebugPane from './debug_pane'
import { layoutAction, chartsPaneResize } from '../actions/layout'
//import Map from './map'

class WorkPanes extends Component {
  render() {
    const { chartsPaneResize } = this.props
    return (
      <div>
        <SplitPane
          split="vertical"
          minSize={300}
          maxSize={800}
          defaultSize={600}
          className="primary"
          onChange={size => chartsPaneResize()}
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
            <DebugPane />
          </SplitPane>
        </SplitPane>
      </div>
    )
  }
}

const mapStateToProps = state => ({})

const mapDispatchToProps = dispatch => ({
  /* use with the pane onChange={size => layoutAction({ paneSize: size })}*/
  layoutAction: layout => dispatch(layoutAction(layout)),
  chartsPaneResize: () => dispatch(chartsPaneResize())
})

export default connect(mapStateToProps, mapDispatchToProps)(WorkPanes)
