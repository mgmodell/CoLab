import React, { useState, useEffect } from "react";
import LinearProgress from "@material-ui/core/LinearProgress";
import PropTypes from "prop-types";
import { useTypedSelector } from "./AppReducers";

export default function WorkingIndicator(props) {

  const working = useTypedSelector( (state) =>{
    let accum = 0;
    if( undefined === props.identifier ){
      accum = state.status.tasks[ props.identifier ];
    } else {
      accum = Number(
        Object.values( state.status.tasks ).reduce(
          (accum, nextVal) => {return Number(accum) + Number(nextVal) },
          accum
        )
      )
    }
    return accum;
  })

  return ( working > 0 ? (
    <LinearProgress id={props.identifier || "waiting"} />
  ) : null )
}
WorkingIndicator.propTypes = {
  identifier: PropTypes.string
};
