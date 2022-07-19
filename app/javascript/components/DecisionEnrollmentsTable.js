/* eslint-disable no-console */
import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import Fab from "@mui/material/Fab";
import withStyles from "@mui/styles/withStyles";
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
import { useTranslation } from "react-i18next";

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
export default function DecisionEnrollmentsTable(props) {
  const category = "admin";
  const { t } = useTranslation(category);

  const [requests_raw, setRequestsRaw] = useState([]);
  const [requests, setRequests] = useState([]);
  const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState("course_number");
  const [working, setWorking] = useState(true);
  const [sortDirection, setSortDirection] = useState(SortDirection.DESC);
  const columns = [
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
      label: t("accept_decline"),
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
                  decision(id, true);
                }}
                aria-label="Accept"
                label="Accept"
                size="small"
                disabled={working}
              >
                <ThumbUpIcon />
              </Fab>
            </Tooltip>

            <Tooltip title="Reject" aria-label="reject">
              <Fab
                onClick={() => {
                  decision(id, false);
                }}
                aria-label="Reject"
                label="Reject"
                size="small"
                disabled={working}
              >
                <ThumbDownIcon />
              </Fab>
            </Tooltip>
          </React.Fragment>
        );
      }
    }
  ];

  useEffect(() => {
    //Retrieve requests
    getRequests();
  }, []);

  const getRequests = () => {
    const url = `${props.init_url}.json`;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setRequests(data);
        setRequestsRaw(data);
        setWorking(false);
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      });
  };
  const filter = event => {
    var filtered = requests_raw.filter(
      request =>
        null != request &&
        request.first_name.includes(event.target.value.toUpperCase())
    );
    setRequests(filtered);
  };

  const colSort = event => {
    let tmpArray = requests_raw;
    let direction = SortDirection.DESC;
    let mod = 1;
    if (event.sortBy == sortBy && direction == sortDirection) {
      direction = SortDirection.ASC;
      mod = -1;
    }
    tmpArray.sort((a, b) => {
      const a_prime = a[event.sortBy] == null ? "" : a[event.sortBy];
      const b_prime = b[event.sortBy] == null ? "" : b[event.sortBy];
      return mod * a_prime.localeCompare(b_prime);
    });
    setRequests(tmpArrayp);
    setSortDirection(direction);
    setSortBy(event.sortBy);
  };

  const decision = (id, accept) => {
    setWorking(true);
    const url = props.update_url + ".json";
    axios
      .patch(url, {
        roster_id: id,
        decision: accept
      })
      .then(response => {
        const data = response.data;
        setRequests(data);
        setRequestsRaw(data);
        setWorking(false);
      })
      .catch(error => {
        const fail_data = new Object();
        fail_data.notice = "The operation failed";
        fail_data.success = false;
        console.log("error", error);
        return fail_data;
      });
  };

  return 0 < requests.length ? (
    <Paper style={{ height: 450, width: "100%" }}>
      <h1>Decision Enrollment Requests</h1>
      <p>
        The following students are trying to enroll in your course. Please
        accept or decline each enrollment.
      </p>
      <Toolbar>
        <InputBase placeholder="Search requests" onChange={filter} />
        <SearchIcon />
        <Typography color="inherit">
          Showing {requests.length} of {requests_raw.length}
        </Typography>
      </Toolbar>
      <WorkingIndicator identifier="loading_enrollments" />
      <WrappedVirtualizedTable
        rowCount={requests.length}
        rowGetter={({ index }) => requests[index]}
        sort={colSort}
        sortBy={sortBy}
        sortDirection={sortDirection}
        columns={columns}
      />
    </Paper>
  ) : null;
}
DecisionEnrollmentsTable.propTypes = {
  init_url: PropTypes.string.isRequired,
  update_url: PropTypes.string.isRequired
};
