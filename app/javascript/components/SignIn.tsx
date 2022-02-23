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
//import { useTranslation } from 'react-i18next';
import Grid from "@mui/material/Grid";
import Input from "@mui/material/Input";
//import {emailSignIn, oAuthSignIn, signOut } from './infrastructure/AuthenticationActions';
import { emailSignIn, oAuthSignIn } from "./infrastructure/ContextActions";
import { GoogleLogin } from "react-google-login";
import { useTypedSelector } from "./infrastructure/AppReducers";
import Skeleton from "@mui/material/Skeleton";

export default function SignIn(props) {
  //const { t, i18n } = useTranslation('schools' );

  const dispatch = useDispatch();
  const { state } = useLocation();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const loggingIn = useTypedSelector(state => state.context.status.loggingIn);

  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const oauth_client_ids = useTypedSelector(
    state => state.context.lookups["oauth_ids"]
  );

  const signOutBtn = (
    <Button
      disabled={false}
      variant="contained"
      onClick={() => {
        //dispatch( signOut( email, password ) )
      }}
    >
      Log Out
    </Button>
  );

  const from = undefined != state ? state.from : "/";

  const enterLoginBtn = (
    <Button
      disabled={"" === email || "" === password || !endpointsLoaded}
      variant="contained"
      onClick={() => {
        dispatch(emailSignIn(email, password)).then(navigate(from));
      }}
    >
      Log in
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

  if (loggingIn) {
    return <Skeleton variant="rectangular" height="300" />;
  } else if (isLoggedIn) {
    return <Navigate replace to={state.from || "/"} />;
  }

  return (
    <Paper>
      <Grid container>
        <Grid item xs={12}>
          <FormControl>
            <InputLabel htmlFor="email">Email</InputLabel>
            <Input
              id="email"
              type="text"
              value={email}
              onChange={event => setEmail(event.target.value)}
            />
          </FormControl>
        </Grid>
        <Grid item xs={12} sm={9}>
          <FormControl>
            <InputLabel htmlFor="password">Password</InputLabel>
            <Input
              id="password"
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={event => setPassword(event.target.value)}
              endAdornment={
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
SignIn.propTypes = {};
