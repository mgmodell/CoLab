import { useSelector, TypedUseSelectorHook } from 'react-redux';

import statusReducer from './StatusSlice';
import contextReducer from './ContextSlice';
import profileReducer from './ProfileSlice';
import { configureStore } from '@reduxjs/toolkit';

const appStatus = configureStore({
  reducer: {
    status: statusReducer,
    context: contextReducer,
    profile: profileReducer,
  },
});

export default appStatus;
export type RootState = ReturnType<typeof appStatus.getState>;

export const useTypedSelector: TypedUseSelectorHook<RootState> = useSelector;
