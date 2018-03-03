import { createAction } from 'redux-actions'
import get from 'lodash/get'
export const fetchAction = createAction('FETCH', uri => ({
  fetch_path: uri
}))

const fetchMiddleware = store => next => action => {
  if (!get(action, 'payload.fetch_path', false)) {
    return next(action)
  }
  console.log(action)
  let dispatch = store.dispatch
  let config = action.payload

  const path = config.fetch_path

  fetch(path)
    .then(response => response.json())
    .then(json => {
      next({ type: action.type, payload: json })
    })
}

export default fetchMiddleware
