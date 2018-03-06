import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Image, Button, Progress, Statistic } from 'semantic-ui-react'
import SplitPane from 'react-split-pane'
import { connect } from 'react-redux'
import Menu from './menu'
import Charts from './charts'
//import { channelPerformRequest } from '../actions'
//import ChartsContainer from './charts_container'

class SidePane extends Component {
  render() {
    let progressBar = null
    const { filteredLength, dataLength } = this.props

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
  //filteredLength: state.crossfilter.filtered,
  //dataLength: state.data.length,
  statement: state.statement
})

const mapDispatchToProps = dispatch => ({})

export default connect(mapStateToProps, mapDispatchToProps)(SidePane)
