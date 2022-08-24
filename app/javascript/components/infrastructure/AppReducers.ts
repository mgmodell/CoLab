import { useSelector, TypedUseSelectorHook } from 'react-redux'

import { combineReducers } from 'redux'
import statusReducer from './StatusActions';
import {context} from './ContextReducers';
import {profile} from './ProfileReducers';

const appStatus = combineReducers({
  status: statusReducer,
  context: context,
  profile: profile
})

export default appStatus;
export type RootState = ReturnType<typeof appStatus>

export const useTypedSelector: TypedUseSelectorHook<RootState> = useSelector