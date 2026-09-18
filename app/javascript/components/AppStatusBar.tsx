import React, { useEffect } from "react";
import { useDispatch } from "react-redux";
import { useTypedSelector } from "./infrastructure/AppReducers";

import { acknowledgeMsg } from "./infrastructure/StatusSlice";

import { Toast } from "primereact/toast";

type AppMessage = {
  text: string;
  priority: "error" | "info" | "warning";
  dismissed: boolean;
};

export default function AppStatusBar() {
  const messages = useTypedSelector((state): AppMessage[] => {
    return state.status.messages ?? [];
  });
  const dispatch = useDispatch();
  const toast = React.useRef<any>(null);

  useEffect(() => {
    messages.forEach((message: AppMessage, index: number) => {
      if (!message.dismissed) {
        if (toast.current) {
          toast.current.show({
            severity: message.priority,
            summary: message.priority,
            detail: message.text,
            life: 30000
          });
        }
        dispatch(acknowledgeMsg(index));
      }
    });
  }, [dispatch, messages]);

  return (
    <>
      <Toast ref={toast} />
    </>
  );
}
