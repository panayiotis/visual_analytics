import React, { Component } from 'react'
import PropTypes from 'prop-types'
import {
  Segment,
  Header,
  Sidebar,
  Image,
  Button,
  Menu,
  Icon
} from 'semantic-ui-react'
import SplitPane from 'react-split-pane'
import { connect } from 'react-redux'
//import { toggleSidebar } from '../actions'
import WorkPanes from './work_panes'
import CustomSidebar from './sidebar'
import Map from './map'
class Layout extends Component {
  render() {
    return (
      <div>
        <Map />
        <Sidebar.Pushable
          style={{
            backgroundColor: 'rgba(255,255,255,0.0)'
          }}
        >
          <CustomSidebar />
          <Sidebar.Pusher
            style={{
              height: '100vh',
              backgroundColor: 'rgba(255,255,255,0.0)'
            }}
          >
            {<WorkPanes toggleSidebar={this.toggleSidebar} />}
          </Sidebar.Pusher>
        </Sidebar.Pushable>
      </div>
    )
  }
}

const mapStateToProps = state => {
  return { ...state.layout }
}

const mapDispatchToProps = dispatch => {
  return {
    onMenuClick: () => {
      //dispatch(toggleSidebar())
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Layout)
