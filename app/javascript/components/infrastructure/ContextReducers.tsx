import {useSelector, TypedUseSelectorHook} from 'react-redux';

import {
    SET_LOGGING_IN,
    SET_LOGGED_IN,
    SET_LOGGED_OUT,
    LOGIN_FAILED,
    SET_ENDPOINT_URL,
    SET_ENDPOINTS,
    SET_LOOKUPS
} from './ContextActions';

export interface ContextRootState {
    status: {
        loggingIn: boolean;
        loggedIn: boolean;
        initialised: boolean;
        endpointsLoaded: boolean;
    };
    config: {
        localStorage?: boolean;
        endpoint_url?: string;
    };
    lookups: { 
        [key: string]: {
            [key: string]: Object;
        };
    };
    endpoints: { 
        [key: string]: {
            [key: string]: string;
        };
    };
}

const initialState : ContextRootState = {
    status: {
        loggingIn: false,
        loggedIn: false,
        initialised: false,
        endpointsLoaded: false,
    },
    config: {
        localStorage: null,
        endpoint_url: null,
    },
    lookups: { },
    endpoints: { },
}

export function context(state: ContextRootState = initialState, action){
    var newState = Object.assign( {}, state );


    switch( action.type){
        case SET_ENDPOINT_URL:
            newState.config.endpoint_url = action.url;
            return newState;
        case SET_LOGGING_IN:
            newState.status.loggingIn = true;
            newState.status.loggedIn = false;
            return newState;
        case SET_LOGGED_IN:
            //    console.log( 'lookups:', action.lookups );
            newState.status.loggingIn = false;
            newState.status.loggedIn = true;
            newState.lookups = action.lookups;
            newState.endpoints = action.endpoints;
            newState.status.endpointsLoaded = true;
            return newState;
        case LOGIN_FAILED:
            newState.status.loggingIn = false;
            return newState;
        case SET_LOGGED_OUT:
            newState.status.loggingIn = false;
            newState.status.loggedIn = false;
            newState.lookups = action.lookups;
            newState.endpoints = action.endpoints;
            newState.status.endpointsLoaded = true;
            console.log( 'lo', newState );
            return newState;
        case SET_ENDPOINTS:
            newState.endpoints = action.endpoints;
            return newState;
        case SET_LOOKUPS:
            newState.lookups = action.lookups;
            return newState;
        default:
            return state;
    }
}