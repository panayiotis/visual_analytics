import React, { Component } from 'react'
import PropTypes from 'prop-types'
import {
  Segment,
  Sidebar,
  Header,
  Image,
  Button,
  Menu,
  Icon
} from 'semantic-ui-react'
import { connect } from 'react-redux'
//import { toggleSidebar } from '../actions'

class CustomSidebar extends Component {
  render() {
    const { sidebar } = this.props
    return (
      <Sidebar
        as={Menu}
        animation="push"
        width="thin"
        visible={sidebar}
        icon="labeled"
        vertical
        inverted
      >
        <Menu.Item name="notebooks" href="/notebooks" target="_self">
          <Icon name="book" />
          Notebooks
        </Menu.Item>
      </Sidebar>
    )
  }
}

const mapStateToProps = state => ({ ...state.layout })

const mapDispatchToProps = dispatch => ({})

export default connect(mapStateToProps, mapDispatchToProps)(CustomSidebar)
