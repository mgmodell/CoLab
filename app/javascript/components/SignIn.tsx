import React, { Suspense, useState } from "react";
import { Navigate, useNavigate, useLocation } from "react-router-dom";
//Redux store stuff
import { useDispatch } from "react-redux";
import { Priorities, addMessage } from "./infrastructure/StatusSlice";
import EmailValidator from "email-validator";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import IconButton from "@mui/material/IconButton";
import InputAdornment from "@mui/material/InputAdornment";
import Paper from "@mui/material/Paper";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import Visibility from "@mui/icons-material/Visibility";
import Grid from "@mui/material/Grid";
import Skeleton from "@mui/material/Skeleton";
import Tab from "@mui/material/Tab";

import { useTranslation } from "react-i18next";
//import {emailSignIn, oAuthSignIn, signOut } from './infrastructure/AuthenticationActions';
import {
  emailSignIn,
  oAuthSignIn,
  emailSignUp
} from "./infrastructure/ContextSlice";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { TabContext, TabPanel, TabList } from "@mui/lab";
import axios from "axios";

import { GoogleOAuthProvider, GoogleLogin } from "@react-oauth/google";
export default function SignIn(props) {
  const category = "devise";
  const { t }: { t: any } = useTranslation(category);

  const dispatch = useDispatch();
  const { state } = useLocation();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const loggingIn = useTypedSelector(state => state.context.status.loggingIn);
  const [curTab, setCurTab] = useState("login");

  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const profileEndpoints = useTypedSelector(
    state => state.context.endpoints["profile"]
  );
  const oauth_client_ids = useTypedSelector(
    state => state.context.lookups["oauth_ids"]
  );

  const from = undefined != state ? state.from : "/home";

  //Code to trap an 'enter' press and submit
  //It gets placed on the password field
  const submitOnEnter = evt => {
    if (endpointsLoaded && evt.key === "Enter") {
      dispatch(emailSignIn({ email, password })).then(navigate(from));
      evt.preventDefault();
    }
  };

  const enterLoginBtn = (
    <Button
      disabled={
        "" === email ||
        "" === password ||
        !endpointsLoaded ||
        !EmailValidator.validate(email)
      }
      variant="contained"
      onClick={() => {
        dispatch(emailSignIn({ email, password })).then(navigate(from));
      }}
    >
      {t("sessions.login_submit")}
    </Button>
  );

  const registerBlock = (
    <React.Fragment>
      <Grid item xs={12} sm={6}>
        <TextField
          label={t("registrations.first_name_fld")}
          id="first_name"
          value={firstName}
          onChange={event => setFirstName(event.target.value)}
          variant="standard"
        />
      </Grid>
      <Grid item xs={12} sm={6}>
        <TextField
          label={t("registrations.last_name_fld")}
          id="last_name"
          value={lastName}
          onChange={event => setLastName(event.target.value)}
          variant="standard"
        />
      </Grid>
      <Grid item xs={12} sm={6}>
        <Button
          disabled={"" === email || !endpointsLoaded}
          variant="contained"
          onClick={() => {
            dispatch(
              emailSignUp({
                email,
                firstName,
                lastName
              })
            ).then(navigate(from));
          }}
        >
          {t("registrations.signup_btn")}
        </Button>
      </Grid>
    </React.Fragment>
  );

  const passwordResetBtn = (
    <Grid item xs={12} sm={6}>
      <Button
        disabled={"" === email || !endpointsLoaded}
        variant="contained"
        onClick={() => {
          const url = profileEndpoints.passwordResetUrl + ".json";

          axios
            .post(url, {
              email: email
            })
            .then(resp => {
              const data = resp.data;
              dispatch(
                addMessage(t(data.message), new Date(), Priorities.INFO)
              );
            })
            .catch(error => {
              console.log("error", error);
            });
        }}
      >
        {t("passwords.forgot_submit")}
      </Button>
    </Grid>
  );

  const clearBtn = (
    <Grid item xs={12} sm={6}>
      <Button
        disabled={"" === email && "" === password}
        variant="contained"
        onClick={() => {
          setPassword("");
          setEmail("");
        }}
      >
        {t("reset_btn")}
      </Button>
    </Grid>
  );

  const get_token_from_oauth = response => {
    dispatch(oAuthSignIn(response.credential));
  };

  const oauthBtn = (
    <GoogleLogin
      onSuccess={get_token_from_oauth}
      onError={() => {
        console.log("Login Failed");
      }}
      useOneTap
      context="use"
      text="continue_with"
    />
  );

  const emailField = (
    <Grid item xs={12}>
      <TextField
        label={t("email_fld")}
        id="email"
        autoFocus
        value={email}
        onChange={event => setEmail(event.target.value)}
        error={"" !== email && !EmailValidator.validate(email)}
        helperText={
          "" === email || EmailValidator.validate(email)
            ? null
            : "Must be a valid email address"
        }
        variant="standard"
      />
    </Grid>
  );

  if (loggingIn || oauth_client_ids === undefined) {
    return <Skeleton variant="rectangular" height="300" />;
  } else if (isLoggedIn) {
    return <Navigate replace to={state?.from || "/home"} />;
  } else {
    return (
      <Suspense fallback={<Skeleton variant={"rectangular"} height="300" />}>
        <GoogleOAuthProvider clientId={oauth_client_ids["google"]}>
          <Paper>
            <TabContext value={curTab}>
              <TabList
                onChange={(evt, newVal) => {
                  setCurTab(newVal);
                }}
              >
                <Tab label={t("sessions.login")} value="login" />
                <Tab label={t("registrations.signup_tab")} value="register" />
                <Tab label={t("passwords.reset_tab")} value="password" />
              </TabList>
              <TabPanel value="login">
                <Grid container>
                  {emailField}
                  <Grid item xs={12} sm={9}>
                    <TextField
                      label="Password"
                      id="password"
                      value={password}
                      variant="standard"
                      onChange={event => setPassword(event.target.value)}
                      onKeyDown={submitOnEnter}
                      type={showPassword ? "text" : "password"}
                      InputProps={{
                        endAdornment: (
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
                              {showPassword ? (
                                <Visibility />
                              ) : (
                                <VisibilityOff />
                              )}
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
              <TabPanel value="register">
                <Grid container>
                  {emailField}
                  {registerBlock}
                  {clearBtn}
                </Grid>
              </TabPanel>
              <TabPanel value="password">
                <Grid container>
                  {emailField}
                  {passwordResetBtn}
                  {clearBtn}
                </Grid>
              </TabPanel>
            </TabContext>
          </Paper>
        </GoogleOAuthProvider>
      </Suspense>
    );
  }
}
SignIn.propTypes = {};
