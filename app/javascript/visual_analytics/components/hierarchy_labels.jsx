import React, { Component } from 'react'
import { Label, Segment, Icon } from 'semantic-ui-react'
import findIndex from 'lodash/findIndex'
import { connect } from 'react-redux'
import { handleLevel } from '../actions/engine'

class HierarchyLabels extends Component {
  render() {
    const { name, level, levels, drill } = this.props
    const { handleLevel } = this.props

    if (levels.length == 0) {
      return null
    }

    const levelsFields = levels.map(l => {
      const color = l === level ? 'blue' : 'yellow'
      const index = findIndex(levels, i => i === l)
      const drillValue = drill[index]

      return (
        <Label
          as="a"
          key={l}
          color={color}
          onClick={handleLevel(name, l)}
          image
        >
          {l}
          {drillValue && (
            <Label.Detail>
              {drillValue} <Icon link name="delete" />{' '}
            </Label.Detail>
          )}
        </Label>
      )
    })
    return (
      <Segment basic>
        <Label.Group>{levelsFields}</Label.Group>
      </Segment>
    )
  }
}

const mapStateToProps = state => ({})

const mapDispatchToProps = dispatch => ({
  handleLevel: (name, nextLevel) => () => dispatch(handleLevel(name, nextLevel))
})

export default connect(mapStateToProps, mapDispatchToProps)(HierarchyLabels)
