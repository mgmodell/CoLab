import React, { Fragment, useState } from "react";

import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import TextField from "@mui/material/TextField";
import DialogContentText from "@mui/material/DialogContentText";
import DialogActions from "@mui/material/DialogActions";
import Button from "@mui/material/Button";
import GroupAddIcon from '@mui/icons-material/GroupAdd';

import {
  GridToolbarQuickFilter,
  GridToolbarContainer,
  GridToolbarDensitySelector,
  GridToolbarFilterButton,
  GridToolbarColumnsButton,
  GridSeparatorIcon
} from "@mui/x-data-grid";
import { IconButton } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import Tooltip from "@mui/material/Tooltip";
import { useDispatch } from "react-redux";

import { startTask, endTask } from "./infrastructure/StatusSlice";
import { StudentData, UserListType } from "./CourseUsersList";
import axios from "axios";

type Props = {
  courseId: number;
  retrievalUrl: string;
  usersListUpdateFunc: (usersList: Array<StudentData> ) => void;
  userType: UserListType;
  addMessagesFunc: ({}) => void;
  refreshUsersFunc: () => void;
  addUsersPath: string;
}
export default function CourseUsersListToolbar(props:Props) {
  const { t } = useTranslation(`admin`);
  const navigate = useNavigate();
  const dispatch = useDispatch( );

  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newUserAddresses, setNewUserAddresses] = useState("");

  const closeDialog = () => {
    setNewUserAddresses("");
    setAddDialogOpen(false);
  };


  const lbl = "Add " + props.userType + "s";

  return (
    <Fragment>
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
                      {t("Cancel")}
                    </Button>
                    <Button
                      onClick={() => {
                        dispatch(startTask("adding_email"));

                        axios
                          .put(props.addUsersPath, {
                            id: props.courseId,
                            addresses: newUserAddresses
                          })
                          .then(response => {
                            const data = response.data;
                            props.addMessagesFunc(data.messages);
                          })
                          .finally(( )=>{
                            props.refreshUsersFunc();
                            dispatch(endTask("adding_email"));
                          });
                        closeDialog();
                      }}
                      color="primary"
                    >
                      Add {props.userType}s!
                    </Button>
                  </DialogActions>
                </Dialog>

    <GridToolbarContainer>
      <GridToolbarDensitySelector />
      <GridToolbarColumnsButton />
      <GridToolbarFilterButton />
       <Tooltip title={lbl}>
         <IconButton
           aria-label={lbl}
           onClick={event => {
             setAddDialogOpen(true);
           }}
           size="large"
         >
           <GroupAddIcon />
         </IconButton>
       </Tooltip>
      <GridSeparatorIcon />
      <GridToolbarQuickFilter debounceMs={50} />
    </GridToolbarContainer>
    </Fragment>
  );
}
