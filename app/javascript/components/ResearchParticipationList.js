import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Link from "@material-ui/core/Link";
import Paper from "@material-ui/core/Paper";

import {useDispatch} from 'react-redux';
import {startTask, endTask} from './infrastructure/StatusActions';

import MUIDataTable from "mui-datatables";
import axios from "axios";

export default function UserCourseList(props) {

  const dispatch = useDispatch( );

  const getCourses = () => {
    dispatch( startTask() );
    var url = props.retrievalUrl;
    axios.get( url, { } )
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        props.consentFormListUpdateFunc(data);
        dispatch( endTask() );
      })
      .catch( error =>{
        console.log( 'error', error );
      });
  };

  useEffect(() => {
    if (null == props.usersList || props.usersList.length < 1) {
      getCourses();
    }
  }, []);

  var consentColumns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Consent Form Status",
      name: "id",
      options: {
        filter: true,
        customBodyRender: value => {
          const consentForm = props.consentFormList.filter(item => {
            return value === item.id;
          })[0];
          // let output: String;
          var output;
          if (consentForm.active) {
            if (Date.now() < Date.parse(consentForm.end_date)) {
              output = "Active";
            } else {
              output = "Inactive (expired)";
            }
          } else {
            output = "Inactive";
          }
          return <span>{output}</span>;
        }
      }
    },
    {
      label: "Consent Status",
      name: "accepted",
      options: {
        filter: true,
        customBodyRender: value => {
          return <span>{value ? "Accepted" : "Declined"}</span>;
        }
      }
    },
    {
      label: "Action",
      name: "link",
      options: {
        filter: false,
        customBodyRender: value => {
          return <Link href={value}>Review/Update</Link>;
        }
      }
    }
  ];

  const consentFormList =
    null != props.consentFormList ? (
      <MUIDataTable
        title={"Your research participation"}
        columns={consentColumns}
        data={props.consentFormList}
        options={{
          responsive: "standard",
          filterType: "checkbox",
          selectableRows: "none",
          print: false,
          download: false
        }}
      />
    ) : (
      "The course data is loading"
    );

  return <Paper>{consentFormList}</Paper>;
}

UserCourseList.propTypes = {
  retrievalUrl: PropTypes.string.isRequired,
  consentFormList: PropTypes.array,
  consentFormListUpdateFunc: PropTypes.func.isRequired,

  addMessagesFunc: PropTypes.func.isRequired
};
