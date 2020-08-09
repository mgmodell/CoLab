import { useSelector, TypedUseSelectorHook } from 'react-redux'

import { combineReducers } from 'redux'
import {tasks} from './TaskStatusReducers';
import {dirtyState} from './DirtyReducers';
import {statusMessages} from './MessageReducers';
import {login} from './AuthenticationReducers';


const appStatus = combineReducers({
  tasks: tasks,
  dirtyState: dirtyState,
  statusMessages: statusMessages,
  login: login,

})

export default appStatus;
export type RootState = ReturnType<typeof appStatus>

export const useTypedSelector: TypedUseSelectorHook<RootState> = useSelector