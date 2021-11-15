import React, {Component} from 'react';
// Inspired by https://ui.dev/react-router-v4-protected-routes-authentication/
import {Route, Redirect} from 'react-router-dom';
import { useTypedSelector } from "./AppReducers";

export default function ProtectedRoute ({ component: Component, ...rest }) {

    const isLoggedIn = useTypedSelector( (state) => state.context.status.loggedIn )

    return(
        <Route
          {...rest}
          render={(props) => {
            if( isLoggedIn ){
              if( undefined !== Component ){
                return (<Component {...props} />)
              } else {
                return rest.render( props )
              }
            }else{
              return(
                <Redirect
                  to={{
                    pathname: '/login',
                    state: {from: props.location}
                  }}
                />

              )
            }
          }
        } />

    )
  }
