import { createSlice } from "@reduxjs/toolkit";

export const Priorities = {
  ERROR: "error",
  INFO: "info",
  WARNING: "warning"
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
  initialState,
  reducers: {
    startTask: {
      reducer: (state, action) => {
        state[action.payload] = (state[action.payload] || 0) + 1;
      }
    },
    endTask: {
      reducer: (state, action) => {
        state[action.payload] = Math.max(0, state[action.payload] || 0) - 1;
      }
    },
    setDirty: {
      reducer: (state, action) => {
        state.dirtyStatus[action.payload] = true;
      }
    },
    setClean: {
      reducer: (state, action) => {
        state.dirtyStatus[action.payload] = false;
      }
    },
    addMessage: {
      reducer: (state, action) => {
        state.messages.push(action.payload);
      },
      prepare: (text, msgTime, priority) => {
        return {
          payload: {
            text: text,
            priority: priority,
            msgTime: msgTime.toJSON(),
            dismissed: false
          }
        };
      }
    },
    acknowledgeMsg: {
      reducer: (state, action) => {
        state.messages.map((message, index) => {
          if (index === action.payload) {
            message.dismissed = true;
          }
        });
      }
    },
    cleanUpMsgs: {
      reducer: (state, action) => {
        const curTime = Date.now();
        state.messages.map((message, index) => {
          if (new Date(message.msgTime) < curTime - 60000) {
            message.dismissed = true;
          }
        });
      }
    }
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
  cleanUpMsgs
} = actions;
export default reducer;
