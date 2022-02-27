import React, { useState, useEffect } from "react";
import { Navigate, useNavigate, useLocation } from "react-router-dom";
//Redux store stuff
import { useSelector, useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  acknowledgeMsg
} from "./infrastructure/StatusActions";
import EmailValidator from 'email-validator';
import Button from "@mui/material/Button";
import PropTypes from "prop-types";
import TextField from "@mui/material/TextField";
import InputLabel from "@mui/material/InputLabel";
import IconButton from "@mui/material/IconButton";
import InputAdornment from "@mui/material/InputAdornment";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import Paper from "@mui/material/Paper";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";
import Collapse from "@mui/material/Collapse";
import Alert from "@mui/material/Alert";
import CloseIcon from "@mui/icons-material/Close";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import Visibility from "@mui/icons-material/Visibility";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import AdapterLuxon from "@mui/lab/AdapterLuxon";
//import i18n from './i18n';
import { useTranslation } from 'react-i18next';
import Grid from "@mui/material/Grid";
import Input from "@mui/material/Input";
//import {emailSignIn, oAuthSignIn, signOut } from './infrastructure/AuthenticationActions';
import { emailSignIn, oAuthSignIn, emailSignUp } from "./infrastructure/ContextActions";
import { GoogleLogin } from "react-google-login";
import { useTypedSelector } from "./infrastructure/AppReducers";
import Skeleton from "@mui/material/Skeleton";
import TabsContext from "@mui/lab/TabContext";
import TabPanel from '@mui/lab/TabPanel';
import TabList from "@mui/lab/TabList";
import { Tab } from "@mui/material";

export default function SignIn(props) {
  const category = "devise";
  const { t, i18n } = useTranslation( category );

  const dispatch = useDispatch();
  const { state } = useLocation();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const loggingIn = useTypedSelector(state => state.context.status.loggingIn);
  const [curTab, setCurTab] = useState( 'login' );

  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const oauth_client_ids = useTypedSelector(
    state => state.context.lookups["oauth_ids"]
  );

  //Code to trap an 'enter' press and submit
  //It gets placed on the password field
  const submitOnEnter = (evt) => {
    if( endpointsLoaded && evt.key === 'Enter' ){
      dispatch(emailSignIn(email, password)).then(navigate(from));
      evt.preventDefault( );
    }
  }

  const from = undefined != state ? state.from : "/";

  const enterLoginBtn = (
    <Button
      disabled={"" === email || "" === password || !endpointsLoaded || !EmailValidator.validate( email )}
      variant="contained"
      onClick={() => {
        dispatch(emailSignIn(email, password)).then(navigate(from));
      }}
    >
      {t( 'sessions.login_submit')}
    </Button>
  );

  const registerBtn = (
    <Button
      disabled={"" === email || !endpointsLoaded}
      variant="contained"
      onClick={() => {
        dispatch(emailSignUp(email)).then(navigate(from));
      }}
    >
      {t( 'registrations.signup_btn')}
    </Button>
  );

  const clearBtn = (
    <Button
      disabled={"" === email && "" === password}
      variant="contained"
      onClick={() => {
        setPassword( '' );
        setEmail( '' );
      }}
    >
      {t( 'reset_btn')}
    </Button>
  );

  const get_token_from_oauth = response => {
    console.log("success", response);
    dispatch(oAuthSignIn(response.tokenId));
  };

  const oauthBtn = (
    <GoogleLogin
      clientId={oauth_client_ids["google"]}
      onSuccess={get_token_from_oauth}
      onFailure={response => {
        console.log("fail", response);
      }}
      cookiePolicy="single_host_origin"
    />
  );

  const emailField = (
          <Grid item xs={12}>
              <TextField
                label='Email'
                id='email'
                autoFocus
                value={email}
                onChange={event => setEmail(event.target.value)}
                error={ '' !== email && !EmailValidator.validate( email ) }
                helperText={('' === email || EmailValidator.validate( email ) ) ? null : 'Must be a valid email address' }
                variant='standard'
              />
          </Grid>
  )

  if (loggingIn) {
    return <Skeleton variant="rectangular" height="300" />;
  } else if (isLoggedIn) {
    return <Navigate replace to={state.from || "/"} />;
  } else {

    return (
      <Paper>
        <TabsContext value={curTab} >
          <TabList onChange={(evt,newVal) => { setCurTab(newVal ); }} >
            <Tab label={t('sessions.login')} value='login' />
            <Tab label={t('registrations.signup_tab')} value='register' />
            <Tab label={t('passwords.reset_tab')} value='password' />
          </TabList>
        <TabPanel value='login'>
        <Grid container>
          {emailField}
          <Grid item xs={12} sm={9}>
              <TextField
                label='Password'
                id='password'
                value={password}
                variant='standard'
                onChange={event => setPassword(event.target.value)}
                onKeyDown={submitOnEnter}
                type={showPassword ? 'text' : 'password'}
                InputProps={{
                  endAdornment:(
                  <InputAdornment position="end">
                    <IconButton
                      aria-label="toggle password visibility"
                      onClick={() => {
                        setShowPassword(!showPassword);
                      }}
                      onMouseDown={event => {
                        event.preventDefault;
                      }}
                      size="large"
                    >
                      {showPassword ? <Visibility /> : <VisibilityOff />}
                    </IconButton>
                  </InputAdornment>

                  )
                }}
              />
          </Grid>
        </Grid>
        {enterLoginBtn}
        {clearBtn}
        {oauthBtn}
        </TabPanel>
        <TabPanel value="register" >
        <Grid container>
          {emailField}
          {registerBtn}
          {clearBtn}
          </Grid>
        </TabPanel>
        <TabPanel value="password" >
        <Grid container>
          {emailField}
          {clearBtn}
          </Grid>
        </TabPanel>
        </TabsContext>
      </Paper>
    );

  }
}
SignIn.propTypes = {};
