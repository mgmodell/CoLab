import React from "react";
import PropTypes from "prop-types";
import Paper from "@material-ui/core/Paper";
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import listPlugin from "@fullcalendar/list";
import momentPlugin from "@fullcalendar/moment";

class CourseCalendar extends React.Component {
  render() {
    const header = {
      left: "prev,next today",
      center: "title",
      right: "dayGridWeek,dayGridMonth,listMonth"
    };

    function clickedMe(event) {
      //TODO: Must do something useful here
      console.log(event);
    }

    return (
      <FullCalendar
        plugins={[dayGridPlugin, listPlugin]}
        header={header}
        eventClick={clickedMe}
        defaultView="dayGridWeek"
        events={this.props.dataUrl + ".json"}
      />
    );
  }
}

CourseCalendar.propTypes = {
  token: PropTypes.string.isRequired,
  dataUrl: PropTypes.string.isRequired
};
export default CourseCalendar;
