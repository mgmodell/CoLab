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
  const hasDirtyChanges = useTypedSelector(state => {
    const dirtyStatus = state.status.dirtyStatus as Record<string, boolean>;
    for (const key in dirtyStatus) {
      if (dirtyStatus[key]) {
        return true;
      }
    }
    return false;
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
      <div style={{ display: "flex", justifyContent: "center", width: "100%", padding: "0.5rem 0 0.25rem", position: "relative", zIndex: 1100 }}>
        <div
          aria-live="polite"
          role="status"
          style={{
            display: "inline-flex",
            justifyContent: "center",
            alignItems: "center",
            gap: "0.5rem",
            padding: "0.35rem 0.75rem",
            borderRadius: "999px",
            border: `1px solid ${hasDirtyChanges ? "#f59e0b" : "#16a34a"}`,
            backgroundColor: hasDirtyChanges ? "#fff7ed" : "#f0fdf4",
            color: hasDirtyChanges ? "#b45309" : "#166534",
            fontSize: "0.8rem",
            fontWeight: 600,
            lineHeight: 1.4,
            width: "fit-content",
            position: "relative",
            zIndex: 1101
          }}
        >
          <i className={`pi ${hasDirtyChanges ? "pi-exclamation-triangle" : "pi-check-circle"}`} />
          <span>{hasDirtyChanges ? "Unsaved changes" : "Saved"}</span>
        </div>
      </div>
    </>
  );
}
