import React, {
  useState,
  Fragment, 
  useEffect} from "react";
import PropTypes from "prop-types";
import MockDate from 'mockdate';

export default function TimeSetter(props) {
  const [newTime, setNewTime] = useState( '' );
  const [date, setDate] = useState( new Date( ) );

  const setTime = () => {
    MockDate.set( new Date( newTime ) );
    setNewTime( '' );
  }
  const resetTime = ( ) => {
    MockDate.reset( );
  }

  const refreshClock = () =>{
    setDate( new Date( ) );
  }

  useEffect( ()=>{
    const timerId = setInterval( refreshClock, 1000 );
    return function cleanup( ){
      clearInterval( timerId);
    };
  }, [] );

  return (
    <Fragment>
      <input id='newTimeVal' type='text' value={newTime} onChange={(e)=>setNewTime(e.target.value)}>
      </input>
      <button id='setTimeBtn' onClick={setTime}>Set Time</button>
      <button id='resetTimeBtn' onClick={resetTime}>reSet Time</button>
      {date.toLocaleTimeString( ) }
    </Fragment>
  );
}
TimeSetter.propTypes = {
};
