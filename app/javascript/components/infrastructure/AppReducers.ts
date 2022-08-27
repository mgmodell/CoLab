import { useSelector, TypedUseSelectorHook } from 'react-redux'

import statusReducer from './StatusSlice';
import contextReducer from './ContextSlice';
import profileReducer from './ProfileSlice';

const appStatus = {
  status: statusReducer,
  context: contextReducer,
  profile: profileReducer
}

export default appStatus;
export type RootState = ReturnType<typeof appStatus>

export const useTypedSelector: TypedUseSelectorHook<RootState> = useSelector