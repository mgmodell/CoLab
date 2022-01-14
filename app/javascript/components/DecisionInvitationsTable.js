/* eslint-disable no-console */
import React, { useState, useEffect } from "react";
import {useDispatch} from 'react-redux';
import PropTypes from "prop-types";
import classNames from "classnames";
import Fab from "@mui/material/Fab";
import withStyles from '@mui/styles/withStyles';
import Paper from "@mui/material/Paper";
import InputBase from "@mui/material/InputBase";
import SearchIcon from "@mui/icons-material/Search";
import Toolbar from "@mui/material/Toolbar";
import Tooltip from "@mui/material/Tooltip";
import Typography from "@mui/material/Typography";
import { useTypedSelector } from "./infrastructure/AppReducers";

import {startTask, endTask} from './infrastructure/StatusActions';
import MUIDataTable from "mui-datatables";
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";

import ThumbDownIcon from "@mui/icons-material/ThumbDown";
import ThumbUpIcon from "@mui/icons-material/ThumbUp";
import axios from "axios";

export default function DecisionInvitationsTable(props) {
  const dispatch = useDispatch( );
  const { t, i18n } = useTranslation();
  const user = useTypedSelector(state=>state.profile.user );

  const columns = [
    {
      label: t("task_name"),
      name: "id",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const invitation = props.invitations.filter(item => {
            return value === item.id;
          })[0];
          return (
            <React.Fragment>
              <Tooltip title={t("accept")}>
                <Fab
                  title={t("accept")}
                  aria-label={t("accept")}
                  onClick={event => {
                    const url = invitation.acceptPath + ".json";
                    dispatch( startTask("accepting") );
                    axios.get( url, { } )
                      .then(response => {
                        const data = response.data;
                        //Process the data
                        props.parentUpdateFunc();
                        dispatch( endTask("accepting") );
                      })
                      .catch( error =>{
                        console.log( 'error', error );
                      });
                  }}
                >
                  <ThumbUpIcon />
                </Fab>
              </Tooltip>
              <Tooltip title={t("decline")}>
                <Fab
                  title={t("decline")}
                  aria-label={t("decline")}
                  onClick={event => {
                    const url = invitation.declinePath + ".json";
                    dispatch( startTask("declining") );
                    axios.get( url, { } )
                      .then(response => {
                        const data = response.data;
                        //Process the data
                        props.parentUpdateFunc();
                        dispatch( endTask("declining") );
                      })
                      .catch( error =>{
                        console.log( 'error', error );
                      });
                  }}
                >
                  <ThumbDownIcon />
                </Fab>
              </Tooltip>
            </React.Fragment>
          );
        }
      }
    },
    {
      label: t("course_name"),
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: t("open_date"),
      name: "startDate",
      options: {
        filter: false
      }
    },
    {
      label: t("close_date"),
      name: "endDate",
      options: {
        filter: false
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
      <MUIDataTable
        title={t("home.greeting", { name: user.first_name })}
        data={props.invitations}
        columns={columns}
        options={{
          responsive: "standard",
          filter: false,
          print: false,
          download: false,
          selectableRows: "none"
        }}
      />
    </React.Fragment>
  );
}
DecisionInvitationsTable.propTypes = {
  invitations: PropTypes.array.isRequired,
  parentUpdateFunc: PropTypes.func.isRequired
};
