import { createStore, createSubscriber, createHook } from "react-sweet-state";

const Store = createStore({
  initialState: {
    working: true,
    statusMessages: []
  },
  actions: {
    setWorking: ( working ) => ({ setState, getState }) => {
      setState({
        working: working
      })
    },
    addMessage: (text, priority) => ({setState, getState}) => {
      const statusMessages = getState().statusMessages;
      statusMessages.push({
        priority: priority,
        text: text,
        dismissed: false
      })
      setState({
        statusMessages: statusMessages
      })

    },
    acknowledge: ( index ) => ({setState, getState }) =>{
      const statusMessages = getState().statusMessages;
      statusMessages[ index ].dismissed = true;
      setState({
        statusMessages: statusMessages
      })

    }


  },
  name: "statusMessages"
});

export const StatusStoreSubscriber = createSubscriber(Store);
// or
export const useStatusStore = createHook(Store);
