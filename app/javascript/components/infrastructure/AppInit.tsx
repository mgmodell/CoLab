import React, { useState, useEffect } from "react";
import { useDispatch } from 'react-redux';
//import { authConfig } from './AuthenticationActions';
import {getContext} from './ContextActions';
import { useTypedSelector } from "./AppReducers";
//import { setEndpointUrl, reloadEndpoints, reloadLookups } from './ResourceActions';

import PropTypes from "prop-types";

export default function AppInit(props) {
  const dispatch = useDispatch( );

  const isLoggedIn = useTypedSelector( (state) => state.context.status.loggedIn );
  const endpointsLoaded = useTypedSelector( (state) => state.context.status.endpointsLoaded );

  const endpoints = useTypedSelector( (state) => state.context.endpoints );

  useEffect( ()=> {
    //dispatch( authConfig()  )
    dispatch( getContext( props.endpointsUrl ) );
    
  }, [] )

  /*
  useEffect( () => {
    dispatch( reloadEndpoints( ) )

  }, [isLoggedIn])

  useEffect( ()=> {
    if( endpointsLoaded ){
      dispatch( reloadLookups( endpoints['home']['lookupsUrl'] ))
    }
  }, [endpointsLoaded] )
  */

  return(
    <React.Fragment />
  )
}

AppInit.propTypes = {
  endpointsUrl: PropTypes.string.isRequired
}