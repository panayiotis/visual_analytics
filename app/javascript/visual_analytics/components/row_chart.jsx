import React from 'react'
import { connect } from 'react-redux'

import * as d3 from 'd3'
import { rowChart } from 'dc'
import colorbrewer from 'colorbrewer'
import { Segment } from 'semantic-ui-react'
import findIndex from 'lodash/findIndex'
import { crossfilterFilter } from '../actions/crossfilter'
import { handleDrill } from '../actions/engine'

class RowChart extends React.Component {
  constructor(props) {
    super(props)
    this.el = null
  }
  componentDidMount() {
    this.postRender()
  }
  componentDidUpdate() {
    this.postRender()
  }
  postRender() {
    const { dimension, group, name, level, levels, drill } = this.props
    const { handleDrill, crossfilterFilter } = this.props
    const size = group.size()
    const hasLevels = levels.length > 0
    const index = findIndex(levels, i => i === level)
    const hasDrill = index >= 0 && index < levels.length - 1
    const colors = d3.scale.quantize().range(colorbrewer.YlGnBu[9])

    const chart = rowChart(this.el)

    chart
      .height(() => size * 25 + 45)
      .width(() => d3.select(this.el.offsetWidth))
      .margins({
        top: 0,
        right: 10,
        bottom: 20,
        left: hasDrill ? 20 : 5
      })
      .dimension(dimension)
      .group(group)
      .colorAccessor((d, i) => d.value)
      .elasticX(true)

    chart.on('filtered', (chart, filter) => {
      crossfilterFilter({
        filters: { [name]: chart.filters() },
        sum: App.xf
          .groupAll()
          .reduceSum(d => d.count)
          .value(),
        count: App.xf
          .groupAll()
          .reduceCount()
          .value()
      })
    })

    if (hasDrill) {
      chart.on('postRender', chart => {
        var barHeight
        barHeight = chart.select('g.row rect').attr('height')
        return chart
          .selectAll('g.row')
          .append('g')
          .classed('drill-down', true)
          .attr('transform', d => `translate(-11, ${barHeight / 2})`)
          .append('text')
          .classed('drill-down', true)
          .attr('x', -7)
          .attr('y', 7)
          .text('⥁')
          .on('click', d => handleDrill(name, d.key))
      })
    }
    window.rowChart = chart

    chart.render()
    window.addEventListener('chartsPaneResize', event => chart.redraw())
  }

  render() {
    return (
      <div
        ref={el => {
          this.el = el
        }}
      />
    )
  }
}

const mapStateToProps = state => ({ schema: state.schema })

const mapDispatchToProps = dispatch => ({
  handleDrill: (name, value) => dispatch(handleDrill(name, value)),
  crossfilterFilter: data => dispatch(crossfilterFilter(data))
})

export default connect(mapStateToProps, mapDispatchToProps)(RowChart)
