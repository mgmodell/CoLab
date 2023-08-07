/* eslint-disable no-console */
import React from "react";
import { useDispatch } from "react-redux";
import Fab from "@mui/material/Fab";
import Tooltip from "@mui/material/Tooltip";

import { useTypedSelector } from "./infrastructure/AppReducers";
import { startTask, endTask } from "./infrastructure/StatusSlice";

import { useTranslation } from "react-i18next";

import ThumbDownIcon from "@mui/icons-material/ThumbDown";
import ThumbUpIcon from "@mui/icons-material/ThumbUp";
import axios from "axios";

import { DateTime } from "luxon";
import { DataGrid, GridColDef } from "@mui/x-data-grid";

interface IInvitation {
  id: number,
  name: string,
  startDate: DateTime,
  endDate: DateTime,
  acceptPath: string,
  declinePath: string,
}
type Props = {
  invitations: Array<IInvitation>;
  parentUpdateFunc: () => void;
}

export default function DecisionInvitationsTable(props : Props) {
  const dispatch = useDispatch();
  const { t, i18n } = useTranslation();
  const user = useTypedSelector(state => state.profile.user);

  const columns: GridColDef[] = [
    {
      headerName: t("task_name"),
      field: "id",
      renderCell: (params) => {
          const invitation = params.row;
          return (
            <React.Fragment>
              <Tooltip title={t("accept")}>
                <Fab
                  aria-label={t("accept")}
                  id="Accept"
                  onClick={event => {
                    const url = invitation.acceptPath + ".json";
                    dispatch(startTask("accepting"));
                    axios
                      .get(url, {})
                      .then(response => {
                        const data = response.data;
                        //Process the data
                        props.parentUpdateFunc();
                        dispatch(endTask("accepting"));
                      })
                      .catch(error => {
                        console.log("error", error);
                      });
                  }}
                >
                  <ThumbUpIcon />
                </Fab>
              </Tooltip>
              <Tooltip title={t("decline")}>
                <Fab
                  aria-label={t("decline")}
                  id="Decline"
                  onClick={event => {
                    const url = invitation.declinePath + ".json";
                    dispatch(startTask("declining"));
                    axios
                      .get(url, {})
                      .then(response => {
                        const data = response.data;
                        //Process the data
                        props.parentUpdateFunc();
                        dispatch(endTask("declining"));
                      })
                      .catch(error => {
                        console.log("error", error);
                      });
                  }}
                >
                  <ThumbDownIcon />
                </Fab>
              </Tooltip>
            </React.Fragment>
          );

      }
    },
    {
      headerName: t("course_name"),
      field: "name",
    },
    {
      headerName: t("open_date"),
      field: "startDate",
      renderCell: (params) => {
          var retVal = <React.Fragment>{t('not_available')}</React.Fragment>
          if (null !== params.value) {
            const dt = DateTime.fromISO(params.value);
            retVal = <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
          }
          return retVal;
      }
    },
    {
      headerName: t("close_date"),
      field: "endDate",
      renderCell: (params) => {
          var retVal = <React.Fragment>{t('not_available')}</React.Fragment>
          if (null !== params.value) {
            const dt = DateTime.fromISO(params.value);
            retVal = <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
          }
          return retVal;
      }
    }
  ];

  return (
    <React.Fragment>
      <h1>{t("home.greeting", { name: user.first_name })}</h1>
      <p>
        {t("home.course_confirm", {
          course_list_text: t("home.courses_interval", {
            postProcess: "interval",
            count: props.invitations.length
          }),
          proper_course_list: t("home.courses_proper_interval", {
            postProcess: "interval",
            count: props.invitations.length
          })
        })}
      </p>
      <DataGrid
        columns={columns}
        rows={props.invitations}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 5 }
          }
        }}
        pageSizeOptions={[5, 10]}
        />
    </React.Fragment>
  );
}
