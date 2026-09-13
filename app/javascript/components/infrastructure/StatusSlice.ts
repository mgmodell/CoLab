import { useEffect, useRef, useCallback } from "react";
import { useDispatch, useSelector } from "react-redux";
import { data, useLocation } from "react-router";
import { createSlice } from "@reduxjs/toolkit";
import { Root } from "react-dom/client";
import { RootState } from "./AppReducers";

export enum Priorities {
  ERROR = "error",
  INFO = "info",
  WARNING = "warning",
}

export enum DIRTY_STATUS {
  CLEAN = false,
  DIRTY = true,
  NONE = null,
}

//const initialState : StatusRootState = {
const initialState = {
  tasks: {},
  messages: [],
  dirtyStatus: {},
};

// Slice
const statusSlice = createSlice({
  name: "status",
  initialState: initialState,
  reducers: {
    startTask: {
      reducer(state, action) {
        state.tasks[action.payload] = (state.tasks[action.payload] || 0) + 1;
      },
      prepare(taskName?: string) {
        const localTaskName = taskName || "default";
        return {
          payload: localTaskName,
          meta: null,
          error: null,
        };
      },
    },
    endTask: {
      reducer(state, action) {
        state.tasks[action.payload] =
          Math.max(0, state.tasks[action.payload] || 0) - 1;
      },
      prepare(taskName?: string) {
        const localTaskName = taskName || "default";
        return {
          payload: localTaskName,
          meta: null,
          error: null,
        };
      },
    },
    setDirty(state, action) {
      state.dirtyStatus[action.payload] = true;
    },
    setClean(state, action) {
      state.dirtyStatus[action.payload] = false;
    },
    unsetDirty(state, action) {
      delete state.dirtyStatus[action.payload];
    },
    addMessage: {
      reducer(state, action) {
        state.messages.push(action.payload);
      },
      prepare(text: string, msgTime: Date, priority: Priorities) {
        return {
          payload: {
            text: text,
            priority: priority,
            msgTime: msgTime.toJSON(),
            dismissed: false,
          },
          meta: null,
          error: null,
        };
      },
    },
    acknowledgeMsg(state, action) {
      state.messages.map((message, index) => {
        if (index === action.payload) {
          message.dismissed = true;
        }
      });
    },
  },
});

const { actions, reducer } = statusSlice;
export const {
  startTask,
  endTask,
  setDirty,
  setClean,
  unsetDirty,
  addMessage,
  acknowledgeMsg,
} = actions;

export function useDirtyStatus(
  initialDirty: DIRTY_STATUS = DIRTY_STATUS.CLEAN,
  flagKey: string | null = null,
) {
  const dispatch = useDispatch();
  const location = useLocation();
  const hasInitialized = useRef(false);

  const panels = location.pathname.split("/") || [];
  const dataPanel =
    flagKey || (Number(panels.at(-1)) > 0 ? panels.at(-2) : panels.at(-1));

  const isDirty = useSelector((state: RootState) => {
    const status = state.status.dirtyStatus as Record<string, boolean>;

    console.log(
      `status for ${dataPanel || "default"}`,
      status[dataPanel || ""],
    );

    switch (status[dataPanel || ""]) {
      case null:
      case undefined:
        return DIRTY_STATUS.NONE;
      case 0:
      case false:
        return DIRTY_STATUS.CLEAN;
      default:
        return DIRTY_STATUS.DIRTY;
    }
  });

  useEffect(() => {
    if (!hasInitialized.current && dataPanel) {
      hasInitialized.current = true;
      if (initialDirty === DIRTY_STATUS.DIRTY) {
        dispatch(setDirty(dataPanel));
      } else if (initialDirty === DIRTY_STATUS.CLEAN) {
        dispatch(setClean(dataPanel));
      } else if (initialDirty === DIRTY_STATUS.NONE) {
        dispatch(unsetDirty(dataPanel));
        // do nothing
      }
    }
  }, [initialDirty, dataPanel, dispatch]);

  const setDirtyStatus = useCallback(
    (status: DIRTY_STATUS.CLEAN | DIRTY_STATUS.DIRTY) => {
      if (!dataPanel) return;

      if (status === DIRTY_STATUS.DIRTY) {
        dispatch(setDirty(dataPanel));
      } else if (status === DIRTY_STATUS.CLEAN) {
        dispatch(setClean(dataPanel));
      }
    },
    [dispatch, dataPanel],
  );

  return [isDirty, setDirtyStatus] as const;
}

export default reducer;
