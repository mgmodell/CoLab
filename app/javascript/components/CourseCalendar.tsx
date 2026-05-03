import React, { useState, useEffect } from "react";
import { Calendar, dayjsLocalizer } from "react-big-calendar";
import dayjs from "dayjs";
import "react-big-calendar/lib/css/react-big-calendar.css";
import axios from "axios";

type Props = {
  dataUrl: string;
};

export default function CourseCalendar(props: Props) {
  const [events, setEvents] = useState([]);

  useEffect(() => {
    axios
      .get(props.dataUrl + ".json")
      .then(response => {
        const data = response.data;
        const mapped = (Array.isArray(data) ? data : data.events || [])
          .filter((ev: { start?: string }): ev is { start: string; title?: string; name?: string; end?: string } =>
            Boolean(ev.start)
          )
          .map((ev: { start: string; title?: string; name?: string; end?: string }) => ({
            title: ev.title || ev.name || "",
            start: new Date(ev.start),
            end: ev.end ? new Date(ev.end) : new Date(ev.start)
          }));
        setEvents(mapped);
      })
      .catch(error => {
        console.error("CourseCalendar fetch error:", error);
      });
  }, [props.dataUrl]);

  return (
    <Calendar
      localizer={dayjsLocalizer(dayjs)}
      events={events}
      defaultView="week"
      views={["week", "month", "agenda"]}
      style={{ height: 600 }}
    />
  );
}
