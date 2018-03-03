import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  Button,
  Icon,
  Table,
  Divider,
  Segment,
  Menu,
  Grid,
  Popup,
  Progress
} from 'semantic-ui-react'
import { perform, requestInitialData } from '../actions/connectivity'
import schemadata from '../schema_stub'
import get from 'lodash/get'
import isEmpty from 'lodash/isEmpty'
import { fetchAction } from '../middleware/fetch_middleware'

class Charts extends Component {
  constructor(props) {
    super(props)
    console.log('charts', props)
    props.requestInitialData()
  }

  render() {
    const { data, schema } = this.props
    const { request, fetchAction, reset } = this.props
    return (
      <div
        className="hello"
        style={{ overflow: 'auto', position: 'relative', top: 0, bottom: 0 }}
      >
        {JSON.stringify(schema, null, 2)}
        <hr />
        {JSON.stringify(data, null, 2)}
      </div>
    )
  }
}

const mapStateToProps = state => ({
  ...state
})

const mapDispatchToProps = dispatch => ({
  requestInitialData: () => dispatch(requestInitialData()),
  request: data => () => dispatch(perform('chunks', 'request', data)),
  fetchAction: uri => () => dispatch(fetchAction(uri)),
  reset: () => () =>
    dispatch({ type: 'DATA', payload: { schema: {}, data: [] } })
})

export default connect(mapStateToProps, mapDispatchToProps)(Charts)
