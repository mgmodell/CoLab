import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Paper from "@mui/material/Paper";
import Dialog from "@mui/material/Dialog";
import DialogActions from "@mui/material/DialogActions";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogTitle from "@mui/material/DialogTitle";
import TextField from "@mui/material/TextField";
import Button from "@mui/material/Button";

import MUIDataTable from "mui-datatables";

import CheckIcon from "@mui/icons-material/Check";
import AddIcon from "@mui/icons-material/Add";
import StarIcon from "@mui/icons-material/Star";
import DeleteForeverIcon from "@mui/icons-material/DeleteForever";
import StarBorderIcon from "@mui/icons-material/StarBorder";

import Link from "@mui/material/Link";
import Tooltip from "@mui/material/Tooltip";
import IconButton from "@mui/material/IconButton";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusActions";
import axios from "axios";

export default function UserEmailList(props) {
  const [addUsersPath, setAddUsersPath] = useState("");
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newEmail, setNewEmail] = useState("");
  const dispatch = useDispatch();

  const emailColumns = [
    {
      label: "Registered Emails",
      name: "email",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return <Link href={"mailto:" + value}>{value}</Link>;
        }
      }
    },
    {
      label: "Primary",
      name: "id",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const email = props.emailList.filter(item => {
            return value == item.id;
          })[0];
          const lbl = "Set as primary";
          const resp = email.primary ? (
            <Tooltip title="Primary">
              <StarIcon />
            </Tooltip>
          ) : (
            <Tooltip title={lbl}>
              <IconButton
                aria-label={lbl}
                onClick={event => {
                  dispatch(startTask("updating"));
                  const url = props.primaryEmailUrl + value + ".json";
                  axios
                    .get(url, {})
                    .then(response => {
                      const data = response.data;
                      props.emailListUpdateFunc(data.emails);
                      props.addMessagesFunc(data.messages);
                      dispatch(endTask("updating"));
                    })
                    .then(error => {
                      console.log("error", error);
                    });
                }}
                size="large"
              >
                <StarBorderIcon />
              </IconButton>
            </Tooltip>
          );
          return resp;
        }
      }
    },
    {
      label: "Confirmed",
      name: "confirmed?",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const resp = value ? <CheckIcon /> : null;
          return resp;
        }
      }
    },
    {
      label: "Remove?",
      name: "id",
      options: {
        filter: false,
        sort: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const lbl2 = "Remove this address";
          return (
            <Tooltip title={lbl2}>
              <IconButton
                aria-label={lbl2}
                onClick={event => {
                  const url = props.removeEmailUrl + value + ".json";
                  dispatch(startTask("removing"));
                  axios
                    .get(url, {})
                    .then(response => {
                      const data = response.data;
                      props.emailListUpdateFunc(data.emails);
                      props.addMessagesFunc(data.messages);
                      dispatch(endTask("removing"));
                    })
                    .catch(error => {
                      console.log("error", error);
                    });
                }}
                size="large"
              >
                <DeleteForeverIcon />
              </IconButton>
            </Tooltip>
          );
        }
      }
    }
  ];

  const closeDialog = () => {
    setNewEmail("");
    setAddDialogOpen(false);
  };

  const emailList =
    null != props.emailList ? (
      <MUIDataTable
        columns={emailColumns}
        data={props.emailList}
        options={{
          responsive: "standard",
          filter: false,
          selectableRows: "none",
          print: false,
          download: false,
          customToolbar: () => {
            const lbl = "Add Email";
            return (
              <React.Fragment>
                <Dialog
                  fullWidth={true}
                  open={addDialogOpen}
                  onClose={() => closeDialog()}
                  aria-labelledby="form-dialog-title"
                >
                  <DialogTitle id="form-dialog-title">Add Email</DialogTitle>
                  <DialogContent>
                    <DialogContentText>
                      Add a new email address:
                    </DialogContentText>
                    <TextField
                      autoFocus
                      margin="dense"
                      id="address"
                      label="Email Address"
                      type="email"
                      value={newEmail}
                      onChange={event => setNewEmail(event.target.value)}
                      fullWidth
                    />
                  </DialogContent>
                  <DialogActions>
                    <Button onClick={() => closeDialog()} color="primary">
                      Cancel
                    </Button>
                    <Button
                      onClick={() => {
                        dispatch(startTask("updating"));
                        axios
                          .put(props.addEmailUrl + ".json", {
                            email_address: newEmail
                          })
                          .then(response => {
                            const data = response.data;
                            //getUsers();
                            props.emailListUpdateFunc(data.emails);
                            props.addMessagesFunc(data.messages);
                            dispatch(endTask("updating"));
                          })
                          .catch(error => {
                            console.log("error", error);
                          });
                        closeDialog();
                      }}
                      color="primary"
                    >
                      Add Email!
                    </Button>
                  </DialogActions>
                </Dialog>

                <Tooltip title={lbl}>
                  <IconButton
                    aria-label={lbl}
                    onClick={event => {
                      setAddDialogOpen(true);
                    }}
                    size="large"
                  >
                    <AddIcon />
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
      <WorkingIndicator identifier="email_actions" />
      {null != props.emailList ? (
        <React.Fragment>
          {emailList}
          <br />
        </React.Fragment>
      ) : (
        "No emails loaded."
      )}
    </Paper>
  );
}

UserEmailList.propTypes = {
  emailList: PropTypes.array,
  emailListUpdateFunc: PropTypes.func.isRequired,

  addEmailUrl: PropTypes.string.isRequired,
  removeEmailUrl: PropTypes.string.isRequired,
  primaryEmailUrl: PropTypes.string.isRequired
};
