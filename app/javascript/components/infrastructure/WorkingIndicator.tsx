import React, { useState, useEffect } from "react";
import LinearProgress from "@material-ui/core/LinearProgress";
import PropTypes from "prop-types";
import { useStatusStore } from "./StatusStore";
import {useSelector} from 'react-redux';

export default function WorkingIndicator(props) {
  const [status, statusActions] = useStatusStore();

  const working = useSelector( state =>{
    let accum = 0;
    if( undefined === props.identifier ){
      accum = state.tasks[ props.identifier ];
    } else {
      accum = Number(
        Object.values( state.tasks ).reduce(
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
