import { ContextRootState } from './ContextReducers';
import {
  START_TASK,
  END_TASK,
  ADD_MESSAGE,
  ACKNOWLEDGE_MSG,
  Priorities
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
  ]
}

const initialState : StatusRootState = {
  tasks: {},
  messages: []
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
    case ADD_MESSAGE:
      newState.messages.push(
          {
            text: action.text,
            priority: action.priority,
            msgTime: action.msgTime,
            dismissed: false
          }
      )
      return newState;
    case ACKNOWLEDGE_MSG:
      newState.messages.map ((message, index) => {
        if (index === action.index) {
          return Object.assign({}, message, {
            dismissed: true
          })
        }
        return message;
      })
      return newState;
    default:
      return state;
  }
}
