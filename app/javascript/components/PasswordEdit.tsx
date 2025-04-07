import React, { useState } from "react";
import axios from "axios";
import { useDispatch } from "react-redux";
import { Priorities, addMessage } from "./infrastructure/StatusSlice";

import { Panel } from "primereact/panel";

import { useSearchParams, useNavigate, useLocation } from "react-router";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { emailSignIn } from "./infrastructure/ContextSlice";
import { Password } from "primereact/password";
import { Button } from "primereact/button";
import { Col, Container, Row } from "react-grid-system";
import { FloatLabel } from "primereact/floatlabel";

export default function PasswordEdit(props) {
  const dispatch = useDispatch();
  const category = "devise";
  const { t, i18n } = useTranslation(category);
  const [showPassword, setShowPassword] = useState(false);
  const [password, setPassword] = useState("");
  const [passwordConfirm, setPasswordConfirm] = useState("");
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const { state } = useLocation();

  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const profileEndpoints = useTypedSelector(
    state => state.context.endpoints["profile"]
  );

  const from = undefined != state ? state.from : "/home";

  //Code to trap an 'enter' press and submit
  //It gets placed on the password field
  const submitOnEnter = evt => {
    if (endpointsLoaded && evt.key === "Enter") {
      dispatch(emailSignIn({ email: string, password: string })).then(() => {
        navigate(from);
      });
      evt.preventDefault();
    }
  };

  const updatePasswordBtn = (
    <Button
      disabled={
        "" === password ||
        "" === passwordConfirm ||
        passwordConfirm !== password ||
        !endpointsLoaded
      }
      onClick={() => {
        const url = profileEndpoints.passwordUpdateUrl + ".json";

        axios
          .patch(url, {
            password: password,
            password_confirmation: passwordConfirm,
            reset_password_token: params.get("reset_password_token")
          })
          .then(resp => {
            const data = resp.data;
            const priority = data.error ? Priorities.ERROR : Priorities.INFO;
            dispatch(addMessage(t(data.message), new Date(), priority));
            navigate("/");
          })
          .catch(error => {
            console.log("error", error);
          });
      }}
    >
      {t("passwords.change_submit")}
    </Button>
  );
  return (
    <Panel>
      <Container>
        <Row>
          <Col xs={12}>
            <FloatLabel>
              <Password
                id="password"
                value={password}
                onChange={event => setPassword(event.target.value)}
                toggleMask
              />
              <label htmlFor="password">{t("passwords.new")}</label>
            </FloatLabel>
          </Col>
          <Col xs={12}>
            <FloatLabel>
              <Password
                id="passwordConfirm"
                value={passwordConfirm}
                onChange={event => setPasswordConfirm(event.target.value)}
                onKeyDown={submitOnEnter}
                toggleMask
              />
              <label htmlFor="password">{t("passwords.confirm")}</label>
            </FloatLabel>
          </Col>
        </Row>
      </Container>
    </Panel>
  );
}
