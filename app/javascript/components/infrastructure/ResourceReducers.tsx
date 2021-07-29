import {useSelector, TypedUseSelectorHook } from 'react-redux';
import {
  SET_ENDPOINT_URL,
  SET_ENDPOINTS,
  SET_LOOKUP_URL,
  SET_LOOKUPS
} from './ResourceActions'

interface ResourcesRootState {
  endpoint_url: string;
  endpointsLoaded: boolean;
  endpoints: { };
  lookup_url: string;
  lookups_loaded: boolean;
  lookups: { };
}

// export const useTypedAuthSelector: TypedUseSelectorHook<AuthRootState> = useSelector

const initialState = {
  endpoint_url: '/endpoints',
  endpointsLoaded: false,
  endpoints: { },
  lookup_url: '/infra/lookups',
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
      newState.endpointsLoaded = true;
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
