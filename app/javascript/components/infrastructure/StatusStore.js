import { createStore, createSubscriber, createHook } from "react-sweet-state";

const Store = createStore({
  initialState: {
    working: 0,
    taskStatus: {},
    statusMessages: []
  },
  actions: {
    startTask: ( task ) => ({ setState, getState }) => {
      const taskName = task || 'loading';
      const taskStatus = getState( ).taskStatus;

      taskStatus[ taskName ] = ( taskStatus[ taskName ] || 0 ) + 1;
      const workingCount = Object.values( taskStatus ).reduce((accumulator, currentValue) => { accumulator + currentValue})

      setState({
        taskStatus: taskStatus,
        working: workingCount || 0
      })
    },
    endTask: ( task ) => ({ setState, getState }) => {
      const taskName = task || 'loading';
      const taskStatus = getState( ).taskStatus;

      taskStatus[ taskName ] = Math.max( 0, ( taskStatus[ taskName ] || 0 ) - 1 );
      const workingCount = Object.values( taskStatus ).reduce((accumulator, currentValue) => {accumulator + currentValue})

      setState({
        taskStatus: taskStatus,
        working: workingCount || 0
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