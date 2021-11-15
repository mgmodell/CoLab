import {useTypedSelector} from './AppReducers';
import axios from 'axios';
import {ProfilesRootState} from './ProfileReducers';

// Action Messages
export const SET_PROFILE = 'SET_PROFILE';
export const SET_PROFILE_LANGUAGE = 'SET_PROFILE_LANGUAGE';
export const SET_ANONYMIZE = 'SET_ANONYMIZE';
export const SET_PROFILE_TIMEZONE = 'SET_PROFILE_TIMEZONE';
export const SET_PROFILE_THEME = 'SET_PROFILE_THEME';
export const CLEAR_PROFILE = 'CLEAR_PROFILE';


import { addMessage, startTask, endTask, Priorities } from './StatusActions';

//Base redux functions
export function setProfile( user: ProfilesRootState ) {
  return { type: SET_PROFILE, user }
}

export function setProfileLanguage( language_id: number ) {
  return { type: SET_PROFILE_LANGUAGE, language_id }
}

export function setAnonymize( anonymize: boolean ) {
  return { type: SET_ANONYMIZE, anonymize }
}

export function setProfileTimezone( timezone: string ) {
  return { type: SET_PROFILE_TIMEZONE, timezone }
}

export function setProfileTheme( theme_id: number ) {
  return { type: SET_PROFILE_THEME, theme_id }
}

export function clearProfile( ) {
  return { type: CLEAR_PROFILE }
}

//Middleware async functions
export function fetchProfile( reset: boolean = false  ){
  return(dispatch,getState)=>{
    const url = getState().context.endpoints[ 'profile' ]['baseUrl'] + '.json';
    dispatch( startTask( 'init' ) )

    axios.get( url, {
    })
      .then( (response)=>{
        console.log( 'user', response );
        const user: ProfilesRootState = response['user']['user'];
        console.log( 'user data', response, user );
        dispatch( setProfile( user ) );
        dispatch( endTask( 'loading' ) );
      } )
      .catch( error =>{
        console.log( 'error', error );
      })
  }
}

export function saveProfile( ){
  return( dispatch, getState )=>{
    dispatch( startTask( 'saving' ) );
    const url = getState().context.endpoints[ 'profile' ]['baseUrl'] + '.json';
    let user: ProfilesRootState = getState().profile.user;


    axios.patch( url, {
      withCredentials: true,
      headers: {
        'Content-Type': 'application/json',
        Accepts: "application/json",
      },
      body: JSON.stringify( user )

    } )
      .then( (data) =>{
        user = data['user'];
        dispatch( setProfile( user ) );
        dispatch( endTask( 'loading' ) );
      } )
      .catch( error =>{
        console.log( 'error', error );
      })
  }
}
