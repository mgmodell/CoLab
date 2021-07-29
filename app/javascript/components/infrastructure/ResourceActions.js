import {useTypedSelector} from './AppReducers'

// Action Messages
export const SET_ENDPOINT_URL = 'SET_ENDPOINT_URL';
export const SET_ENDPOINTS = 'SET_ENDPOINTS';
export const SET_LOOKUP_URL = 'SET_LOOKUP_URL';
export const SET_LOOKUPS = 'SET_LOOKUPS';

import { addMessage, startTask, endTask, Priorities } from './StatusActions';

export function setEndpointUrl( url ) {
  return { type: SET_ENDPOINT_URL, url }
}

export function setEndpoints( endpoints ) {
  return { type: SET_ENDPOINTS, endpoints }
}


export function reloadEndpoints( url ){
  return(dispatch,getState)=>{
    dispatch( startTask( 'init' ) )

    var endpointsUrl = url
    if( !endpointsUrl ){
      endpointsUrl = getState().resources.endpoint_url
    } else {
      dispatch( setEndpointUrl( endpointsUrl ) );
    }
    //useTypedSelector( state => { return state['context'].endpointsUrl })

        fetch(endpointsUrl + ".json", {
          method: "GET",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
            Accepts: "application/json",
          }
        })
          .then(response => {
            if (response.ok) {
              return response.json();
            } else {
              //setState({ error: response });
            }
          })
          .then(data => {
            dispatch( setEndpoints( data.endpoints ) )
            dispatch( endTask( 'init' ) )
          });
    
  }
}

export function setLookupUrl( url ) {
  return { type: SET_LOOKUP_URL, url }
}

export function setLookups( lookups ) {
  return { type: SET_LOOKUPS, lookups }
}


export function reloadLookups( url ){
  return(dispatch,getState)=>{
    dispatch( startTask( 'init' ) )
    var lookupsUrl = url
    if( !lookupsUrl ){
      lookupsUrl = getState().resources.lookup_url
    } else {
      dispatch( setLookupUrl( lookupsUrl ) );
    }

        fetch(lookupsUrl + ".json", {
          method: "GET",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
            Accepts: "application/json",
          }
        })
          .then(response => {
            if (response.ok) {
              return response.json();
            } else {
              //setState({ error: response });
            }
          })
          .then(data => {
            dispatch( setLookups( data ) )
            dispatch( endTask( 'init' ) )
          });
    
  }
}
