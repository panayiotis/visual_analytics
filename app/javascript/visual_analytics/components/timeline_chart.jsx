import React from 'react'
import { connect } from 'react-redux'
import findIndex from 'lodash/findIndex'
import * as d3 from 'd3'
import { barChart } from 'dc'
import colorbrewer from 'colorbrewer'
import { Segment } from 'semantic-ui-react'
import { crossfilterFilter } from '../actions/crossfilter'
import { handleDrill } from '../actions/engine'
import { dateToQuarter } from '../helpers/dates'

class TimelineChart extends React.Component {
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

    const chart = barChart(this.el)

    const timeDomain = group
      .all()
      .map(g => new Date(g.key))
      .reduce(
        (acc, val) => {
          let m = val
          if (m < acc[0]) {
            acc[0] = m
          }
          if (m > acc[1]) {
            acc[1] = m
          }
          return acc
        },
        [new Date(), 0]
      )

    chart
      .height(() => 200)
      .width(() => d3.select(this.el.offsetWidth))

      .margins({
        top: 10,
        right: 10,
        bottom: 30,
        left: 60
      })
      .dimension(dimension)
      .group(group)
      .alwaysUseRounding(true)
      .barPadding(0.1)
      .centerBar(true)
      .elasticX(true)
      .elasticY(true)
      .renderHorizontalGridLines(true)
      .transitionDuration(500)

    switch (level) {
      case 'year':
        chart
          .round(date => d3.time.month.offset(d3.time.year(date), 6))
          .x(d3.time.scale().domain(timeDomain))
          .xAxisLabel('x axis label')
          .xAxisPadding(6)
          .xAxisPaddingUnit('month')
          .xUnits(d3.time.years)
          .yAxisLabel('y axis label')
        chart.xAxis().ticks(d3.time.years)
        break
      case 'quarter':
        chart
          .round(date => d3.time.day.offset(dateToQuarter(date), 50))
          .x(d3.time.scale().domain(timeDomain))
          .xAxisLabel('x axis label')
          .xAxisPadding(60)
          .xAxisPaddingUnit('day')
          .xUnits((start, stop) => d3.time.months(start, stop, 3))
          .yAxisLabel('y axis label')
        chart.xAxis().ticks(d3.time.months, 3)
        break
      default:
        chart
          .round(date => d3.time.day.offset(d3.time.month(date), 15))
          .x(d3.time.scale().domain(timeDomain))
          .xAxisLabel('x axis label')
          .xAxisPadding(15)
          .xAxisPaddingUnit('day')
          .xUnits(d3.time.months)
          .yAxisLabel('y axis label')
        chart.xAxis().ticks(d3.time.months, 3)
    }

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

    window.timelineChart = chart

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

export default connect(mapStateToProps, mapDispatchToProps)(TimelineChart)
