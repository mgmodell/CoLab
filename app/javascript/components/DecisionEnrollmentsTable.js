/* eslint-disable no-console */
import React from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import Fab from "@mui/material/Fab";
import withStyles from '@mui/styles/withStyles';
import Paper from "@mui/material/Paper";
import InputBase from "@mui/material/InputBase";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import SearchIcon from "@mui/icons-material/Search";
import Toolbar from "@mui/material/Toolbar";
import Tooltip from "@mui/material/Tooltip";
import Typography from "@mui/material/Typography";
import { SortDirection } from "react-virtualized";
import WrappedVirtualizedTable from "../components/WrappedVirtualizedTable";

import ThumbDownIcon from "@mui/icons-material/ThumbDown";
import ThumbUpIcon from "@mui/icons-material/ThumbUp";
import axios from "axios";

const styles = theme => ({
  table: {
    fontFamily: theme.typography.fontFamily
  },
  flexContainer: {
    display: "flex",
    alignItems: "center",
    boxSizing: "border-box"
  },
  tableRow: {
    cursor: "pointer"
  },
  tableRowHover: {
    "&:hover": {
      backgroundColor: theme.palette.grey[200]
    }
  },
  tableCell: {
    flex: 1
  },
  noClick: {
    cursor: "initial"
  }
});
class DecisionEnrollmentsTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      requests_raw: [],
      requests: [],
      search: "",
      sortBy: "course_number",
      working: true,
      sortDirection: SortDirection.DESC,
      columns: [
        {
          width: 100,
          label: "First Name",
          dataKey: "first_name",
          numeric: false,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          label: "Last Name",
          dataKey: "last_name",
          numeric: false,
          disableSort: false,
          visible: true
        },
        {
          width: 200,
          flexGrow: 1.0,
          label: "Course Name",
          dataKey: "course_name",
          numeric: false,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          label: "Course Number",
          dataKey: "course_number",
          numeric: false,
          disableSort: false,
          visible: true
        },
        {
          width: 100,
          label: "Accept/Decline",
          dataKey: "id",
          numeric: false,
          disableSort: false,
          visible: true,
          formatter: data => {
            const id = data;
            return (
              <React.Fragment>
                <Tooltip title="Accept" aria-label="accept">
                  <Fab
                    onClick={() => {
                      this.decision(id, true);
                    }}
                    aria-label="Accept"
                    size="small"
                    disabled={this.state.working}
                  >
                    <ThumbUpIcon />
                  </Fab>
                </Tooltip>

                <Tooltip title="Reject" aria-label="reject">
                  <Fab
                    onClick={() => {
                      this.decision(id, false);
                    }}
                    aria-label="Reject"
                    size="small"
                    disabled={this.state.working}
                  >
                    <ThumbDownIcon />
                  </Fab>
                </Tooltip>
              </React.Fragment>
            );
          }
        }
      ]
    };
    this.filter = this.filter.bind(this);
    this.colSort = this.colSort.bind(this);
  }
  componentDidMount() {
    //Retrieve requests
    this.getRequests();
  }
  getRequests() {
    const url = `${this.props.init_url}.json`
    axios.get( url, { } )
      .then(response => {
        const data = response.data;
        this.setState({
          requests: data,
          requests_raw: data,
          working: false
        });
      })
      .catch( error =>{
          console.log("error", error );
          return [{ id: -1, name: "no data" }];
      });
  }
  filter = function(event) {
    var filtered = this.state.requests_raw.filter(
      request =>
        null != request &&
        request.first_name.includes(event.target.value.toUpperCase())
    );
    this.setState({ requests: filtered });
  };

  colSort = function(event) {
    let tmpArray = this.state.requests_raw;
    let direction = SortDirection.DESC;
    let mod = 1;
    if (
      event.sortBy == this.state.sortBy &&
      direction == this.state.sortDirection
    ) {
      direction = SortDirection.ASC;
      mod = -1;
    }
    tmpArray.sort((a, b) => {
      const a_prime = a[event.sortBy] == null ? "" : a[event.sortBy];
      const b_prime = b[event.sortBy] == null ? "" : b[event.sortBy];
      return mod * a_prime.localeCompare(b_prime);
    });
    this.setState({
      requests: tmpArray,
      sortDirection: direction,
      sortBy: event.sortBy
    });
  };

  decision(id, accept) {
    this.setState({ working: true });
    const url = this.props.update_url + ".json";
    axios.patch( url, {
        roster_id: id,
        decision: accept
    })
      .then(response => {
        const data = response.data;
        this.setState({
          requests: data,
          requests_raw: data,
          working: false
        });
      })
      .catch( error=>{
          const fail_data = new Object();
          fail_data.notice = "The operation failed";
          fail_data.success = false;
          console.log("error", error);
          return fail_data;
      });
  }

  render() {
    if (0 < this.state.requests.length) {
      return (
        <Paper style={{ height: 450, width: "100%" }}>
          <h1>Decision Enrollment Requests</h1>
          <p>
            The following students are trying to enroll in your course. Please accept or decline each enrollment.
          </p>
          <Toolbar>
            <InputBase placeholder="Search requests" onChange={this.filter} />
            <SearchIcon />
            <Typography color="inherit">
              Showing {this.state.requests.length} of{" "}
              {this.state.requests_raw.length}
            </Typography>
          </Toolbar>
          <WorkingIndicator identifier="loading_enrollments" />
          <WrappedVirtualizedTable
            rowCount={this.state.requests.length}
            rowGetter={({ index }) => this.state.requests[index]}
            sort={this.colSort}
            sortBy={this.state.sortBy}
            sortDirection={this.state.sortDirection}
            columns={this.state.columns}
          />
        </Paper>
      );
    } else {
      return null;
    }
  }
}
DecisionEnrollmentsTable.propTypes = {
  init_url: PropTypes.string.isRequired,
  update_url: PropTypes.string.isRequired,
};

export default DecisionEnrollmentsTable;
