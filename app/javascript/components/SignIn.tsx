import React, { useState, useEffect } from "react";
import {Redirect} from 'react-router-dom';
//Redux store stuff
import { useSelector, useDispatch } from 'react-redux';
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  acknowledgeMsg} from './infrastructure/StatusActions';
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import IconButton from "@material-ui/core/IconButton";
import InputAdornment from '@material-ui/core/InputAdornment';
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";
import Collapse from "@material-ui/core/Collapse";
import Alert from "@material-ui/lab/Alert";
import CloseIcon from "@material-ui/icons/Close";
import VisibilityOff from '@material-ui/icons/VisibilityOff';
import Visibility from '@material-ui/icons/Visibility';

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import Grid from "@material-ui/core/Grid";
import Input from "@material-ui/core/Input";
//import {emailSignIn, oAuthSignIn, signOut } from './infrastructure/AuthenticationActions';
import {emailLogin} from './infrastructure/ContextActions';
import {useTypedSelector} from './infrastructure/AppReducers'

export default function SignIn(props) {
  //const { t, i18n } = useTranslation('schools' );

  const dispatch = useDispatch( );

  const [email, setEmail] = useState( '' );
  const [password, setPassword] = useState( '' );
  const [showPassword, setShowPassword] = useState( false );
  const [from, setFrom] = useState( props.from || '/'  );
  const isLoggedIn = useTypedSelector( state => state.context.status.loggedIn );
  const endpointsLoaded = useTypedSelector(state=>state.context.status.endpointsLoaded );

  const signOutBtn =  (
    <Button disabled={false} variant="contained" onClick={()=>{
      //dispatch( signOut( email, password ) )
    }}>
      Log Out
    </Button>
  );
  const enterLoginBtn =  (
    <Button disabled={'' === email || '' === password || !endpointsLoaded } variant="contained" onClick={()=>{
      dispatch( emailLogin( email, password ) )
    }}>
      Log in
    </Button>
  );
  const oauthBtn =  (
    <Button variant="contained" onClick={()=>{
      //dispatch( oAuthSignIn( 'google') );
    }}>
      Log In with Google
    </Button>
  );

  if( isLoggedIn ){
    return <Redirect to={from} />
  }

  return (
    <Paper>
      <Grid container>
        <Grid item xs={12} >
        <FormControl >
          <InputLabel htmlFor="email">Email</InputLabel>
          <Input
            id="email"
            type='text'
            value={email}
            onChange={(event) => setEmail( event.target.value )}
          />
        </FormControl>
        </Grid>
        <Grid item xs={12} sm={9}>
        <FormControl >
          <InputLabel htmlFor="password">Password</InputLabel>
          <Input
            id="password"
            type={showPassword ? 'text' : 'password' }
            value={password}
            onChange={(event) => setPassword( event.target.value )}
            endAdornment={
              <InputAdornment position="end">
                <IconButton
                  aria-label="toggle password visibility"
                  onClick={()=>{setShowPassword( !showPassword )}}
                  onMouseDown={(event)=>{event.preventDefault}}
                >
                  {showPassword ? <Visibility /> : <VisibilityOff />}
                </IconButton>
              </InputAdornment>
            }
          />
        </FormControl>
        </Grid>
      </Grid>
      {enterLoginBtn}
      {oauthBtn}
    </Paper>
  );
}
SignIn.propTypes = {
  from: PropTypes.string
}
