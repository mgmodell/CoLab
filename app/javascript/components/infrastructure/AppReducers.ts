import { useSelector, TypedUseSelectorHook } from 'react-redux'

import { combineReducers } from 'redux'
import {status} from './StatusReducers';
import {dirtyState} from './DirtyReducers';
import {context} from './ContextReducers';
import {profile} from './ProfileReducers';

const appStatus = combineReducers({
  status: status,
  dirtyState: dirtyState,
  context: context,
  profile: profile
})

export default appStatus;
export type RootState = ReturnType<typeof appStatus>

export const useTypedSelector: TypedUseSelectorHook<RootState> = useSelector