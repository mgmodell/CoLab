import {useSelector, TypedUseSelectorHook} from 'react-redux';

import {
  SET_DIRTY,
  SET_CLEAN
} from './StatusActions'

interface DirtyRootState {
  [taskName: string] : boolean;
}

const initialState: DirtyRootState = {}

// export const useTypedDirtySelector: TypedUseSelectorHook<DirtyRootState> = useSelector

export function dirtyState(state: DirtyRootState = {}, action) {
  const newState = Object.assign( {}, state );

  switch (action.type) {
    case SET_DIRTY:
      newState[ action.task ] = true;
      return newState;
    case SET_CLEAN:
      newState[ action.task ] = false;
      return newState;
    default:
      return state;
  }
}
