import ActionCable from 'actioncable'
import { createAction } from 'redux-actions'
import cloneDeep from 'lodash/cloneDeep'
import findIndex from 'lodash/findIndex'
import { perform } from '../actions/connectivity'

import {
  ENGINE_COMPUTATION,
  ENGINE_DRILL,
  ENGINE_LEVEL
} from '../actions/action_types'

export const engineDrill = createAction(ENGINE_DRILL)
export const engineLevel = createAction(ENGINE_LEVEL)

export const handleDrill = (name, value) => {
  return function(dispatch, getState) {
    dispatch(engineDrill({ name, value }))

    const schema = cloneDeep(getState().schema)
    const { level, levels, drill } = schema.fields[name]
    const index = findIndex(levels, i => i === level)

    schema.fields[name].drill[index] = value
    schema.fields[name].level = levels[index + 1]
    dispatch(perform('chunks', 'request', { schema: schema }))
  }
}

export const handleLevel = (name, nextLevel) => {
  return function(dispatch, getState) {
    dispatch(engineLevel({ name, nextLevel }))

    const schema = cloneDeep(getState().schema)
    const { level, levels, drill } = schema.fields[name]

    const index = findIndex(levels, i => i === level)
    const nextIndex = findIndex(levels, i => i === nextLevel)

    for (let i = nextIndex; i <= levels.length; i++) {
      schema.fields[name].drill[i] = null
    }
    schema.fields[name].level = levels[nextIndex]
    dispatch(perform('chunks', 'request', { schema: schema }))
  }
}
