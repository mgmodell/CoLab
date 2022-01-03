import axios from 'axios';

import {fetchProfile, setProfile, clearProfile} from './ProfileActions';
import {addMessage, Priorities} from './StatusActions';

export const SET_INITIALISED = 'SET_INITIALISED';
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
    GOOGLE_AUTH_PATH:   '/auth/omniauth',

    tokenFormat: {
        "access-token": "{{ access-token }}",
        "token-type":   "Bearer",
        client:         "{{ client }}",
        expiry:         "{{ expiry }}",
        uid:            "{{ uid }}"
    },

    authProviderPaths: {
        google: '/auth/google_oauth2'
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

    buildOAuthURL: function( configName: string,
                            params: {[key: string],
                            string}, providerPath: string ){

        let oAuthUrl: string = CONFIG.API_URL + providerPath;
        oAuthUrl += '?auth_origin_url=' + encodeURIComponent( location.href );
        oAuthUrl += '&config_name=' + encodeURIComponent(configName );
        oAuthUrl += "&omniauth_window_type=newWindow";

        if( params ){
            for( var key in params ){
                oAuthUrl += '&';
                oAuthUrl += encodeURIComponent( key );
                oAuthUrl += '=';
                oAuthUrl += encodeURIComponent(params[key])
            }
        }
        return oAuthUrl;
    }


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
                    dispatch( addMessage( 'Signed in successfully.', new Date(), Priorities.INFO ))
                    CONFIG.retrieveResources( dispatch, getState )
                        .then( response =>{
                            dispatch( fetchProfile( ) );
                        });
                })
                .catch( error=>{
                    console.log( 'error', error );
                })

        }
    }

}

export function oAuthSignIn( provider: string ){
    return( dispatch, getState ) =>{
        dispatch( setLoggingIn );
        //Get the URL
        const providerPath = CONFIG.authProviderPaths[ provider ];
        let url: string = CONFIG.buildOAuthURL( provider, {}, providerPath );

        if( true /*load here*/ ){
            window.location.replace( url )

        }else {
            var popup = this.open( url );
            //build a listenFoCredentials function
        }

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
