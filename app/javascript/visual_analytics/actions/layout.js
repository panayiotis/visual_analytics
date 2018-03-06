import { createAction } from 'redux-actions'

import { SIDEBAR, LAYOUT } from '../actions/action_types'

export const sidebarToggle = createAction(SIDEBAR)
export const layoutAction = createAction(LAYOUT)
export const chartsPaneResize = () => {
  return function(dispatch, getState) {
    const event = new Event('chartsPaneResize')
    dispatchEvent(event)
  }
}
