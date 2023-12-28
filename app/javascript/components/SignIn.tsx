import React, { Suspense, useState } from "react";
import { Navigate, useNavigate, useLocation } from "react-router-dom";
//Redux store stuff
import { useDispatch } from "react-redux";
import { Priorities, addMessage } from "./infrastructure/StatusSlice";
import EmailValidator from "email-validator";

import Grid from "@mui/material/Grid";


import { useTranslation } from "react-i18next";
//import {emailSignIn, oAuthSignIn, signOut } from './infrastructure/AuthenticationActions';
import {
  emailSignIn,
  oAuthSignIn,
  emailSignUp
} from "./infrastructure/ContextSlice";
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";
import { TabView, TabPanel } from "primereact/tabview";
import { Button } from "primereact/button";
import { Skeleton } from "primereact/skeleton";
import { Panel } from "primereact/panel";
import { InputText } from "primereact/inputtext";
import { Password } from "primereact/password";


import { GoogleOAuthProvider, GoogleLogin } from "@react-oauth/google";
export default function SignIn(props) {
  const category = "devise";
  const { t }: { t: any } = useTranslation(category);

  const dispatch = useDispatch();
  const location = useLocation();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const loggingIn = useTypedSelector(state => state.context.status.loggingIn);
  const [curTab, setCurTab] = useState(0);

  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const profileEndpoints = useTypedSelector(
    state => state.context.endpoints["profile"]
  );
  const oauth_client_ids = useTypedSelector(
    state => state.context.lookups["oauth_ids"]
  );

  const from = undefined != location.state?.from ? location.state.from : "/home";

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
        <span className='p-float-label'>
          <InputText
            id="first_name"
            value={firstName}
            onChange={event => setFirstName(event.target.value)}
          />
          <label htmlFor="first_name">{t("registrations.first_name_fld")}</label>
        </span>
      </Grid>
      <Grid item xs={12} sm={6}>
        <span className='p-float-label'>
          <InputText
            id="last_name"
            value={lastName}
            onChange={event => setLastName(event.target.value)}
          />
          <label htmlFor="last_name">{t("registrations.last_name_fld")}</label>
        </span>
      </Grid>
      <Grid item xs={12} sm={6}>
        <Button
          disabled={"" === email || !endpointsLoaded}
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
      <span className='p-float-label'>
        <InputText
          id="email"
          autoFocus
          value={email}
          onChange={event => setEmail(event.target.value)}
        />
        <label htmlFor="email">{t("email_fld")}</label>
      </span>
    </Grid>
  );

  if (loggingIn || oauth_client_ids === undefined) {
    return <Skeleton className="mb-2" height="300" />;
  } else if (isLoggedIn) {
    //return <Navigate replace to={location.state?.from || "/home"} />;
    return <Navigate replace to={from} />;
  } else {
    return (
      <Suspense fallback={<Skeleton className="mb-2" height="300" />}>
        <GoogleOAuthProvider clientId={oauth_client_ids["google"]}>
          <Panel>
            <TabView activeIndex={curTab} >
              <TabPanel
                header={t("sessions.login")}  >
                <Grid container>
                  {emailField}
                  <Grid item xs={12} sm={9}>
                    <span className='p-float-label'>
                      <Password
                        id="password"
                        value={password}
                        onChange={event => setPassword(event.target.value)}
                        onKeyDown={submitOnEnter}
                        toggleMask
                      />
                      <label htmlFor="password">{t("password_fld")}</label>
                    </span>
                  </Grid>
                </Grid>
                {enterLoginBtn}
                {clearBtn}
                {oauthBtn}
              </TabPanel>
              <TabPanel
                header={t("registrations.signup_tab")} >
                <Grid container>
                  {emailField}
                  {registerBlock}
                  {clearBtn}
                </Grid>
              </TabPanel>
              <TabPanel
                header={t("passwords.reset_tab")} >
                <Grid container>
                  {emailField}
                  {passwordResetBtn}
                  {clearBtn}
                </Grid>
              </TabPanel>
            </TabView>
          </Panel>
        </GoogleOAuthProvider>
      </Suspense>
    );
  }
}
SignIn.propTypes = {};
