import React, { useState } from "react";
import Paper from "@mui/material/Paper";

import CheckIcon from "@mui/icons-material/Check";
import StarIcon from "@mui/icons-material/Star";
import DeleteForeverIcon from "@mui/icons-material/DeleteForever";
import StarBorderIcon from "@mui/icons-material/StarBorder";

import Link from "@mui/material/Link";
import Tooltip from "@mui/material/Tooltip";
import IconButton from "@mui/material/IconButton";

import WorkingIndicator from "./infrastructure/WorkingIndicator";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";
import axios from "axios";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import UserListToolbar from "./UserListToolbar";

interface IEmail {
  id: number;
  email: string;
  primary: boolean;
  confirmed?: boolean;

}
type Props = {
  emailList: Array<string>;
  emailListUpdateFunc: ( emails: Array<IEmail> ) => void;

  addEmailUrl: string;
  removeEmailUrl: string;
  addMessagesFunc: ( messages: Record<string, string> ) => void;
  primaryEmailUrl: string;
}

export default function UserEmailList(props: Props) {
  const category = 'profile';
  const {t} = useTranslation( `${category}s` );
  const [addUsersPath, setAddUsersPath] = useState("");
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newEmail, setNewEmail] = useState("");
  const dispatch = useDispatch();

  const emailColumns: GridColDef[] = [
    {
      headerName: t('emails.registered_col'),
      field: "email",
      renderCell: (params) => {
          return <Link href={`mailto:${params.row.email}`}>{params.row.email}</Link>;
      }
    },
    {
      headerName: t('emails.primary_col'),
      field: "id",
      renderCell: (params) => {
          const resp = params.row.primary ? (
            <Tooltip title={t('emails.primary_col')}>
              <StarIcon />
            </Tooltip>
          ) : (
            <Tooltip title={t('emails.set_primary')}>
              <IconButton
                aria-label={t('emails.set_primary')}
                onClick={event => {
                  dispatch(startTask("updating"));
                  const url = props.primaryEmailUrl + params.row.id + ".json";
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
    },
    {
      headerName: t('emails.confirmed_col'),
      field: "confirmed?",
      renderCell: ( params ) => {
          const resp = params.value ? <CheckIcon /> : null;
          return resp;
      }
    },
    {
      headerName: t('emails.remove_btn'),
      field: "id",
      renderCell: ( params ) => {
          return (
            <Tooltip title={t('emails.remove_tltp')}>
              <IconButton
                aria-label={t('emails.remove_tltp')}
                onClick={event => {
                  const url = props.removeEmailUrl + params.row.id + ".json";
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
  ];

  const closeDialog = () => {
    setNewEmail("");
    setAddDialogOpen(false);
  };

  const emailList =
    null != props.emailList ? (
      <DataGrid
        isCellEditable={()=>false}
        columns={emailColumns}
        rows={props.emailList}
        slots={{
          toolbar: UserListToolbar
        }}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 5 }
          }
        }}
        pageSizeOptions={[5, 10]}
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
        <div>{t('emails.none_yet')}</div>
      )}
    </Paper>
  );
}

