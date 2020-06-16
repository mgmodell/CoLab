import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import Paper from "@material-ui/core/Paper";
import Dialog from "@material-ui/core/Dialog";
import DialogActions from "@material-ui/core/DialogActions";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import DialogTitle from "@material-ui/core/DialogTitle";
import TextField from "@material-ui/core/TextField";
import Button from "@material-ui/core/Button";

import MUIDataTable from "mui-datatables";

import CheckIcon from '@material-ui/icons/Check';
import AddIcon from '@material-ui/icons/Add';
import StarIcon from '@material-ui/icons/Star';
import DeleteForeverIcon from '@material-ui/icons/DeleteForever';
import StarBorderIcon from '@material-ui/icons/StarBorder';

import Link from "@material-ui/core/Link";
import Tooltip from "@material-ui/core/Tooltip";
import IconButton from "@material-ui/core/IconButton";
import { useStatusStore } from './infrastructure/StatusStore';

export default function UserEmailList(props) {
  const [addUsersPath, setAddUsersPath] = useState("");
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newEmail, setNewEmail] = useState("");

  const [status, statusActions] = useStatusStore( );

  const refreshFunc = newMessages => {
    //getUsers();
    statusActions.addMessage( )
    props.addMessagesFunc(newMessages);
    statusActions.setWorking(false);
  };

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
          const email = props.emailList.filter((item)=>{
            return value == item.id;
          })[0]
          const lbl = 'Set as primary';
          const resp = email.primary ? 
            (
              <Tooltip title='Primary'>
                <StarIcon/>
              </Tooltip>
            ) :
            (
                <Tooltip title={lbl}>
                  <IconButton
                    aria-label={lbl}
                    onClick={event => {
                      const url = props.primaryEmailUrl + value + '.json'
                      statusActions.setWorking( true )
                      fetch(url, {
                        method: "GET",
                        credentials: "include",
                        headers: {
                          "Content-Type": "application/json",
                          Accepts: "application/json",
                          "X-CSRF-Token": props.token
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
                          props.emailListUpdateFunc( data.emails )
                          props.addMessagesFunc(data.messages);
                          statusActions.setWorking(false);
                        });
                    }}
                  >
                    <StarBorderIcon />
                  </IconButton>
                </Tooltip>
            )
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
          const resp = value ? <CheckIcon/> : null;
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
          const lbl2 = 'Remove this address';
          return (
                <Tooltip title={lbl2}>
                  <IconButton
                    aria-label={lbl2}
                    onClick={event => {
                      const url = props.removeEmailUrl + value + '.json'
                      statusActions.setWorking( true )
                      fetch(url, {
                        method: "GET",
                        credentials: "include",
                        headers: {
                          "Content-Type": "application/json",
                          Accepts: "application/json",
                          "X-CSRF-Token": props.token
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
                          props.emailListUpdateFunc( data.emails )
                          props.addMessagesFunc(data.messages);
                          statusActions.setWorking(false);
                        });
                    }}
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
                  <DialogTitle id="form-dialog-title">
                    Add Email
                  </DialogTitle>
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
                      onChange={event =>
                        setNewEmail(event.target.value)
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
                        statusActions.setWorking(true);
                        fetch(props.addEmailUrl + '.json', {
                          method: "PUT",
                          credentials: "include",
                          headers: {
                            "Content-Type": "application/json",
                            Accepts: "application/json",
                            "X-CSRF-Token": props.token
                          },
                          body: JSON.stringify({
                            email_address: newEmail
                          })
                        })
                          .then(response => {
                            if (response.ok) {
                              return response.json();
                            } else {
                              console.log("error");
                            }
                          })
                          .then(data => {
                            //getUsers();
                            props.emailListUpdateFunc(data.emails)
                            props.addMessagesFunc(data.messages);
                            statusActions.setWorking(false);
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
      {status.working ? <LinearProgress id='waiting' /> : null}
      {null != props.emailList ? (
        <React.Fragment>
          {emailList}
          <br />
        </React.Fragment>
      ) : (
        'No emails loaded.'
      )}
    </Paper>
  );
}

UserEmailList.propTypes = {
  token: PropTypes.string.isRequired,
  emailList: PropTypes.array,
  emailListUpdateFunc: PropTypes.func.isRequired,

  addEmailUrl: PropTypes.string.isRequired,
  removeEmailUrl: PropTypes.string.isRequired,
  primaryEmailUrl: PropTypes.string.isRequired,
};
