import React from "react";

import { useTranslation } from "react-i18next";

import {
    GridSeparatorIcon,
    GridToolbarColumnsButton,
    GridToolbarContainer,
    GridToolbarDensitySelector,
    GridToolbarExport,
    GridToolbarFilterButton,
    GridToolbarQuickFilter
} from '@mui/x-data-grid';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, TextField } from "@mui/material";


export default function UserListToolbar( props ){

    const category = 'profile';
    const {t} = useTranslation( `${category}s`);

    return(
        <GridToolbarContainer>
            <GridToolbarDensitySelector />
            <GridToolbarColumnsButton />
            <GridToolbarFilterButton />
            <GridSeparatorIcon />
            <GridToolbarQuickFilter />
            <React.Fragment>
                <Dialog
                  fullWidth={true}
                  open={addDialogOpen}
                  onClose={() => closeDialog()}
                  aria-labelledby="form-dialog-title"
                >
                    <DialogTitle>{t('emails.add_dlg_title')}</DialogTitle>
                  <DialogContent>
                    <DialogContentText>
                      {t('emails.add_dlg')}:
                    </DialogContentText>
                    <TextField
                      autoFocus
                      margin="dense"
                      id="address"
                      label={t('emails.email_lbl')}
                      type="email"
                      value={newEmail}
                      onChange={event => setNewEmail(event.target.value)}
                      fullWidth
                    />
                  </DialogContent>
                  <DialogActions>
                    <Button onClick={() => closeDialog()} color="primary">
                      {t('cancel')}
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
                      {t('emails.add_btn')}
                    </Button>
                  </DialogActions>

                </Dialog>
            </React.Fragment>

        </GridToolbarContainer>
    )
}