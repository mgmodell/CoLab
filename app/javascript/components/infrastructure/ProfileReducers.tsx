import {useSelector, TypedUseSelectorHook } from 'react-redux';
import {
  SET_PROFILE,
  SET_ANONYMIZE,
  SET_PROFILE_TIMEZONE,
  SET_PROFILE_THEME,
  CLEAR_PROFILE
} from './ProfileActions'

export interface ProfilesRootState {
  lastRetrieved: Date;
  user: {
  id: number;
  first_name: string;
  last_name: string;
  name: string;
  emails: [{
    email: string;
    primary: boolean;
  }];

  welcomed: boolean;
  is_instructor: boolean;
  is_admin: boolean;
  country: string;
  timezone: string;
  language_id: number;
  theme_id: number;
  admin: boolean;
  researcher: boolean;
  anonymize: boolean;

  gender_id: number;
  date_of_birth: Date;
  home_state_id: number;
  primary_language_id: number;

  school_id: number;
  started_school: Date;
  cip_code_id: number;

  impairment_visual: boolean;
  impairment_auditory: boolean;
  impairment_motor: boolean;
  impairment_cognitive: boolean;
  impairment_other: boolean;

  }

}


const initialState = {
  lastRetrieved: null,
  user: {
  id: -1,
  first_name: '',
  last_name: '',
  name: '',
  emails: [
  ],

  welcomed: false,
  is_instructor: false,
  is_admin: false,
  country: null,
  timezone: 'UTC',
  language_id: 40,
  theme_id: 0,
  admin: false,
  researcher: false,
  anonymize: false,

  gender_id: null,
  date_of_birth: null ,
  home_state_id: null,
  primary_language_id: null,

  school_id: null,
  started_school: null,
  cip_code_id: null,

  impairment_visual: false,
  impairment_auditory: false,
  impairment_motor: false,
  impairment_cognitive: false,
  impairment_other: false,

  }
}


export function profile(state: ProfileRootState = initialState, action) {
  var newState = Object.assign( {}, state );

  switch (action.type) {
    case SET_PROFILE:
      Object.assign( newState.user = action.user );
      newState.lastRetrieved = Date.now();
      return newState;
    case SET_ANONYMIZE:
      newState.user.anonymize = action.anonymize;
      return newState;
    case SET_PROFILE_TIMEZONE:
      newState.user.timezone = action.timezone;
      return newState;
    case SET_PROFILE_THEME:
      newState.user.theme_id = action.theme_id;
      return newState;
    case CLEAR_PROFILE:
      Object.assign( newState, initialState );
      newState.lastRetrieved = null;
      return newState;
    default:
      return state;
  }
}
