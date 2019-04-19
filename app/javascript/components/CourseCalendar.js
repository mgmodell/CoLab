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
          right: 'dayGridMonth,dayGridYear,listMonth'
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
        defaultView='dayGridMonth'
        events={this.props.dataUrl + '.json'}
          
      />
    );
  }
}

CourseCalendar.propTypes = {
  token: PropTypes.string.isRequired,
  dataUrl: PropTypes.string.isRequired
};
export default CourseCalendar
