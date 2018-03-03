import React, { Component } from 'react'
import { connect } from 'react-redux'
import Charts from './charts'
import Layout from './layout'
import { establish } from '../actions/connectivity'

class App extends Component {
  constructor(props) {
    super(props)
  }

  componentDidMount() {
    console.log('app mounted')
  }

  componentWillUnmount() {
    console.log('app unmounted')
  }

  render() {
    return <Layout />
  }
}

const mapStateToProps = state => ({
  ...state
})

const mapDispatchToProps = dispatch => ({
  establish: dispatch(establish())
})

export default connect(mapStateToProps, mapDispatchToProps)(App)
