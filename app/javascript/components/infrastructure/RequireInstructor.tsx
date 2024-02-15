import React from "react";
import { Navigate, useLocation } from "react-router-dom";
import { Skeleton } from "primereact/skeleton";
import { useTypedSelector } from "./AppReducers";

export default function RequireInstructor({ children }) {
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const isLoggingIn = useTypedSelector(state => state.context.status.loggingIn);
  const user = useTypedSelector(state => state.profile.user);

  const location = useLocation();

  if (user.is_instructor || user.is_admin) {
    return children;
  } else if (isLoggingIn) {
    return <Skeleton className="mb-2" height={'50rem'} />;
  } else {
    return <Navigate to="/" replace />;
  }
}
