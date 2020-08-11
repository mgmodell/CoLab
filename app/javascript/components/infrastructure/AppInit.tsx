import React, { useState, useEffect } from "react";
import { useDispatch } from 'react-redux';
import { authConfig } from './AuthenticationActions';
import { useTypedSelector } from "./AppReducers";
import { setEndpointUrl, reloadEndpoints, reloadLookups } from './ResourceActions';

import PropTypes from "prop-types";

export default function AppInit(props) {
  const dispatch = useDispatch( );

  const isLoggedIn = useTypedSelector( state => state['login'].isLoggedIn  )
  const endpoints_loaded = useTypedSelector( state => state['resources'].endpoints_loaded  )
  const endpoints = useTypedSelector( state => state['resources'].endpoints );

  useEffect( ()=> {
    dispatch( reloadEndpoints( props.endpointsUrl ))
    dispatch( authConfig()  )
  }, [] )

  useEffect( () => {
    dispatch( reloadEndpoints( ) )

  }, [isLoggedIn])

  useEffect( ()=> {
    if( endpoints_loaded ){
      dispatch( reloadLookups( endpoints['home']['lookupsUrl'] ))
    }
  }, [endpoints_loaded] )

  return(
    <React.Fragment />
  )
}

AppInit.propTypes = {
  endpointsUrl: PropTypes.string.isRequired
}