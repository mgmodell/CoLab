import { useSelector, TypedUseSelectorHook } from 'react-redux'

import { combineReducers } from 'redux'
import {tasks} from './TaskStatusReducers';
import {dirtyState} from './DirtyReducers';
import {statusMessages} from './MessageReducers';
import {login} from './AuthenticationReducers';
import {resources} from './ResourceReducers';


const appStatus = combineReducers({
  tasks: tasks,
  dirtyState: dirtyState,
  statusMessages: statusMessages,
  login: login,
  resources: resources,

})

export default appStatus;
export type RootState = ReturnType<typeof appStatus>

export const useTypedSelector: TypedUseSelectorHook<RootState> = useSelector