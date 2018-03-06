import { createAction } from 'redux-actions'
import get from 'lodash/get'

const dataTransformMiddleware = store => next => action => {
  if (!action || action.type != 'DATA') {
    return next(action)
  }
  console.debug('data transform middleware applied')
  action.payload.data.forEach(d => {
    d.date = new Date(d.date)
  })
  next(action)
}

export default dataTransformMiddleware
