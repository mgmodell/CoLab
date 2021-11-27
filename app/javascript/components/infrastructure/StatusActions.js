export const START_TASK = 'START_TASK';
export const END_TASK = 'END_TASK';
export const SET_DIRTY = 'SET_DIRTY';
export const SET_CLEAN = 'SET_CLEAN';
export const ADD_MESSAGE = 'ADD_MESSAGE';
export const ACKNOWLEDGE_MSG = 'ACKNOWLEDGE_MSG';

export const Priorities = {
  ERROR: 'error',
  INFO: 'info',
  WARNING: 'warning'
}

export function startTask(task) {
  return { type: START_TASK, task }
}

export function endTask(task) {
  return { type: END_TASK, task }
}

export function setDirty(task) {
  return { type: SET_DIRTY, task }
}

export function setClean(task) {
  return { type: SET_CLEAN, task }
}

export function addMessage(text, msgTime, priority) {
  return { type: ADD_MESSAGE, text, msgTime, priority }
}

export function acknowledgeMsg(index) {
  return { type: ACKNOWLEDGE_MSG, index }
}
