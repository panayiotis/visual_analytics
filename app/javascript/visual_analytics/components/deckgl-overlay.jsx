import React, { Component } from 'react'
import DeckGL, { GeoJsonLayer } from 'deck.gl'
import * as d3 from 'd3'
import colorbrewer from 'colorbrewer'

const LIGHT_SETTINGS = {
  //lightsPosition: [-0.144528, 49.739968, 8000, -3.807751, 54.104682, 8000],
  lightsPosition: [-1, 50, 100000, -7, 54, 80000],
  ambientRatio: 0.4,
  diffuseRatio: 0.6,
  specularRatio: 0.2,
  lightsStrength: [0.6, 0.0, 0.8, 0],
  numberOfLights: 2
}

export default class DeckGLOverlay extends Component {
  static get defaultViewport() {
    return {
      latitude: 53.4,
      longitude: -2,
      zoom: 6,
      maxZoom: 12,
      pitch: 45,
      bearing: 0
    }
  }

  render() {
    const { viewport, data, elevations } = this.props

    if (!data) {
      return null
    }
    const layer = new GeoJsonLayer({
      id: 'geojson',
      data,
      elevationScale: 1,
      opacity: 0.8,
      stroked: true,
      filled: true,
      extruded: true,
      wireframe: true,
      fp64: false,
      lightSettings: LIGHT_SETTINGS,
      //pickable: Boolean(this.props.onHover),
      //onHover: this.props.onHover,
      onClick: this.props.onClick
    })

    return <DeckGL {...viewport} layers={[layer]} />
  }
}
