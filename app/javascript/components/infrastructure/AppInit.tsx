import React, { useState, useEffect } from "react";
import { useDispatch } from 'react-redux';
import {getContext, setInitialised} from './ContextActions';
import { useTypedSelector } from "./AppReducers";

import PropTypes from "prop-types";
import Skeleton from "@material-ui/lab/Skeleton";

type Props = {
  children?: React.ReactNode,
  endpointsUrl,
};

export default function AppInit(props: Props ) {
  const dispatch = useDispatch( );

  const initialised = useTypedSelector( (state) => state.context.status.initialised );
  const isLoggedIn = useTypedSelector( (state) => state.context.status.loggedIn );
  const endpointsLoaded = useTypedSelector( (state) => state.context.status.endpointsLoaded );

  const endpoints = useTypedSelector( (state) => state.context.endpoints );

  useEffect( ()=> {
    //dispatch( authConfig()  )
    dispatch( getContext( props.endpointsUrl ) );
    
  }, [] )


  if( !initialised || undefined === props.children ){
    return(
     <Skeleton variant="rect" height={300} />
    )
  }else{
    return props.children;

  }
}

AppInit.propTypes = {
  endpointsUrl: PropTypes.string.isRequired
}