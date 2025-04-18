import React, { useEffect } from "react";
import { useDispatch } from "react-redux";
import { useTypedSelector } from "./infrastructure/AppReducers";

import { acknowledgeMsg } from "./infrastructure/StatusSlice";

import { Toast } from "primereact/toast";

export default function AppStatusBar(props) {
  const messages = useTypedSelector(state => {
    return state.status.messages;
  });
  const dispatch = useDispatch();
  const toast = React.useRef(null);

  useEffect(() => {
    messages.forEach((message, index) => {
      if (!message.dismissed) {
        toast.current.show({
          severity: message.priority,
          summary: message.priority,
          detail: message.text,
          life: 30000
        });
        dispatch(acknowledgeMsg(index));
      }
    });
  }, [messages]);

  return <Toast ref={toast} />;
}
