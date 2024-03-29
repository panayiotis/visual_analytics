import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  Button,
  Divider,
  Grid,
  Icon,
  Label,
  Menu,
  Message,
  Popup,
  Progress,
  Segment,
  Statistic,
  Table
} from 'semantic-ui-react'
import { perform, requestInitialData } from '../actions/connectivity'
import get from 'lodash/get'
import isEmpty from 'lodash/isEmpty'
import flatten from 'lodash/flatten'
import zip from 'lodash/zip'
import { fetchAction } from '../middleware/fetch_middleware'
import crossfilter from 'crossfilter2'
import * as d3 from 'd3'
import RowChart from './row_chart'
import TimelineChart from './timeline_chart'
import HierarchyLabels from './hierarchy_labels'
import { crossfilterAction, updateElevations } from '../actions/crossfilter'

const NoSessionMessage = () => (
  <Message color="orange" floating icon>
    <Icon name="circle notched" loading />
    <Message.Content>
      <Message.Header>No visualization data yet</Message.Header>
      You have to connect to an active Spark Session
    </Message.Content>
  </Message>
)

class Charts extends Component {
  constructor(props) {
    super(props)
    this.state = {
      renderCount: 1
    }
    props.requestInitialData()
    this.segments = []
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      renderCount: this.state.renderCount + 1
    })
    const { data, schema } = nextProps
    const { request, fetchAction, reset, crossfilterAction } = nextProps

    App.xf = crossfilter(data)
    App.dimensions = {}
    App.groups = {}

    const fields = Object.values(schema.fields).sort((a, b) => {
      if (a.name === 'date') {
        return -1
      } else if (b.name === 'date') {
        return 1
      } else if (a.name === 'nuts') {
        return -1
      } else if (b.name === 'nuts') {
        return 1
      } else {
        return -1
      }
    })
    fields.forEach(f => {
      App.dimensions[f.name] = App.xf.dimension(d => d[f.name])
    })

    fields.forEach(f => {
      App.groups[f.name] = App.dimensions[f.name]
        .group()
        .reduceSum(d => d.count)
    })
    const uniqueValues = name => App.groups[name].all().map(g => g.key)

    this.segments = fields.map(f => {
      let props = {
        key: `${f.name}chart`,
        dimension: App.dimensions[f.name],
        group: App.groups[f.name],
        ...f
      }
      let chart
      switch (f.name) {
        case 'date':
          chart = <TimelineChart {...props} />
          break
        default:
          chart = <RowChart {...props} />
      }
      return (
        <Segment.Group key={`${f.name}segment`}>
          <Label attached="top">{f.name}</Label>
          <HierarchyLabels key={`${f.name}levels`} {...f} />
          <Segment>{chart}</Segment>
        </Segment.Group>
      )
    })

    crossfilterAction({
      sum: App.xf
        .groupAll()
        .reduceSum(d => d.count)
        .value(),
      count: App.xf
        .groupAll()
        .reduceCount()
        .value()
    })
    updateElevations()
  }

  render() {
    const segments = this.segments
    if (segments.length == 0) {
      return (
        <div style={{ margin: '3em 1em' }}>
          <NoSessionMessage />
        </div>
      )
    }

    return (
      <div
        className="hello"
        style={{ overflow: 'auto', position: 'relative', top: 0, bottom: 0 }}
      >
        <div style={{ padding: '5px' }}>{segments}</div>
      </div>
    )
  }
}

const mapStateToProps = state => ({
  schema: state.schema,
  data: state.data
})

const mapDispatchToProps = dispatch => ({
  requestInitialData: () => dispatch(requestInitialData()),
  request: data => () => dispatch(perform('chunks', 'request', data)),
  crossfilterAction: data => dispatch(crossfilterAction(data)),
  updateElevations: () => dispatch(updateElevations())
})

export default connect(mapStateToProps, mapDispatchToProps)(Charts)
