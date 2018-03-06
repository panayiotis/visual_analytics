import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Image, Button, Progress, Tab } from 'semantic-ui-react'
import SplitPane from 'react-split-pane'
import { connect } from 'react-redux'
import Menu from './menu'
import Charts from './charts'
//import { channelPerformRequest } from '../actions'
//import ChartsContainer from './charts_container'

class DebugPane extends Component {
  render() {
    let progressBar = null

    /*if (['running', 'waiting'].includes(state)) {
      progressBar = (
        <Progress percent={100} size={'small'} indicating />
      )
    }*/

    const { data, schema } = this.props
    const panes = [
      {
        menuItem: 'Schema',
        render: () => (
          <Tab.Pane>
            <pre>{JSON.stringify(schema, null, 2)}</pre>
          </Tab.Pane>
        )
      },
      {
        menuItem: 'Data',
        render: () => (
          <Tab.Pane>
            <pre>{JSON.stringify(data, null, 2)}</pre>
          </Tab.Pane>
        )
      }
    ]
    return (
      <div style={{}}>
        <h3>Debug pane</h3>
        <Tab panes={panes} />
      </div>
    )
  }
}

const mapStateToProps = state => ({
  ...state
})

const mapDispatchToProps = dispatch => ({})

export default connect(mapStateToProps, mapDispatchToProps)(DebugPane)
