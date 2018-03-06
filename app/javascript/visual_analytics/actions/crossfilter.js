import ActionCable from 'actioncable'
import { createAction } from 'redux-actions'
import dc from 'dc'

import { CROSSFILTER_FILTER, CROSSFILTER } from '../actions/action_types'
export const crossfilterFilter = createAction(CROSSFILTER_FILTER)
export const crossfilterAction = createAction(CROSSFILTER)
export const handleCrossfilterReset = () => {
  return function(dispatch) {
    dc.filterAll()
    dc.redrawAll()
  }
}
