import React, {
  useState,
  Fragment } from "react";
import PropTypes from "prop-types";
import TimeShift from "timeshift";

export default function TimeSetter(props) {
  const [newTime, setNewTime] = useState( '' );

  const setTime = () => {
    Date = TimeShift.Date;
    TimeShift.setTime( newTime );
  }
  const resetTime = ( ) => {
    Date = TimeShift.setTime( undefined );
  }

  return (
    <Fragment>
      <input id='newTimeVal' type='text' value={newTime} onChange={(e)=>setNewTime(e.target.value)}>
      </input>
      <button id='setTimeBtn' onClick={setTime}>Set Time</button>
      <button id='resetTimeBtn' onClick={resetTime}>reSet Time</button>
    </Fragment>
  );
}
TimeSetter.propTypes = {
};
