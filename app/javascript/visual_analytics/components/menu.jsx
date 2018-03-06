import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { sidebarToggle } from '../actions/layout'
import { handleCrossfilterReset } from '../actions/crossfilter'

import {
  Button,
  Divider,
  Grid,
  Icon,
  Image,
  Menu,
  Popup,
  Progress,
  Segment,
  Statistic,
  Sidebar,
  Table
} from 'semantic-ui-react'
import SplitPane from 'react-split-pane'
import { connect } from 'react-redux'
import isEmpty from 'lodash/isEmpty'
import get from 'lodash/get'
//import { toggleSidebar } from '../actions'

const ConnectionStatusMenuItem = props => {
  const { name, color, loading } = props
  const { header, content } = props
  return (
    <Popup
      trigger={
        <Menu.Item>
          <Icon {...{ name, color, loading }} />
        </Menu.Item>
      }
      {...{ header, content }}
      on={['hover', 'click']}
    />
  )
}

const ProgressBarLabel = props => {
  const { state } = props
  switch (state) {
    case 'initial':
      return 'initial'
    case 'waiting':
      return 'waiting'
    case 'running':
      return 'running'
    case 'error':
      return 'error'
    case 'success':
      return 'success'
    default:
      return null
  }
}

const ProgressBar = props => {
  const { state, progress } = props
  switch (state) {
    case 'initial':
      return <Progress size="small" disabled percent={0} />
    case 'waiting':
      return <Progress size="small" active color="teal" percent={100} />
    case 'running':
      return <Progress size="small" active success percent={progress * 100} />
    case 'error':
      return <Progress size="small" error percent={progress * 100} />
    case 'success':
      return <Progress size="small" disabled percent={100} />
    default:
      return null
  }
}

class CustomMenu extends Component {
  render() {
    const { data, schema } = this.props
    const { server, engine } = this.props.connectivity
    const { sidebar } = this.props.layout
    const { computation } = this.props.engine
    const { request, fetchAction, reset } = this.props
    const { sidebarToggle } = this.props
    const totalRows = this.props.data.length
    const filteredRows = this.props.crossfilter.count
    const filteredSum = this.props.crossfilter.sum
    const hasFilters = filteredRows != totalRows

    const sesionStatus = (loading, busy, idle) => {
      if (engine.sessions.length == 0) {
        return loading
      } else {
        let state = engine.sessions.slice(-1)[0].state
        if (state == 'busy') {
          return busy
        } else {
          return idle
        }
      }
    }
    const connectionStatusProps = [
      {
        key: 'session',
        name: sesionStatus('spinner', 'code', 'code'),
        color: sesionStatus('red', 'green', 'blue'),
        loading: sesionStatus(true, false, false),
        header: 'Session',
        content: 'a spark session must be initiated before the app can run'
      },
      {
        key: 'spark',
        name: engine.connected ? 'server' : 'spinner',
        color: engine.connected ? 'blue' : 'red',
        loading: !engine.connected ? true : false,
        header: 'Big Data Processing Engine',
        content: 'Connectivity to Apache Spark'
      },
      {
        key: 'server',
        name: server.connected ? 'wifi' : 'spinner',
        color: server.connected ? 'blue' : 'red',
        loading: !server.connected ? true : false,
        header: 'Visual Analytics server',
        content:
          'shows connectivity to the visual analytics server via websockets'
      }
    ]

    return (
      <div>
        <Menu attached="top">
          <Menu.Item
            icon="sidebar"
            name="Visual Analytics App"
            onClick={sidebarToggle()}
          />
          <Menu.Menu position="right">
            {connectionStatusProps.map(props => (
              <ConnectionStatusMenuItem {...props} />
            ))}
          </Menu.Menu>
        </Menu>

        <Segment attached="bottom">
          <Grid divided columns={16}>
            <Grid.Column width={4} style={{ paddingBottom: 0 }}>
              <ProgressBarLabel {...computation} />
            </Grid.Column>
            <Grid.Column width={12} style={{ paddingBottom: 0 }}>
              <ProgressBar {...computation} />
            </Grid.Column>
          </Grid>
        </Segment>
        <Segment attached="bottom">
          <Statistic.Group widths={4} size="mini">
            <Statistic label="total rows" value={totalRows} />
            <Statistic
              label="filtered rows"
              value={filteredRows == 0 ? totalRows : filteredRows}
            />
            <Statistic label="Sum" value={filteredSum} />
            {
              <Button
                disabled={!hasFilters}
                size="mini"
                onClick={handleCrossfilterReset()}
              >
                reset
              </Button>
            }
          </Statistic.Group>
        </Segment>
      </div>
    )
  }
}

const mapStateToProps = state => ({
  ...state
})

const mapDispatchToProps = dispatch => ({
  sidebarToggle: () => () => dispatch(sidebarToggle()),
  handleCrossfilterReset: () => () => dispatch(handleCrossfilterReset())
})

export default connect(mapStateToProps, mapDispatchToProps)(CustomMenu)
