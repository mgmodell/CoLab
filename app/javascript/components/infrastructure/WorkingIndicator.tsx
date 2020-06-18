import React, { useState, useEffect } from "react";
import LinearProgress from '@material-ui/core/LinearProgress';
import PropTypes from "prop-types";
import { useStatusStore } from './StatusStore';

export default function WorkingIndicator(props) {
  const [status, statusActions] = useStatusStore( );

  return ( (undefined === props.identifier && status.working > 0 ) ||
    status.taskStatus[ props.identifier ] > 0 ) ?
    (<LinearProgress id={props.identifier || 'waiting'} />) : null;


}
WorkingIndicator.propTypes = {
  identifier: PropTypes.string
};
