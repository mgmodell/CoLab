import React from "react"
import PropTypes from "prop-types"
import FullCalendar from '@fullcalendar/react'
import dayGridPlugin from '@fullcalendar/daygrid'
import momentPlugin from '@fullcalendar/moment'

class CourseCalendar extends React.Component {
  render () {
    return (
      <FullCalendar
        defaultView="dayGridMonth"
        plugins={[ dayGridPlugin ]}
      />
    );
  }
}

CourseCalendar.propTypes = {
  dataUrl: PropTypes.string
};
export default CourseCalendar
