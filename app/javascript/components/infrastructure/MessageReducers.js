import {
  ADD_MESSAGE,
  ACKNOWLEDGE_MSG
} from './StatusActions'

export function statusMessages(state = [], action) {
  switch (action.type) {
    case ADD_MESSAGE:
      return [
          ...state,
          {
            text: action.text,
            priority: action.priority,
            msgTime: action.msgTime,
            dismissed: false
          }
        ];
    case ACKNOWLEDGE_MSG:
      return state.map((message, index) => {
        if (index === action.index) {
          return Object.assign({}, message, {
            dismissed: true
          })
        }
        return message;
      })
    default:
      return state
  }
}
