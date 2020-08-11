import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Paper from "@material-ui/core/Paper";
import Popover from "@material-ui/core/Popover";

import {useDispatch} from 'react-redux';
import {startTask, endTask} from './infrastructure/StatusActions';
import MUIDataTable from "mui-datatables";

import Link from "@material-ui/core/Link";
import { Container } from "@material-ui/core";

export default function ReactionsList(props) {
  const [anchorEl, setAnchorEl] = useState();
  const [popMsg, setPopMsg] = useState();

  const dispatch = useDispatch( );
  const getReactions = () => {
    var url = props.retrievalUrl + ".json";
    dispatch( startTask() );
    fetch(url, {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        //MetaData and Infrastructure
        props.reactionsListUpdateFunc(data.reactions);

        dispatch( endTask() );
      });
  };

  useEffect(() => {
    if (null == props.reactionsList) {
      getReactions();
    }
  }, []);

  const openPop = (event, msg) => {
    setAnchorEl(event.currentTarget);
    setPopMsg(msg);
  };

  const closePop = () => {
    setAnchorEl(null);
    setPopMsg(null);
  };

  var reactionColumns = [
    {
      label: "Student",
      name: "user",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return <Link href={"mailto:" + value.email}>{value.name}</Link>;
        }
      }
    },
    {
      label: "Email",
      name: "user",
      options: {
        display: false,
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return <Link href={"mailto:" + value.email}>{value.email}</Link>;
        }
      }
    },
    {
      label: "Completion",
      name: "status",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return value + "%";
        }
      }
    },
    {
      label: "Narrative",
      name: "narrative",
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          return value;
        }
      }
    },
    {
      label: "Scenario",
      name: "scenario",
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          return value;
        }
      }
    },
    {
      label: "Response",
      name: "behavior",
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          if ("Other" == value) {
            return (
              <Link
                onClick={event =>
                  openPop(
                    event,
                    props.reactionsList[tableMeta.rowIndex].other_name
                  )
                }
              >
                {value}
              </Link>
            );
          } else {
            return value;
          }
        }
      }
    },
    {
      label: "Improvements",
      name: "improvements",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          if ("" != value) {
            return (
              <Link
                onClick={event =>
                  openPop(
                    event,
                    props.reactionsList[tableMeta.rowIndex].improvements
                  )
                }
              >
                Suggestions
              </Link>
            );
          } else {
            return "N/A";
          }
        }
      }
    }
  ];

  return (
    <Paper>
      {null != props.reactionsList ? (
        <React.Fragment>
          <MUIDataTable
            title="Reactions"
            columns={reactionColumns}
            data={props.reactionsList}
            options={{
              responsive: "standard",
              filterType: "checkbox",
              selectableRows: "none",
              print: false,
              download: false
            }}
          />
          <Popover
            open={Boolean(anchorEl)}
            onClose={closePop}
            anchorEl={anchorEl}
          >
            <Container maxWidth="sm">{popMsg}</Container>
          </Popover>
        </React.Fragment>
      ) : (
        "No reactions yet."
      )}
    </Paper>
  );
}

ReactionsList.propTypes = {
  retrievalUrl: PropTypes.string.isRequired,
  reactionsList: PropTypes.array,
  reactionsListUpdateFunc: PropTypes.func.isRequired
};
