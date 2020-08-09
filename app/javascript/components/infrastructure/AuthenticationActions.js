import {useSelector } from 'react-redux';

// Action Messages
export const AUTH_INIT = 'AUTH_INIT';
export const AUTH_CLEAR = 'AUTH_CLEAR';
export const AUTH_SUCCESS = 'LOGIN_SUCCESS';

import Auth from 'j-toker';
import { addMessage, Priorities } from './StatusActions';

export function authInit( ) {
  return { type: AUTH_INIT }
}

export function authClear() {
  return { type: AUTH_CLEAR }
}

export function authSuccess( email, id, first_name, last_name, theme, welcomed, timezone, language,  is_admin ) {
  return { type: AUTH_SUCCESS, email, id, first_name, last_name, theme, welcomed, timezone, language,  is_admin }
}

export function authConfig( apiUrl = '/api/v1' ){
  return(dispatch)=>{
    dispatch( authInit( ) );
    const auth = Auth.configure({ apiUrl: apiUrl, })
      .then( out =>{
        dispatch(authSuccess( out.uid, 
          out.id, out.first_name, out.last_name,
          out.theme_id, out.welcomed, out.timezone, out.language,
          out.admin ) );
        //dispatch( addMessage( "Successfully logged in", new Date(), Priorities.LOW ))
      })
      .fail(resp =>{
        dispatch( authClear( ) );
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
            dispatch( authSuccess( user.email ) );
            dispatch( addMessage( 'Successfully logged in', new Date( ), Priorities.LOW))

          })
          .fail(resp =>{
            dispatch( authClear( ) );
            dispatch( addMessage( 'Authentication failure: ' + resp.errors.join(' '), new Date( ), Priorities.HIGH))

          })
    
  }
}

export function signOut( ){

  return (dispatch)=>{
    console.log( 'signing in' )
    Auth.signOut( );
    console.log( 'signed out', auth );
    dispatch( authClear( ) );
    
  }
}