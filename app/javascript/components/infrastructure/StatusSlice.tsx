import { createSlice } from "@reduxjs/toolkit";

export enum Priorities  {
  ERROR = "error",
  INFO = "info",
  WARNING = "warning"
};

//const initialState : StatusRootState = {
const initialState = {
  tasks: {},
  messages: [],
  dirtyStatus: {}
};

// Slice
const statusSlice = createSlice({
  name: "status",
  initialState: initialState,
  reducers: {
    startTask:{
      reducer (state, action) {
        state[action.payload] = (state[action.payload] || 0) + 1;
      },
      prepare(taskName?: string) {
        const localTaskName = taskName || 'default';
        return {
          payload: localTaskName,
          meta: null,
          error: null
        };
      }

    },
    endTask(state, action) {
        state[action.payload] = Math.max(0, state[action.payload] || 0) - 1;
    },
    setDirty (state, action) {
        state.dirtyStatus[action.payload] = true;
    },
    setClean (state, action) {
        state.dirtyStatus[action.payload] = false;
    },
    addMessage: {
      reducer (state, action) {
        state.messages.push(action.payload);
      },
      prepare(text: string, msgTime: Date, priority: Priorities ) {
        return {
          payload: {
            text: text,
            priority: priority,
            msgTime: msgTime.toJSON(),
            dismissed: false
          },
          meta: null,
          error: null
        };
      }
    },
    acknowledgeMsg (state, action) {
        state.messages.map((message, index) => {
          if (index === action.payload) {
            message.dismissed = true;
          }
        });
    },
  }
});

const { actions, reducer } = statusSlice;
export const {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  acknowledgeMsg,
} = actions;
export default reducer;
