import React, { useState, useEffect } from "react";
import { useDispatch } from 'react-redux';
import { authConfig } from './AuthenticationActions';
import { useTypedSelector } from "./AppReducers";

export default function AuthInit(props) {
  const dispatch = useDispatch( );
  const isLoggedIn = useTypedSelector( state =>{ state['login'].isLoggedIn } )

  useEffect( ()=> {
    dispatch( authConfig()  )
  }, [] )

  return(
    <React.Fragment />
  )
}
