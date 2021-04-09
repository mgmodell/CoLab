import {useSelector } from 'react-redux';

// Action Messages
export const AUTH_INIT = 'AUTH_INIT';
export const AUTH_CLEAR = 'AUTH_CLEAR';
export const AUTH_SUCCESS = 'LOGIN_SUCCESS';

import Auth from 'j-toker';
import { addMessage, Priorities } from './StatusActions';
import { reloadEndpoints, reloadLookups } from './ResourceActions'

export function authInit( ) {
  return { type: AUTH_INIT }
}

export function authClear() {
  return { type: AUTH_CLEAR }
}

export function authSuccess( email, id, first_name, last_name, theme, welcomed, timezone, language,  is_admin, is_instructor ) {
  return { type: AUTH_SUCCESS, email, id, first_name, last_name, theme, welcomed, timezone, language,  is_admin, is_instructor }
}

export function authConfig( apiUrl = '' ){
  return(dispatch)=>{
    dispatch( authInit( ) );
    const auth = Auth.configure({ apiUrl: apiUrl, })
      .then( user =>{
        dispatch(authSuccess( user.uid, 
          user.id, user.first_name, user.last_name,
          user.theme_id, user.welcomed, user.timezone, user.language,
          user.admin, user.instructor ) );
        dispatch( reloadEndpoints( ) );
        dispatch( reloadLookups( ) )
        //dispatch( addMessage( "Successfully logged in", new Date(), Priorities.LOW ))
      })
      .fail(resp =>{
        dispatch( authClear( ) );
        dispatch( reloadEndpoints( ) );
        dispatch( reloadLookups( ) )
      });
  }
}

export function emailSignIn( email, password ){
  return (dispatch)=>{
        dispatch( authInit( ) );

        Auth.emailSignIn({
          email: email,
          password: password
        })
          .then(user =>{
            dispatch(authSuccess( user.uid, 
              user.id, user.first_name, user.last_name,
              user.theme_id, user.welcomed, user.timezone, user.language,
              user.admin, user.instructor ) );
            dispatch( reloadEndpoints( ) );
            dispatch( addMessage( 'Successfully logged in', new Date( ), Priorities.LOW))

          })
          .fail(resp =>{
            dispatch( authClear( ) );
            dispatch( reloadEndpoints( ) );
            dispatch( addMessage( 'Authentication failure: ' + resp.reason +  resp.data.errors.join(' '), new Date( ), Priorities.HIGH))

          })
    
  }
}

export function oAuthSignIn( provider ){
  return (dispatch)=>{
        dispatch( authInit( ) );

        Auth.oAuthSignIn({
          provider: provider
        })
          .then(user =>{
            dispatch(authSuccess( user.uid, 
              user.id, user.first_name, user.last_name,
              user.theme_id, user.welcomed, user.timezone, user.language,
              user.admin, user.instructor ) );
            dispatch( reloadEndpoints( ) );
            dispatch( addMessage( 'Successfully logged in', new Date( ), Priorities.LOW))

          })
          .fail(resp =>{
            dispatch( authClear( ) );
            dispatch( reloadEndpoints( ) );
            dispatch( addMessage( 'Authentication failure: ' + resp.errors.join(' '), new Date( ), Priorities.HIGH))

          })
    
  }
}

export function signOut( ){

  return (dispatch)=>{
    Auth.signOut( );
    dispatch( authClear( ) );
    dispatch( reloadEndpoints( ) );
    
  }
}
