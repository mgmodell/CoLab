import React from "react";
import { Navigate, useLocation } from "react-router";
import { useTypedSelector } from "./AppReducers";
import { Skeleton } from "primereact/skeleton";

export default function RequireAuth({ children }) {
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const isLoggingIn = useTypedSelector(state => state.context.status.loggingIn);
  const location = useLocation();

  if (isLoggedIn) {
    return children;
  } else if (isLoggingIn) {
    return <Skeleton className={"mb-2"} height={"30rem"} />;
  } else {
    return (
      <Navigate
        to="/welcome/login"
        replace
        state={{
          from: location.pathname
        }}
      />
    );
  }
}
