/*
 * This code was largely adapted from j-toker.
 * https://github.com/lynndylanhurley/j-toker
 */
import axios from 'axios';

import {fetchProfile, setProfile, clearProfile} from './ProfileActions';
import {addMessage, Priorities} from './StatusActions';
import i18n from '../infrastructure/i18n';

export const SET_INITIALISED = 'SET_INITIALISED';
export const SET_LOGGING_IN = 'SET_LOGGING_IN';
export const SET_LOGGED_IN = 'SET_LOGGED_IN';
export const SET_LOGGED_OUT = 'SET_LOGGED_OUT';
export const LOGIN_FAILED = 'SET_LOGIN_FAILED';
export const SET_ENDPOINT_URL = 'SET_ENDPOINT_URL';
export const SET_ENDPOINTS = 'SET_ENDPOINTS';
export const SET_LOOKUPS = 'SET_LOOKUPS';

const category = 'devise';
const t = i18n.getFixedT( null, category );


const CONFIG = {
    SAVED_CREDS_KEY:    'colab_authHeaders',
    API_URL:            '/auth',
    SIGN_OUT_PATH:      '/auth/sign_out',
    EMAIL_SIGNIN_PATH:  '/auth/sign_in',
    EMAIL_REGISTRATION_PATH: '/auth',

    tokenFormat: {
        "access-token": "{{ access-token }}",
        "token-type":   "Bearer",
        client:         "{{ client }}",
        expiry:         "{{ expiry }}",
        uid:            "{{ uid }}"
    },

    parseExpiry: function(headers){
        // convert from ruby time (seconds) to js time (millis)
        return (parseInt(headers['expiry'], 10) * 1000) || null;
    },

    /**
     * This function is used as an axios send interceptor.
     * 
     * @param config what has already been configured to be sent.
     * @returns 
     */
    appendAuthHeaders: function( config: any ){
        const storedHeaders = CONFIG.retrieveData( CONFIG.SAVED_CREDS_KEY );

        if ( CONFIG.isApiRequest(config.url) && storedHeaders) {
            // bust IE cache
          config['headers'][ 'If-Modified-Since'] = 'Mon, 26 Jul 1997 05:00:00 GMT';

          // set header for each key in `tokenFormat` config
          for (var key in CONFIG.tokenFormat) {
            config['headers'][key] =  storedHeaders[key];
          }
        }
        return config;

    },

    /**
     * This function is used as an axios receive interceptor.
     * 
     * @param response 
     * @returns 
     */
    storeRetrievedCredentials: function( response: any ){


        if( CONFIG.isApiRequest( response['config']['url'] ) ){
            let newHeaders = {};
            let blankHeaders = true;

            for( var key in CONFIG.tokenFormat){
                newHeaders[ key ] = response['headers'][key];
                if( newHeaders[key]){
                    blankHeaders = false;
                }
            }

            if( !blankHeaders ) {
                CONFIG.persistData( CONFIG.SAVED_CREDS_KEY, newHeaders );
            }


        };
        return response;
    },

    isApiRequest: function( url: string ){
        //Maybe we'll do something meaningful here later
        return true;
    },

    retrieveData( key ){
        var val = null;

        //Add Cookie support later
        val = localStorage.getItem(key);

        // if value is a simple string, the parser will fail. in that case, simply
        // unescape the quotes and return the string.
        try {
          // return parsed json response
          return JSON.parse( val );
        } catch (err) {
          // unescape quotes
          return val && val.replace(/("|')/g, '');
        }

    },

    persistData: function( key : string, val ){
        let data = JSON.stringify( val );

        //Add Cookie support later
        localStorage.setItem(key, data);


    },

    deleteData: function( key : string ){

        //Add Cookie support later
        localStorage.removeItem(key);


    },

    retrieveResources: function( dispatch: Function, getState: Function ){
        const endPointsUrl = getState()['context']['config']['endpoint_url'];

        return axios.get( endPointsUrl + '.json',
            { withCredentials: true } )
            .then( resp =>{
                if( resp['data'][ 'logged_in'] ){
                    dispatch( setLoggedIn(
                        resp['data']['lookups'],
                        resp['data']['endpoints'] ) );
                    dispatch( setProfile( resp['data']['profile']['user']) )
                    //dispatch( fetchProfile( ) );
                } else {
                    dispatch( setLoggedOut(
                        resp['data']['lookups'],
                        resp['data']['endpoints'] ) );
                    dispatch( clearProfile );
                    CONFIG.deleteData( CONFIG.SAVED_CREDS_KEY );
                }

            })

    },


}


export function setInitialised( ){
    return{ type: SET_INITIALISED };
}
export function setLoggingIn( ){
    return{ type: SET_LOGGING_IN };
}
export function setLoggedIn( lookups: object, endpoints: object ){
    return{ type: SET_LOGGED_IN, lookups, endpoints };
}

export function setLoggedOut( lookups: object, endpoints: object ){
    return{ type: SET_LOGGED_OUT, lookups, endpoints };
}

export function setLoginFailed( ){
    return{ type: LOGIN_FAILED };
}

export function setEndPointUrl( url : string ){
    return { type: SET_ENDPOINT_URL, url };
}

export function setEndPoints( endpoints : object ){
    return { type: SET_ENDPOINTS, endpoints };
}

export function setLookups( lookups: object ){
    return { type: SET_LOOKUPS, lookups };
}

export function getContext( endPointsUrl: string ){
    return( dispatch, getState ) =>{
        dispatch( setEndPointUrl( endPointsUrl ) );
        dispatch( setLoggingIn( ) );
        axios.interceptors.request.use( CONFIG.appendAuthHeaders );
        axios.interceptors.response.use( CONFIG.storeRetrievedCredentials );

        //Add ProcessLocationBar later
        
        //Pull the resources
        CONFIG.retrieveResources( dispatch, getState )
            .then( () =>{
                dispatch( setInitialised( ) );
            });
    }

}

export function emailSignIn( email: string, password: string ){

    return( dispatch, getState ) =>{
        dispatch( setLoggingIn);

        if( !email || !password ){
            dispatch( setLoginFailed( ) );
        } else {
            return axios.post( CONFIG.EMAIL_SIGNIN_PATH,
                { email: email,
                  password: password } )
                .then( resp=>{
                    //TODO resp contains the full user info
                    dispatch( addMessage( t( 'sessions.signed_in'), new Date(), Priorities.INFO ))
                    CONFIG.retrieveResources( dispatch, getState )
                        .then( response =>{
                            dispatch( fetchProfile( ) );
                        });
                })
                .catch( error=>{
                    //Handle a failed login properly
                    console.log( 'error', error );
                })

        }
    }

}

//Untested
export function emailSignUp( email: string ){

    return( dispatch, getState ) =>{
        dispatch( setLoggingIn);

        if( !email ){
            dispatch( setLoginFailed( ) );

        } else {
            return axios.post( CONFIG.EMAIL_REGISTRATION_PATH + '.json',
                {
                    email: email,
                 } )
                .then( resp=>{
                    const data = resp.data;
                    dispatch( addMessage( t( data.message ), new Date(), Priorities.INFO ))
                })
                .catch( error=>{
                    console.log( 'error', error );
                })

        }
    }

}

export function oAuthSignIn( token: string ){
    return( dispatch, getState ) =>{
        dispatch( setLoggingIn );

        const url = getState().context.endpoints['home'].oauthValidate + '.json';

        axios.post( url, {
            id_token: token
        })
            .then( resp=>{
                //TODO resp contains the full user info
                dispatch( addMessage( resp.data['message'], new Date(), Priorities.INFO ))
                CONFIG.retrieveResources( dispatch, getState )
                    .then( response =>{
                        dispatch( fetchProfile( ) );
                    });
            })
            .catch( error=>{
                //Handle a failed login properly
                console.log( 'error', error );
            })

    }
    
}


export function signOut( ){
    return( dispatch, getState ) =>{
        if( getState().context.status.loggedIn){
            axios.delete( CONFIG.SIGN_OUT_PATH, {} )
            .then( resp=>{
                dispatch( clearProfile() );
                CONFIG.deleteData( CONFIG.SAVED_CREDS_KEY );
                CONFIG.retrieveResources( dispatch, getState )
                //TODO: Finish this
                // Wipe out the existing cookies/localStorage

            })
        }

    }
}
