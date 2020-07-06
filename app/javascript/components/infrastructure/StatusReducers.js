import { combineReducers } from 'redux'
import {tasks} from './TaskStatusReducers';
import {dirtyState} from './DirtyReducers';
import {statusMessages} from './MessageReducers';

const appStatus = combineReducers({
  tasks,
  dirtyState,
  statusMessages
})

export default appStatus;