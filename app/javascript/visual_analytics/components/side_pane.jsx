import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Image, Button, Progress } from 'semantic-ui-react'
import SplitPane from 'react-split-pane'
import { connect } from 'react-redux'
import Menu from './menu'
import Charts from './charts'
//import { channelPerformRequest } from '../actions'
//import ChartsContainer from './charts_container'

class SidePane extends Component {
  render() {
    let progressBar = null

    /*if (['running', 'waiting'].includes(state)) {
      progressBar = (
        <Progress percent={100} size={'small'} indicating />
      )
    }*/

    return (
      <div
        className="sidepanejsx"
        style={{
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          height: '100%'
        }}
      >
        <Menu style={{ flex: 1 }} />
        <Charts style={{ flex: 2 }} />
      </div>
    )
  }
}

const mapStateToProps = state => ({
  statement: state.statement
})

const mapDispatchToProps = dispatch => ({})

export default connect(mapStateToProps, mapDispatchToProps)(SidePane)
