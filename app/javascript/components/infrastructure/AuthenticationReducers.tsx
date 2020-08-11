import {useSelector, TypedUseSelectorHook } from 'react-redux';
import {
  AUTH_INIT,
  AUTH_SUCCESS,
  STORE_AUTH_CONFIG,
  AUTH_CLEAR,
} from './AuthenticationActions'

interface AuthRootState {
  isLoggedIn: boolean;
  isLoggingIn: boolean;
  profile: {
    id: number;
    first_name: string;
    last_name: string;
    theme: string;
    timezone: string;
    language: string;
    is_admin: boolean;
    is_instructor: boolean,
    welcomed: boolean;
    email: string;
  };
}

// export const useTypedAuthSelector: TypedUseSelectorHook<AuthRootState> = useSelector

const initialState = {
    isLoggingIn: false,
    isLoggedIn: false,
    profile: {
      id: 0,
      first_name: "",
      last_name: "",
      theme: "",
      timezone: "UTC",
      language: "en",
      is_admin: false,
      is_instructor: false,
      welcomed: false,
      email: ''
    }
}


export function login(state: AuthRootState = initialState, action) {
  var newState = Object.assign( {}, state );

  switch (action.type) {
    case AUTH_INIT:
      newState.isLoggingIn = true;
      newState.auth = action.auth;
      return newState;
    case AUTH_CLEAR:
      newState = Object.assign( {}, initialState );
      return newState;
    case AUTH_SUCCESS:
      newState.isLoggingIn = false;
      newState.isLoggedIn = true;
      newState.profile = {
        id: action.id,
        first_name: action.first_name,
        last_name: action.last_name,
        theme: action.theme,
        timezone: action.timezone || 'UTC',
        language: action.language || "en",
        is_admin: action.is_admin,
        is_instructor: action.is_instructor,
        welcomed: action.welcomed,
        email: action.email,
      }
      return newState;
    default:
      return state;
  }
}
