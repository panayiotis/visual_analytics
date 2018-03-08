import React, { Component } from 'react'
import { render } from 'react-dom'
import MapGL from 'react-map-gl'
import DeckGLOverlay from './deckgl-overlay.jsx'
import * as d3 from 'd3'
import { connect } from 'react-redux'

import { fetchGeojson } from '../actions/geojson'

// Set your mapbox token here
const MAPBOX_TOKEN = process.env.MapboxAccessToken // eslint-disable-line

class Map extends Component {
  constructor(props) {
    super(props)
    this.state = {
      viewport: {
        ...DeckGLOverlay.defaultViewport,
        width: 500,
        height: 500
      }
    }
    props.fetchGeojson()
  }

  componentDidMount() {
    window.addEventListener('resize', this._resize.bind(this))
    this._resize()
  }

  _resize() {
    this._onViewportChange({
      width: window.innerWidth,
      height: window.innerHeight
    })
  }

  _onViewportChange(viewport) {
    this.setState({
      viewport: { ...this.state.viewport, ...viewport }
    })
  }

  render() {
    const { viewport } = this.state
    const { geojson, elevations } = this.props

    return (
      <MapGL
        {...viewport}
        onViewportChange={this._onViewportChange.bind(this)}
        mapboxApiAccessToken={MAPBOX_TOKEN}
        mapStyle="mapbox://styles/mapbox/dark-v9"
      >
        <DeckGLOverlay
          viewport={viewport}
          data={geojson}
          onHover={info => console.log('Hovered:', info)}
          onClick={info => console.log('Clicked:', info)}
          elevations={elevations}
        />
      </MapGL>
    )
  }
}
const mapStateToProps = state => ({ geojson: state.geojson })

const mapDispatchToProps = dispatch => ({
  fetchGeojson: () => dispatch(fetchGeojson())
})

export default connect(mapStateToProps, mapDispatchToProps)(Map)
