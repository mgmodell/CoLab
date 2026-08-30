import React, { useEffect } from "react";
import { useDispatch } from "react-redux";
import { useTypedSelector } from "./infrastructure/AppReducers";

import { acknowledgeMsg } from "./infrastructure/StatusSlice";

import { Toast } from "primereact/toast";

export default function AppStatusBar(props) {
  const messages = useTypedSelector(state => {
    return state.status.messages;
  });
  const hasDirtyChanges = useTypedSelector(state => {
    return Object.values(state.status.dirtyStatus).some(Boolean);
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

  return (
    <>
      <Toast ref={toast} />
      <div
        aria-live="polite"
        style={{
          display: "flex",
          justifyContent: "flex-end",
          alignItems: "center",
          gap: "0.5rem",
          padding: "0.25rem 0.75rem",
          color: hasDirtyChanges ? "#b45309" : "#166534",
          fontSize: "0.8rem",
          fontWeight: 600,
          lineHeight: 1.4
        }}
      >
        <i className={`pi ${hasDirtyChanges ? "pi-exclamation-triangle" : "pi-check-circle"}`} />
        <span>{hasDirtyChanges ? "Unsaved changes" : "Saved"}</span>
      </div>
    </>
  );
}
