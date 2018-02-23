import React, { Component } from 'react'
import { connect } from 'react-redux'
import { helloAction } from '../actions/hello'

class App extends Component {
  constructor(props) {
    super(props)
    console.log(props)
    setInterval(() => {
      console.log('dispatch action hello')
      props.helloAction(Date.now())
    }, 2000)
  }

  componentDidMount() {
    console.log('app mounted')
  }

  componentWillUnmount() {
    console.log('app unmounted')
  }

  render() {
    return <h1>App {this.props.hello} </h1>
  }
}

const mapStateToProps = state => ({
  ...state
})

const mapDispatchToProps = dispatch => ({
  helloAction: payload => dispatch(helloAction(payload))
})

export default connect(mapStateToProps, mapDispatchToProps)(App)
