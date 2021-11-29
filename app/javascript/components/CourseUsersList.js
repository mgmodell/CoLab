import React, { useState, useEffect } from "react";
import {useDispatch} from 'react-redux';
import PropTypes from "prop-types";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Paper from "@material-ui/core/Paper";
import Dialog from "@material-ui/core/Dialog";
import DialogActions from "@material-ui/core/DialogActions";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import DialogTitle from "@material-ui/core/DialogTitle";
import TextField from "@material-ui/core/TextField";
import Button from "@material-ui/core/Button";

import MUIDataTable from "mui-datatables";

import PersonAddIcon from "@material-ui/icons/PersonAdd";

import HelpOutlineIcon from "@material-ui/icons/HelpOutline";
import NotInterestedIcon from "@material-ui/icons/NotInterested";
import CheckCircleOutlineIcon from "@material-ui/icons/CheckCircleOutline";
import SupervisedUserCircleIcon from "@material-ui/icons/SupervisedUserCircle";
import ClearIcon from "@material-ui/icons/Clear";

import EmailIcon from "@material-ui/icons/Email";
import CheckIcon from "@material-ui/icons/Check";
import GroupAddIcon from "@material-ui/icons/GroupAdd";

import Link from "@material-ui/core/Link";
import Tooltip from "@material-ui/core/Tooltip";
import IconButton from "@material-ui/core/IconButton";
import DropUserButton from "./DropUserButton";
import BingoDataRepresentation from "./BingoBoards/BingoDataRepresentation";
import {startTask, endTask} from './infrastructure/StatusActions';
import axios from "axios";

export default function CourseUsersList(props) {
  const [addUsersPath, setAddUsersPath] = useState("");
  const [procRegReqPath, setProcRegReqPath] = useState("");
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newUserAddresses, setNewUserAddresses] = useState("");

  const dispatch = useDispatch( );

  const getUsers = () => {
    dispatch( startTask() );
    var url = props.retrievalUrl;
    axios.get( url, { } )
      .then(data => {
        //MetaData and Infrastructure
        if ("student" == props.userType) {
          setAddUsersPath(data.add_function.students + ".json");
        } else {
          setAddUsersPath(data.add_function.instructor + ".json");
        }
        setProcRegReqPath(data.add_function.proc_self_reg + ".json");
        props.usersListUpdateFunc(data.users);

        dispatch( endTask() );
      })
      .catch( error=>{
        console.log( 'error', error );
      });
  };

  const refreshFunc = newMessages => {
    getUsers();
    props.addMessagesFunc(newMessages);
  };

  useEffect(() => {
    if (null == props.usersList || props.usersList.length < 1) {
      getUsers();
    }
  }, []);

  var userColumns = [
    {
      label: "First Name",
      name: "first_name",
      tag: "first_name",
      options: {
        filter: false
      }
    },
    {
      label: "Last Name",
      name: "last_name",
      tag: "last_name",
      options: {
        filter: false
      }
    },
    {
      label: "Email",
      name: "email",
      tag: "email",
      options: {
        display: false,
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return <Link href={"mailto:" + value}>{value}</Link>;
        }
      }
    },
    {
      label: "Bingo Progress",
      name: "id",
      tag: "bingo_performance",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const user = props.usersList.filter(item => {
            return value == item.id;
          })[0];
          const data = user.bingo_data;
          return (
            <React.Fragment>
              <BingoDataRepresentation
                height={30}
                width={70}
                value={Number(value)}
                scores={data}
              />
            </React.Fragment>
          );
        }
      }
    },
    {
      label: "Assessment Progress",
      name: "assessment_performance",
      tag: "assessment_performance",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return value + "%";
        }
      }
    },
    {
      label: "Experience Progress",
      name: "experience_performance",
      tag: "experience_performance",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return value + "%";
        }
      }
    },
    {
      label: "Status",
      name: "status",
      tag: "status",
      options: {
        display: true,
        customBodyRender: (value, tableMeta, updateValue) => {
          return iconForStatus(value);
        },
        customFilterListOptions: {
          render: value => {
            return iconForStatus(value);
          }
        },
        filterOptions: {
          names: ["Enrolled", "Dropped", "Undetermined"],
          logic: (location, filters) => {
            switch (location) {
              case "enrolled_student":
                return !filters.includes("Enrolled");
                break;
              case "invited_student":
              case "requesting_student":
                return !filters.includes("Undetermined");
                break;
              case "rejected_student":
              case "dropped_student":
              case "declined_student":
                return !filters.includes("Dropped");
                break;
              case "instructor":
                return !filters.includes("Instructor");
                break;
              case "assistant":
                return !filters.includes("Assistant");
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
      label: "Actions",
      name: "id",
      options: {
        filter: false,
        sort: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const user = props.usersList.filter(user => {
            return value == user.id;
          })[0];
          var btns = [];
          var lbl = "";
          switch (user.status) {
            case "invited_student":
              lbl = "Re-Send Invitation";
              btns.push(
                <Tooltip key="re-send-invite" title={lbl}>
                  <IconButton
                    aria-label={lbl}
                    onClick={event => {
                      dispatch( startTask("inviting") );
                      axios.get( user.reinvite_link, { } )
                        .then(data => {
                          refreshFunc(data.messages);
                          dispatch( endTask("inviting") );
                        })
                        .catch( error =>{
                          console.log( 'error', error );
                        });
                    }}
                  >
                    <EmailIcon />
                  </IconButton>
                </Tooltip>
              );
            case "instructor":
            case "assistant":
            case "enrolled_student":
              lbl = "Drop Student";
              btns.push(
                <DropUserButton
                  key="drop-student-button"
                  dropUrl={user.drop_link}
                  refreshFunc={refreshFunc}
                />
              );
              break;
            case "requesting_student":
              lbl = "Accept Student";
              const lbl2 = "Decline Student";
              btns.push(
                <Tooltip key="accept" title={lbl}>
                  <IconButton
                    aria-label={lbl}
                    onClick={event => {
                      dispatch( startTask("accepting_student") );
                      axios.patch( procRegReqPath, {
                        body: JSON.stringify({
                          roster_id: user.id,
                          decision: true
                        })
                      })
                        .then(data => {
                          refreshFunc(data.messages);
                          dispatch( endTask("accepting_student") );
                        })
                        .catch( error =>{
                          console.log( 'error', error );
                        });
                    }}
                  >
                    <CheckIcon />
                  </IconButton>
                </Tooltip>
              );
              btns.push(
                <Tooltip key="decline" title={lbl2}>
                  <IconButton
                    aria-label={lbl2}
                    onClick={event => {
                      dispatch( startTask("decline_student") );
                      axios.patch( procRegReqPath, {
                        body: JSON.stringify({
                          roster_id: user.id,
                          decision: false
                        })
                      })
                        .then(data => {
                          refreshFunc(data.messages);
                          dispatch( endTask("decline_student") );
                        })
                        .catch( error=>{
                          console.log( 'error', error );
                        });
                    }}
                  >
                    <ClearIcon />
                  </IconButton>
                </Tooltip>
              );
              break;
            case "rejected_student":
            case "dropped_student":
            case "declined_student":
              lbl = "Re-Add Student";
              btns.push(
                <Tooltip key="re-add" title={lbl}>
                  <IconButton
                    aria-label={lbl}
                    onClick={event => {
                      dispatch( startTask("re-adding") );
                      axios.put( addUsersPath, {
                        body: JSON.stringify({
                          addresses: user.email
                        })

                      })
                        .then(data => {
                          refreshFunc(data.messages);
                          dispatch( endTask("re-adding") );
                        })
                        .catch( error =>{
                          console.log( 'error', error );
                        });
                    }}
                  >
                    <PersonAddIcon />
                  </IconButton>
                </Tooltip>
              );
              break;
            default:
              console.log("Status not found: " + user.status);
          }

          return btns;
        }
      }
    }
  ];

  if ("instructor" == props.userType) {
    userColumns = userColumns.filter(column => {
      const toRemove = [
        "bingo_performance",
        "experience_performance",
        "assessment_performance",
        "bingo_data"
      ];
      return !toRemove.includes(column.tag);
    });
    userColumns[userColumns.length - 2].options.filterOptions.names = [
      "Instructor",
      "Assistant"
    ];
  }

  const closeDialog = () => {
    setNewUserAddresses("");
    setAddDialogOpen(false);
  };

  const iconForStatus = status => {
    var icon;
    switch (status.toLowerCase()) {
      case "enrolled":
      case "enrolled_student":
        icon = (
          <Tooltip title="Enrolled">
            <CheckCircleOutlineIcon />
          </Tooltip>
        );
        break;
      case "undetermined":
      case "invited_student":
      case "requesting_student":
        icon = (
          <Tooltip title="Awaiting Response">
            <HelpOutlineIcon />
          </Tooltip>
        );
        break;
      case "dropped":
      case "rejected_student":
      case "dropped_student":
      case "declined_student":
        icon = (
          <Tooltip title="Not Enrolled">
            <NotInterestedIcon />
          </Tooltip>
        );
        break;
      case "instructor":
      case "assistant":
        icon = (
          <Tooltip title="Instructor or Assistant">
            <SupervisedUserCircleIcon />
          </Tooltip>
        );
        break;
      default:
        console.log("status not found: " + status);
    }
    return icon;
  };

  const userList =
    null != props.usersList ? (
      <MUIDataTable
        title={"instructor" == props.userType ? "Instructor" : "Students"}
        columns={userColumns}
        data={props.usersList.filter(user => {
          const checkType =
            "instructor" !== user.status && "assistant" != user.status;
          return "instructor" === props.userType ? !checkType : checkType;
        })}
        options={{
          responsive: "standard",
          filterType: "checkbox",
          selectableRows: "none",
          print: false,
          download: false,
          customToolbar: () => {
            const lbl = "Add " + props.userType + "s";
            return (
              <React.Fragment>
                <Dialog
                  fullWidth={true}
                  open={addDialogOpen}
                  onClose={() => closeDialog()}
                  aria-labelledby="form-dialog-title"
                >
                  <DialogTitle id="form-dialog-title">
                    Add {props.userType}s
                  </DialogTitle>
                  <DialogContent>
                    <DialogContentText>
                      Add {props.userType}s by email:
                    </DialogContentText>
                    <TextField
                      autoFocus
                      margin="dense"
                      id="addresses"
                      label="Email Address"
                      type="email"
                      value={newUserAddresses}
                      onChange={event =>
                        setNewUserAddresses(event.target.value)
                      }
                      fullWidth
                    />
                  </DialogContent>
                  <DialogActions>
                    <Button onClick={() => closeDialog()} color="primary">
                      Cancel
                    </Button>
                    <Button
                      onClick={() => {
                        dispatch( startTask("adding_email") );

                        axios.put( addUsersPath, {
                          body: JSON.stringify({
                            id: props.courseId,
                            addresses: newUserAddresses
                          })

                        } )
                          .then(response => {
                            getUsers();
                            const data = response.data;
                            props.addMessagesFunc(data.messages);
                            dispatch( endTask("adding_email") );
                          });
                        closeDialog();
                      }}
                      color="primary"
                    >
                      Add {props.userType}s!
                    </Button>
                  </DialogActions>
                </Dialog>

                <Tooltip title={lbl}>
                  <IconButton
                    aria-label={lbl}
                    onClick={event => {
                      setAddDialogOpen(true);
                    }}
                  >
                    <GroupAddIcon />
                  </IconButton>
                </Tooltip>
              </React.Fragment>
            );
          }
        }}
      />
    ) : null;

  return (
    <Paper>
      <WorkingIndicator identifier="loading_users" />
      {null != props.usersList ? (
        <React.Fragment>
          {userList}
          <br />
        </React.Fragment>
      ) : (
        "You must save the Course to have students assigned to it"
      )}
    </Paper>
  );
}

CourseUsersList.propTypes = {
  courseId: PropTypes.number.isRequired,
  retrievalUrl: PropTypes.string.isRequired,
  usersList: PropTypes.array,
  usersListUpdateFunc: PropTypes.func.isRequired,

  userType: PropTypes.oneOf(["student", "instructor"]),
  addMessagesFunc: PropTypes.func.isRequired
};
