import {
  Paper,
  Grid,
  TextField,
  IconButton,
  InputAdornment,
  Button
} from "@mui/material";
import { useSelector, useDispatch } from "react-redux";
import { Priorities, addMessage } from "./infrastructure/StatusActions";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import Visibility from "@mui/icons-material/Visibility";
import React, { useState } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";

export default function PasswordEdit(props) {
  const dispatch = useDispatch();
  const category = "devise";
  const { t, i18n } = useTranslation(category);
  const [showPassword, setShowPassword] = useState(false);
  const [password, setPassword] = useState("");
  const [passwordConfirm, setPasswordConfirm] = useState("");
  const [params] = useSearchParams();
  const navigate = useNavigate();

  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const profileEndpoints = useTypedSelector(
    state => state.context.endpoints["profile"]
  );

  //Code to trap an 'enter' press and submit
  //It gets placed on the password field
  const submitOnEnter = evt => {
    if (endpointsLoaded && evt.key === "Enter") {
      dispatch(emailSignIn(email, password)).then(navigate(from));
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
      variant="contained"
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
    <Paper>
      <Grid container>
        <h1>{t("change_password_intro")}</h1>
        <Grid item xs={12} sm={9}>
          <TextField
            label="Password"
            id="password"
            value={password}
            variant="standard"
            onChange={event => setPassword(event.target.value)}
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
                    {showPassword ? <Visibility /> : <VisibilityOff />}
                  </IconButton>
                </InputAdornment>
              )
            }}
          />
        </Grid>
        <Grid item xs={12} sm={9}>
          <TextField
            label="Confirm your Password"
            id="passwordConfirm"
            value={passwordConfirm}
            variant="standard"
            onChange={event => setPasswordConfirm(event.target.value)}
            onKeyDown={submitOnEnter}
            type={showPassword ? "text" : "password"}
          />
        </Grid>
        {updatePasswordBtn}
      </Grid>
    </Paper>
  );
}
