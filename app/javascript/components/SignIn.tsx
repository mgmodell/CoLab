import React, { Suspense, useState } from "react";
import { Navigate, useNavigate, useLocation } from "react-router";
//Redux store stuff
import { useDispatch } from "react-redux";
import { Priorities, addMessage } from "./infrastructure/StatusSlice";
import EmailValidator from "email-validator";


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
import { Container, Col, Row } from "react-grid-system";
import { FloatLabel } from "primereact/floatlabel";
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
      <Row>

        <Col xs={12} sm={12}>
          <FloatLabel>
            <InputText
              id="first_name"
              value={firstName}
              onChange={event => setFirstName(event.target.value)}
            />
            <label htmlFor="first_name">{t("registrations.first_name_fld")}</label>
          </FloatLabel>

        </Col>
      </Row>
      <Row>

        <Col xs={12} sm={12}>
          <FloatLabel>
            <InputText
              id="last_name"
              value={lastName}
              onChange={event => setLastName(event.target.value)}
            />
            <label htmlFor="last_name">{t("registrations.last_name_fld")}</label>
          </FloatLabel>

        </Col>
      </Row>
      <Row>

        <Col xs={12} sm={12}>
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

        </Col>
      </Row>
    </React.Fragment>
  );

  const passwordResetBtn = (
    <Col xs={12} sm={6}>
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
    </Col>
  );

  const clearBtn = (
    <Col xs={12} sm={6}>
      <Button
        disabled={"" === email && "" === password}
        onClick={() => {
          setPassword("");
          setEmail("");
        }}
      >
        {t("reset_btn")}
      </Button>
    </Col>
  );

  const get_token_from_oauth = response => {
    dispatch(oAuthSignIn(response.credential));
  };

  const oauthBtn = (
    <Col xs={12}>
      <GoogleLogin
        onSuccess={get_token_from_oauth}
        onError={() => {
          console.log("Login Failed");
        }}
        useOneTap
        context="use"
        text="continue_with"
      />
    </Col>
  );

  const emailField = (
    <Col xs={12}>
      <FloatLabel>
        <InputText
          id="email"
          autoFocus
          value={email}
          onChange={event => setEmail(event.target.value)}
        />
        <label htmlFor="email">{t("email_fld")}</label>
      </FloatLabel>
    </Col>
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
                <Container fluid>
                  <Row>
                    {emailField}
                  </Row>
                  <Row>
                    <Col xs={12} >
                      <FloatLabel>
                        <Password
                          inputId="password"
                          feedback={false}
                          value={password}
                          onChange={event => setPassword(event.target.value)}
                          onKeyDown={submitOnEnter}
                          toggleMask
                        />
                        <label htmlFor="password">{t("password_fld")}</label>
                      </FloatLabel>
                    </Col>
                  </Row>
                  <Row>
                    {enterLoginBtn}
                    {clearBtn}
                  </Row>
                  <Row>
                    {oauthBtn}
                  </Row>
                </Container>
              </TabPanel>
              <TabPanel
                header={t("registrations.signup_tab")} >
                <Container>
                  <Row>
                    {emailField}
                  </Row>
                  {registerBlock}
                  <Row>
                    {clearBtn}
                  </Row>
                </Container>
              </TabPanel>
              <TabPanel
                header={t("passwords.reset_tab")} >
                <Container>
                  <Row>
                    {emailField}
                  </Row>
                  <Row>
                    {passwordResetBtn}
                    {clearBtn}
                  </Row>
                </Container>
              </TabPanel>
            </TabView>
          </Panel>
        </GoogleOAuthProvider>
      </Suspense>
    );
  }
}
