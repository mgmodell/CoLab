import React, { useEffect, Suspense } from "react";
import { useDispatch } from "react-redux";
import { getContext, setDebug } from "./ContextSlice";
import { useTypedSelector } from "./AppReducers";

import { Skeleton } from "primereact/skeleton";
import { IUser } from "./ProfileSlice";
import chroma from "chroma-js";

type Props = {
  children?: React.ReactNode;
  endpointsUrl: string;
  debug?: boolean;
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
  const user: IUser = useTypedSelector(state => state.profile.user);

  const endpoints = useTypedSelector(state => state.context.endpoints);

  useEffect(() => {
    //dispatch( authConfig()  )
    dispatch(getContext(props.endpointsUrl));
  }, []);

  useEffect(() => {
    //dispatch( authConfig()  )
    const primaryColor =
      user && user.theme ? user.theme : "#007bff";

    document.documentElement.style.setProperty(
      "--tertiary-color",
      chroma( primaryColor ).brighten(2).hex()
    );
    document.documentElement.style.setProperty(
      "--secondary-color",
      chroma( primaryColor ).darken(2).hex()
    );
    document.documentElement.style.setProperty(
      "--primary-color",
      primaryColor
    );
  }, [user]);

  useEffect(() => {
    dispatch(setDebug(props.debug));
  }, [props.debug]);

  return (
    <Suspense fallback={<Skeleton className={"mb-2"} />}>
      {props.children}
    </Suspense>
  );
}
