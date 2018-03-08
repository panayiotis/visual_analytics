import { combineReducers } from 'redux'

import connectivity from './connectivity'
import notebook from './notebook'
import engine from './engine'
import data from './data'
import schema from './schema'
import layout from './layout'
import crossfilter from './crossfilter'
import geojson from './geojson'

const reducer = combineReducers({
  connectivity,
  crossfilter,
  data,
  engine,
  geojson,
  layout,
  notebook,
  schema
})

export default reducer
