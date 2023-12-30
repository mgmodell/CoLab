import React from "react";
import PropTypes from "prop-types";
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import listPlugin from "@fullcalendar/list";

type Props = {
  dataUrl: string
};
export default function CourseCalendar(props : Props) {
  const header = {
    left: "prev,next today",
    center: "title",
    right: "dayGridWeek,dayGridMonth,listMonth"
  };

  return (
    <FullCalendar
      plugins={[dayGridPlugin, listPlugin]}
      header={header}
      defaultView="dayGridWeek"
      events={props.dataUrl + ".json"}
    />
  );
}
