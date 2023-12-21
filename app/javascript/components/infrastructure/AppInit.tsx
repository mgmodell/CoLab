import React, { useState, useEffect, Suspense } from "react";
import { useDispatch } from "react-redux";
import { getContext, setInitialised } from "./ContextSlice";
import { cleanUpMsgs } from "./StatusSlice";
import { useTypedSelector } from "./AppReducers";

import PropTypes from "prop-types";
import Skeleton from "@mui/material/Skeleton";

type Props = {
  children?: React.ReactNode;
  endpointsUrl;
};

export default function AppInit(props: Props) {
  const dispatch = useDispatch();

  const initialised = useTypedSelector(
    state => state.context.status.initialised
  );
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const endpoints = useTypedSelector(state => state.context.endpoints);

  useEffect(() => {
    //dispatch( authConfig()  )
    dispatch(getContext(props.endpointsUrl));
  }, []);

  return (
    <Suspense fallback={<Skeleton variant={"rectangular"} />}>
      {props.children}
    </Suspense>
  );
}

AppInit.propTypes = {
  endpointsUrl: PropTypes.string.isRequired
};
