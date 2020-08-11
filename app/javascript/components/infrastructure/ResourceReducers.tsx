import {useSelector, TypedUseSelectorHook } from 'react-redux';
import {
  SET_ENDPOINT_URL,
  SET_ENDPOINTS,
  SET_LOOKUP_URL,
  SET_LOOKUPS
} from './ResourceActions'

interface ResourcesRootState {
  endpoint_url: string;
  endpoints_loaded: boolean;
  endpoints: { };
  lookup_url: string;
  lookups_loaded: boolean;
  lookups: { };
}

// export const useTypedAuthSelector: TypedUseSelectorHook<AuthRootState> = useSelector

const initialState = {
  endpoint_url: '/endpoints',
  endpoints_loaded: false,
  endpoints: { },
  lookup_url: '/lookups',
  lookups_loaded: false,
  lookups: { }
}


export function resources(state: ResourcesRootState = initialState, action) {
  var newState = Object.assign( {}, state );

  switch (action.type) {
    case SET_ENDPOINT_URL:
      newState.endpoint_url = action.url;
      return newState;
    case SET_ENDPOINTS:
      newState.endpoints = action.endpoints;
      newState.endpoints_loaded = true;
      return newState;
    case SET_LOOKUP_URL:
      newState.lookup_url = action.url;
      return newState;
    case SET_LOOKUPS:
      newState.lookups = action.lookups;
      newState.lookups_loaded = true;
      return newState;
    default:
      return state;
  }
}
