/* eslint-disable no-console */
import React from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import Fab from "@material-ui/core/Fab";
import { withStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import InputBase from "@material-ui/core/InputBase";
import WorkingIndicator from './infrastructure/WorkingIndicator';
import SearchIcon from "@material-ui/icons/Search";
import Toolbar from "@material-ui/core/Toolbar";
import Tooltip from "@material-ui/core/Tooltip";
import Typography from "@material-ui/core/Typography";
import { SortDirection } from "react-virtualized";
import WrappedVirtualizedTable from "../components/WrappedVirtualizedTable";

import ThumbDownIcon from "@material-ui/icons/ThumbDown";
import ThumbUpIcon from "@material-ui/icons/ThumbUp";

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
    fetch(this.props.init_url + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        this.setState({
          requests: data,
          requests_raw: data,
          working: false
        });
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
    fetch(this.props.update_url + ".json", {
      method: "PATCH",
      credentials: "include",
      body: JSON.stringify({
        roster_id: id,
        decision: accept
      }),
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          const fail_data = new Object();
          fail_data.notice = "The operation failed";
          fail_data.success = false;
          console.log("error");
          return fail_data;
        }
      })
      .then(data => {
        this.setState({
          requests: data,
          requests_raw: data,
          working: false
        });
      });
  }

  render() {
    if (0 < this.state.requests.length) {
      return (
        <Paper style={{ height: 450, width: "100%" }}>
          <Toolbar>
            <InputBase placeholder="Search requests" onChange={this.filter} />
            <SearchIcon />
            <Typography color="inherit">
              Showing {this.state.requests.length} of{" "}
              {this.state.requests_raw.length}
            </Typography>
          </Toolbar>
          <WorkingIndicator identifier='loading_enrollments' />
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
  token: PropTypes.string.isRequired
};

export default DecisionEnrollmentsTable;
