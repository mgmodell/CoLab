import { ContextRootState } from './ContextReducers';
import {
  START_TASK,
  END_TASK,
  ADD_MESSAGE,
  ACKNOWLEDGE_MSG,
  Priorities,
  SET_DIRTY,
  SET_CLEAN
} from './StatusActions'

interface StatusRootState {
  tasks: {
    [taskName: string] : string;
  },
  messages: [
    {
      priority: Priorities,
      text: String,
      date: Date,
      acknowledged: boolean
    }
  ],
  dirtyStatus: {
    [taskName: string] : boolean;
  }
}

const initialState : StatusRootState = {
  tasks: {},
  messages: [],
  dirtyStatus: { }
}


export function status(state: StatusRootState = initialState, action) {
  const newState = Object.assign( {}, state );
  const taskName = action.task || 'loading';

  switch (action.type) {
    case START_TASK:
      newState[ taskName ] = (newState[ taskName] || 0) + 1;
      return newState;
    case END_TASK:
      newState[ taskName ] = Math.max(0, (newState[ taskName] || 0) - 1);
      return newState;
    case SET_DIRTY: {
      const dirtyStatus = Object.assign( {}, newState.dirtyStatus );
      dirtyStatus[ action.task ] = true;
      newState.dirtyStatus = dirtyStatus;
      return newState;
    }
    case SET_CLEAN: {
      const dirtyStatus = Object.assign( {}, newState.dirtyStatus );
      dirtyStatus[ action.task ] = false;
      newState.dirtyStatus = dirtyStatus;
      return newState;
    }
    case ADD_MESSAGE: {
      const newMessages = newState.messages.map( (x) => x );
      newMessages.push(
          {
            text: action.text,
            priority: action.priority,
            msgTime: action.msgTime,
            dismissed: false
          }
      );
      newState.messages = newMessages;
      return newState;

    }
    case ACKNOWLEDGE_MSG: {
      const newMessages = newState.messages.map ((message, index) => {
        if (index === action.index) {
          return Object.assign({}, message, {
            dismissed: true
          })
        }
        return message;
      })
      newState.messages = newMessages;
      return newState;

    }
    default:
      return state;
  }
}
