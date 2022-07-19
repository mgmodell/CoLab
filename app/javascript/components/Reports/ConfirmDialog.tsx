import React, {useState, useEffect} from "react";
import { PropTypes } from "prop-types";
import { useTranslation } from "react-i18next";
import {
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
    } from "@mui/material";


  export default function ConfirmDialog( props ){
  const category = "graphing";
  const { t, i18n } = useTranslation( category );

    return(
        <Dialog
          open={props.isOpen}
          onClose={() => props.closeFunc( false )}
        aria-labelledby="alert-dialog-title"
        aria-describedby="alert-dialog-description"
      >
        <DialogTitle id="alert-dialog-title">
          {t('anon_confirm_title')}
        </DialogTitle>
        <DialogContent>
          <DialogContentText id="alert-dialog-description">
          {t('anon_confirm')}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>props.closeFunc( false )}>Disagree</Button>
          <Button onClick={()=>props.closeFunc( true )} autoFocus>
            Agree
          </Button>
        </DialogActions>

        </Dialog>

    )

      
  }

  ConfirmDialog.propTypes = {
      isOpen: PropTypes.bool,
      closeFunc: PropTypes.func
          
  }