import React, { useState, Suspense } from "react";
import { makeStyles } from "@material-ui/core/styles";
import { BrowserRouter as Router, Switch, Route, Link } from "react-router-dom";
import Skeleton from "@material-ui/lab/Skeleton";
import PropTypes from "prop-types";
import AppHeader from "./AppHeader";
import { ThemeProvider } from "@material-ui/core/styles";
import { createMuiTheme } from "@material-ui/core/styles";

export default function PageWrapper(props) {
  const [helpTopic, setHelpTopic] = useState("");

  return (
    <Suspense fallback={<Skeleton variant="rect" height={50} />}>
      <AppHeader token={props.token} getEndpointsUrl={props.getEndpointsUrl} />
    </Suspense>
  );
}

PageWrapper.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
