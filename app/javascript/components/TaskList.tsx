import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import PropTypes from "prop-types";
import Paper from "@mui/material/Paper";
import Link from "@mui/material/Link";
import { DateTime, Settings } from "luxon";

import { iconForType } from "./ActivityLib";

import MUIDataTable from "mui-datatables";
import { useTypedSelector } from "./infrastructure/AppReducers";
import Logo from "./Logo";

export default function TaskList(props) {
  //const endpointSet = "home";
  //const endpoints = useTypedSelector(state=>state['context'].endpoints[endpointSet])
  //const endpointStatus = useTypedSelector(state=>state['context'].endpointsLoaded)
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );
  const navigate = useNavigate();

  const columns = [
    {
      label: "Type",
      name: "type",
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          return iconForType( value );
        },
        customFilterListOptions: {
          render: value => {
            return iconForType( value );
          }
        },
        filterOptions: {
          names: ["Bingo Games", "Assessments", "Experiences"],
          logic: (location, filters) => {
            switch (location) {
              case "Bingo Games":
                return filters.includes("bingo_game");
                break;
              case "Assessments":
                return filters.includes("assessment");
                break;
              case "Experience":
                return filters.includes("experience");
                break;
              case "Assignment":
                return filters.includes("assignment");
                break;
              default:
                console.log("filter not found: " + location);
            }

            return false;
          }
        }
      }
    },
    {
      label: "Task",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Course Name",
      name: "course_name"
    },
    {
      label: "Group Name",
      name: "group_name"
    },
    {
      label: "Status",
      name: "status",
      options: {
        filter: false,
        display: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          var output = value + "%";
          if (tableMeta.rowData[0] == "assessment") {
            if (0 == value) {
              output = "Not Completed";
            } else {
              output = "Completed";
            }
          }

          return <span>{output}</span>;
        }
      }
    },
    {
      label: "Open Date",
      name: "start_date",
      options: {
        filter: false,
        display: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          var retVal = <div></div>;
          if (null !== value) {
            const dt = value.setZone(tz_hash[user.timezone]);
            retVal = (
              <span>
                {dt.toLocaleString(DateTime.DATETIME_MED)} ({dt.zoneName} )
              </span>
            );
          }
          return retVal;
        }
      }
    },
    {
      label: "Close Date",
      name: "next_date",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          var retVal = <div></div>;
          if (null !== value) {
            const dt = value.setZone(tz_hash[user.timezone]);
            retVal = <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
          }
          return retVal;
        }
      }
    },
    {
      label: "Consent Form",
      name: "consent_link",
      options: {
        filter: false,
        display: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const consent =
            null == value ? (
              <span>Not for Research</span>
            ) : (
              <Link href={value}>Research Consent Form</Link>
            );

          return consent;
        }
      }
    }
  ];

  useEffect(() => {
    if (null !== user.lastRetrieved && null !== tz_hash) {
      Settings.defaultZoneName = tz_hash[user.timezone];
    }
  }, [user.lastRetrieved, tz_hash]);

  const muiDatTab =
    null !== user.lastRetrieved && null !== tz_hash ? (
      <MUIDataTable
        title="Tasks"
        data={props.tasks}
        columns={columns}
        options={{
          responsive: "standard",
          filterType: "checkbox",
          print: false,
          download: false,
          onRowClick: (rowData, rowState) => {
            const link = props.tasks[rowState.dataIndex].link;
            if (null != link) {
              // window.location.href = link;
              navigate(link);
            }
          },
          selectableRows: "none"
        }}
      />
    ) : (
      <Logo height={100} width={100} spinning />
    );
  return (
    <Paper>
      <div style={{ maxWidth: "100%" }}>{muiDatTab}</div>
    </Paper>
  );
}

TaskList.propTypes = {
  tasks: PropTypes.array.isRequired
};
