import React, { useState, useEffect } from "react";
import Paper from "@mui/material/Paper";

import { useDispatch } from "react-redux";

import { startTask, endTask } from "./infrastructure/StatusSlice";
import axios from "axios";

import WorkingIndicator from "./infrastructure/WorkingIndicator";
import BingoDataRepresentation from "./BingoBoards/BingoDataRepresentation";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import StandardListToolbar from "./StandardListToolbar";

interface ICourse {
  id: number,
  name: string,
  number: string,
  experience_performance: number,
  bingo_performance: number,
  assessment_performance: number,
  bingo_data: Array<number>,
}

type Props = {
  retrievalUrl: string;
  coursesList: Array<ICourse>;
  coursesListUpdateFunc: (coursesList: Array<ICourse> ) => void;
}

export default function UserCourseList(props : Props) {
  const dispatch = useDispatch();

  const category = "profile";
  const { t } = useTranslation( `${category}s` );

  const getCourses = () => {
    dispatch(startTask());
    var url = props.retrievalUrl;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        props.coursesListUpdateFunc(data);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (null == props.coursesList || props.coursesList.length < 1) {
      getCourses();
    }
  }, []);

  var courseColumns : GridColDef[] = [
    {
      headerName: t('course_status.name'),
      field: "name",
      width: 250,
    },
    {
      headerName: t('course_status.number'),
      field: "number",
    },
    {
      headerName: t("course_status.bingo"),
      field: "id",
      renderCell: (params) => {
        const data = params.row.bingo_data;
        return(
          <BingoDataRepresentation
            height={30}
            width={70}
            value={Number(params.row.bingo_performance)}
            scores={data}
          />
        )

      }
    },
    {
      headerName: t('course_status.assessment'),
      field: "assessment_performance",
      renderCell: (params) =>{
        return `${params.value}%`;
      }
    },
    {
      headerName: t('course_status.experience'),
      field: "experience_performance",
      renderCell: (params) =>{
        return `${params.value}%`;
      }
    }
  ];

  const courseList =
    null != props.coursesList ? (
      <DataGrid
        isCellEditable={() => false }
        columns={courseColumns}
        getRowId={(row) =>{
          return `${row.number}-${row.id}`;
         }}
        rows={props.coursesList}
        slots={{
          toolbar: StandardListToolbar
        }}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 5 }
          }
        }}
        pageSizeOptions={[5, 10]}
        />

    ) : (
      "The course data is loading"
    );

  return (
    <Paper>
      <WorkingIndicator identifier="courses_loading" />
      {courseList}
    </Paper>
  );
}

