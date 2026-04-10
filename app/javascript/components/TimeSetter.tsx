import React, { useState, Fragment, useEffect } from "react";
import MockDate from "mockdate";

interface TimeSetterProps {}

export default function TimeSetter(props: TimeSetterProps) {
  const [newTime, setNewTime] = useState("");
  const [hitCount, setHitCount] = useState(0);

  const [date, setDate] = useState(new Date());

  const setTime = () => {
    if (newTime.length > 0) {
      MockDate.set(new Date(newTime));
      setNewTime("");
      setHitCount(hitCount + 1);
    }
  };
  const resetTime = () => {
    MockDate.reset();
  };

  const refreshClock = () => {
    setDate(new Date());
  };

  useEffect(() => {
    const timerId = setInterval(refreshClock, 1000);
    return function cleanup() {
      clearInterval(timerId);
    };
  }, []);

  return (
    <Fragment>
      <input
        id="newTimeVal"
        type="text"
        value={newTime}
        onChange={e => setNewTime(e.target.value)}
      />
      <button id="setTimeBtn" onClick={setTime}>
        Set Time
      </button>
      <button id="resetTimeBtn" onClick={resetTime}>
        reSet Time
      </button>
      {date.toLocaleTimeString()} - {date.toLocaleDateString()} hits: {hitCount}
    </Fragment>
  );
}
