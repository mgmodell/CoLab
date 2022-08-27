import { useSelector, TypedUseSelectorHook } from 'react-redux'

import { combineReducers } from 'redux'
import statusReducer from './StatusActions';
import contextReducer from './ContextActions';
import profileReducer from './ProfileActions';

const appStatus = combineReducers({
  status: statusReducer,
  context: contextReducer,
  profile: profileReducer
})

export default appStatus;
export type RootState = ReturnType<typeof appStatus>

export const useTypedSelector: TypedUseSelectorHook<RootState> = useSelector