import React, { useState, useEffect } from "react";
import { useHistory } from "react-router-dom";
import PropTypes from "prop-types";
import Paper from "@material-ui/core/Paper";
import Link from "@material-ui/core/Link";
import { DateTime } from "luxon";
import Settings from "luxon/src/settings.js";

import LocalLibraryIcon from "@material-ui/icons/LocalLibrary";
import GridOffIcon from "@material-ui/icons/GridOff";
import TuneIcon from "@material-ui/icons/Tune";

import { useEndpointStore } from "./infrastructure/EndPointStore";
import { useUserStore } from "./infrastructure/UserStore";
import MUIDataTable from "mui-datatables";

export default function TaskList(props) {
  const endpointSet = "home";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();
  const history = useHistory();

  const columns = [
    {
      label: "Type",
      name: "type",
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          var icon;
          if ("experience" == value) {
            icon = <LocalLibraryIcon />;
          } else if ("assessment" == value) {
            icon = <TuneIcon />;
          } else if ("bingo_game" == value) {
            icon = <GridOffIcon />;
          }
          return icon;
        },
        customFilterListOptions: {
          render: value => {
            var icon;
            if ("Experiences" == value) {
              icon = <LocalLibraryIcon />;
            } else if ("Assessments" == value) {
              icon = <TuneIcon />;
            } else if ("Bingo Games" == value) {
              icon = <GridOffIcon />;
            }
            return icon;
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
              default:
                console.log("filter not found: " + location);
            }

            console.log(location, filters);
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
          const dt = DateTime.fromISO(value, {
            zone: Settings.defaultZoneName
          });
          return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
        }
      }
    },
    {
      label: "Close Date",
      name: "end_date",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const dt = DateTime.fromISO(value, {
            zone: Settings.defaultZoneName
          });
          return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
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
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  const muiDatTab = (
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
            history.push(link);
          }
        },
        selectableRows: "none"
      }}
    />
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
