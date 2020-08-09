import {useSelector, TypedUseSelectorHook } from 'react-redux';
import {
  ADD_MESSAGE,
  ACKNOWLEDGE_MSG,
  Priorities
} from './StatusActions'
import { string } from 'prop-types';


interface Message{
      text: string;
      priority: Priorities;
      msgTime: Date;
      dismissed: Boolean;

}
interface MessagesRootState {
  messages: Message[ ];
  
}

const initialState: MessagesRootState = {messages: [ ]}

export const useTypedMessageSelector: TypedUseSelectorHook<MessagesRootState> = useSelector

export function statusMessages( state: MessagesRootState = initialState, action) {
  const newState = Object.assign( {}, state )

  switch (action.type) {
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
      return state
  }
}
