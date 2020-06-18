/* eslint-disable no-console */
import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import Fab from "@material-ui/core/Fab";
import { withStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import InputBase from "@material-ui/core/InputBase";
import SearchIcon from "@material-ui/icons/Search";
import Toolbar from "@material-ui/core/Toolbar";
import Tooltip from "@material-ui/core/Tooltip";
import Typography from "@material-ui/core/Typography";
import { useUserStore } from "./infrastructure/UserStore";
import { useStatusStore } from './infrastructure/StatusStore';

import MUIDataTable from 'mui-datatables';
import { i18n } from './infrastructure/i18n';
import {useTranslation} from 'react-i18next';

import ThumbDownIcon from "@material-ui/icons/ThumbDown";
import ThumbUpIcon from "@material-ui/icons/ThumbUp";

export default function DecisionInvitationsTable(props){

  const [status, statusActions] = useStatusStore( );
  const {t, i18n } = useTranslation( )
  const [user, userActions] = useUserStore();

  useEffect(() => {
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  const columns = [
    {
      label: t( 'task_name'),
      name: 'id',
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const invitation = props.invitations.filter((item)=>{
            return value === item.id;
          })[0];
          return (
            <React.Fragment>
              <Tooltip title={t('accept')}>
              <Fab
                title={t('accept')}
                aria-label={t('accept')}
                onClick={(event)=>{
                const url = invitation.acceptPath + '.json'
                statusActions.startTask( 'accepting' );
                fetch( url, {
                  method: 'GET',
                  credentials: "include",
                  cache: "no-cache",
                  headers: {
                    "Content-Type": "application/json",
                    Accept: "application/json",
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
                    //Process the data
                    props.parentUpdateFunc();
                    statusActions.endTask( 'accepting' );
                  });

                }} >
                <ThumbUpIcon />
              </Fab>
              </Tooltip>
              <Tooltip title={t('decline')}>
              <Fab
                title={t('decline')}
                aria-label={t('decline')}
                onClick={(event)=>{
                const url = invitation.declinePath + '.json'
                statusActions.startTask( 'declining' );
                fetch( url, {
                  method: 'GET',
                  credentials: "include",
                  cache: "no-cache",
                  headers: {
                    "Content-Type": "application/json",
                    Accept: "application/json",
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
                    //Process the data
                    props.parentUpdateFunc();
                    statusActions.endTask( 'declining' );
                  });

                }} >
                <ThumbDownIcon />

              </Fab>

              </Tooltip>
            </React.Fragment>
          )

        }
      }
    },
    {
      label: t( 'course_name'),
      name: 'name',
      options: {
        filter: false
      }
    },
    {
      label: t( 'open_date'),
      name: 'startDate',
      options: {
        filter: false
      }
    },
    {
      label: t( 'close_date'),
      name: 'endDate',
      options: {
        filter: false
      }
    },
  ]

  return (
    <React.Fragment>
      <h1>{t( 'home.greeting', {name: user.first_name})}</h1>
      <p>
        {t('home.course_confirm', {
          course_list_text: t( 'home.courses_interval', {postProcess: 'interval', count: props.invitations.length }),
          proper_course_list: t( 'home.courses_proper_interval', {postProcess: 'interval', count: props.invitations.length })
        })}
      </p>
    <MUIDataTable
      title={t( 'home.greeting', {name: user.first_name})}
      data={props.invitations}
      columns={columns}
      options={{
        responsive: 'standard',
        filter: false,
        print: false,
        download: false,
        selectableRows: 'none'
      }}
      />

    </React.Fragment>
  )

}
DecisionInvitationsTable.propTypes = {
  token: PropTypes.string.isRequired,
  invitations: PropTypes.array.isRequired,
  parentUpdateFunc: PropTypes.func.isRequired
};
