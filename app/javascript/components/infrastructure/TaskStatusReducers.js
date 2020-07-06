import {
  START_TASK,
  END_TASK
} from './StatusActions'

export function tasks(state = {}, action) {
  const newState = Object.assign( {}, state );
  const taskName = action.task || 'loading';

  switch (action.type) {
    case START_TASK:
      newState[ taskName ] = (newState[ taskName] || 0) + 1;
      return newState;
    case END_TASK:
      newState[ taskName ] = Math.max(0, (newState[ taskName] || 0) - 1);
      return newState;
    default:
      return state;
  }
}
