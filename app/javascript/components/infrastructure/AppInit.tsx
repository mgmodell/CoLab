import React, { useEffect, Suspense } from "react";
import { useDispatch } from "react-redux";
import { getContext, setDebug } from "./ContextSlice";
import { useTypedSelector } from "./AppReducers";

import { Skeleton } from "primereact/skeleton";

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

  const endpoints = useTypedSelector(state => state.context.endpoints);

  useEffect(() => {
    //dispatch( authConfig()  )
    dispatch(getContext(props.endpointsUrl));
  }, []);

  useEffect(() => {
    dispatch(setDebug(props.debug));
  }, [props.debug]);

  return (
    <Suspense fallback={<Skeleton className={"mb-2"} />}>
      {props.children}
    </Suspense>
  );
}
