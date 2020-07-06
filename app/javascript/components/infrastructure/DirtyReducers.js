import {
  SET_DIRTY,
  SET_CLEAN
} from './StatusActions'

export function dirtyState(state = {}, action) {
  const newState = Object.assign( {}, state );

  switch (action.type) {
    case SET_DIRTY:
      newState[ action.task ] = true;
      return newState;
    case SET_CLEAN:
      newState[ action.task ] = false;
      return newState;
    default:
      return state;
  }
}
