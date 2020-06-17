import React, { useState, useEffect } from "react";
import LinearProgress from '@material-ui/core/LinearProgress';
import PropTypes from "prop-types";
import { useStatusStore } from './StatusStore';

export default function WorkingIndicator(props) {
  const [status, statusActions] = useStatusStore( );

  return status.working ?
    (<LinearProgress id={props.identifier} />) : null;

}
WorkingIndicator.propTypes = {
  identifier: PropTypes.string.isRequired
};
