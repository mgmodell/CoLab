import axios from 'axios';
//import {addMessage, startTask, endTask, Priorities } from './StatusActions';

import {fetchProfile} from './ProfileActions';

export const SET_LOGGING_IN = 'SET_LOGGING_IN';
export const SET_LOGGED_IN = 'SET_LOGGED_IN';
export const SET_LOGGED_OUT = 'SET_LOGGED_OUT';
export const LOGIN_FAILED = 'SET_LOGIN_FAILED';
export const SET_ENDPOINT_URL = 'SET_ENDPOINT_URL';
export const SET_ENDPOINTS = 'SET_ENDPOINTS';
export const SET_LOOKUPS = 'SET_LOOKUPS';

const CONFIG = {
    SAVED_CREDS_KEY:    'colab_authHeaders',
    API_URL:            '/api',
    SIGN_OUT_PATH:      '/auth/sign_out',
    EMAIL_SIGNIN_PATH:  '/auth/sign_in',

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

    authProviderPaths: {
        google:    '/auth/google_oauth2'
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
        console.log( 'appended', config );
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
        console.log( 'storing', response );
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

    retrieveResources: function( dispatch: Function, getState: Function ){
        const endPointsUrl = getState()['context']['config']['endpoint_url'];

        axios.get( endPointsUrl + '.json',
            { withCredentials: true } )
            .then( resp =>{

                if( resp['data'][ 'logged_in'] ){
                    dispatch( setLoggedIn(
                        resp['data']['lookups'],
                        resp['data']['endpoints'] ) );
                    dispatch( fetchProfile( ) );
                } else {
                    dispatch( setLoggedOut(
                        resp['data']['lookups'],
                        resp['data']['endpoints'] ) );
                }

            })

    }


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
        CONFIG.retrieveResources( dispatch, getState );
    }

}

export function emailLogin( email: string, password: string ){
    return( dispatch, getState ) =>{
        dispatch( setLoggingIn);

        if( !email || !password ){
            dispatch( setLoginFailed( ) );
        } else {
            axios.post( CONFIG.EMAIL_SIGNIN_PATH,
                { email: email,
                  password: password } )
                .then( resp=>{
                    console.log( 'login', resp );
                    CONFIG.retrieveResources( dispatch, getState );
                    dispatch( fetchProfile( ) );
                    CONFIG.retrieveResources( dispatch, getState );
                })
                .catch( error=>{
                    console.log( 'error', error );
                })

        }
    }

}


