import React from "react"
import PropTypes from "prop-types"
import Paper from '@material-ui/core/Paper'
import FullCalendar from '@fullcalendar/react'
import dayGridPlugin from '@fullcalendar/daygrid'
import listPlugin from '@fullcalendar/list'
import momentPlugin from '@fullcalendar/moment'


class CourseCalendar extends React.Component {
  render () {
    const header = {
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridMonth, dayGridWeek, listMonth'
        }

    function clickedMe( event ){
      console.log( event )
      console.log( event.title )

    }

    return (
      <FullCalendar
        plugins={[ dayGridPlugin, listPlugin ]}
        header={header}
        eventClick={clickedMe}
        themeSystem='standard'
        events={[
          { title: 'event 1', allDay: true,
            start: '2019-04-22', end: '2019-4-22' },
          { title: 'event 2', allDay: true,
            start: '2019-04-25', end: '2019-4-30' }
        ]}
          
      />
    );
  }
}

CourseCalendar.propTypes = {
  dataUrl: PropTypes.string
};
export default CourseCalendar
