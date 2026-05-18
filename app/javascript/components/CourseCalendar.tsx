import React, { useState, useEffect } from "react";
import { Calendar, dayjsLocalizer } from "react-big-calendar";
import dayjs from "dayjs";
import "react-big-calendar/lib/css/react-big-calendar.css";
import axios from "axios";

interface IRawEvent {
  title?: string;
  name?: string;
  start: string;
  end?: string;
}

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
          .filter((ev: { start?: string }): ev is IRawEvent => Boolean(ev.start))
          .map((ev: IRawEvent) => ({
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
