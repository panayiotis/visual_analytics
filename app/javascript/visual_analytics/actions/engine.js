import ActionCable from 'actioncable'
import { createAction } from 'redux-actions'
import cloneDeep from 'lodash/cloneDeep'
import findIndex from 'lodash/findIndex'
import { perform } from '../actions/connectivity'
import { md as digest } from 'node-forge'

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
    dispatch(
      perform('chunks', 'request', {
        ...schema,
        key: schemaToHash(schema)
      })
    )
  }
}

export const handleLevel = (name, nextLevel) => {
  return function(dispatch, getState) {
    dispatch(engineLevel({ name, nextLevel }))

    const schema = cloneDeep(getState().schema)
    const { level, levels, drill } = schema.fields[name]

    const index = findIndex(levels, i => i === level)
    const nextIndex = findIndex(levels, i => i === nextLevel)

    for (let i = nextIndex; i < levels.length; i++) {
      schema.fields[name].drill[i] = null
    }
    schema.fields[name].level = levels[nextIndex]
    dispatch(
      perform('chunks', 'request', {
        ...schema,
        key: schemaToHash(schema)
      })
    )
  }
}

/**
 * Create hash for a schema.
 * The resulted hash has to be *identical* to the one produced by the
 * Spark Scala adapter.
 *
 * @param {object} schema
 * @return {string} hash - hash of the schema.
 */
export const schemaToHash = ({ fields, view }) => {
  const json = JSON.stringify(
    Object.values(fields).sort((a, b) => {
      if (a.name < b.name) {
        return -1
      }
      return 1
    })
  )
  // console.debug(json)
  const sha256 = digest.sha256.create()
  sha256.update(json)
  const key = sha256
    .digest()
    .toHex()
    .slice(0, 5)
  return view + key
}
