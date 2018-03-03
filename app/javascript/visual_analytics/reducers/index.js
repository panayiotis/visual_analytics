import { combineReducers } from 'redux'

import connectivity from './connectivity'
import notebook from './notebook'
import engine from './engine'
import data from './data'
import schema from './schema'
import layout from './layout'

const reducer = combineReducers({
  connectivity,
  data,
  engine,
  notebook,
  layout,
  schema
})

export default reducer
