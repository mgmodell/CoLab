import {
  START_TASK,
  END_TASK
} from './StatusActions'

interface TaskStatusRootState {
  [taskName: string] : string;
}

//export const useTypedTaskStatusSelector: TypedUseSelectorHook<TaskStatusRootState> = useSelector
const initialState: TaskStatusRootState = {}

export function tasks(state: TaskStatusRootState = {}, action) {
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
