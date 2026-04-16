import React from "react";
import { useTypedSelector } from "./AppReducers";
import { ProgressBar } from "primereact/progressbar";

type Props = {
  identifier?: string;
};
export default function WorkingIndicator(props: Props) {
  const working = useTypedSelector(state => {
    let accum = 0;
    if (undefined === props.identifier) {
      accum = Number(
        Object.values(state.status.tasks).reduce((accum, nextVal) => {
          return Number(accum) + Number(nextVal);
        }, accum)
      );
    } else {
      accum = state.status.tasks[props.identifier];
    }
    return accum;
  });

  return working > 0 ? (
    <ProgressBar
      mode="indeterminate"
      style={{ height: "6px", width: "100%" }}
      id={props.identifier || "waiting"}
    />
  ) : null;
}
