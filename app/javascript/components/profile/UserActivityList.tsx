import React, { useState, useEffect } from "react";
import Paper from "@mui/material/Paper";
import { iconForType } from "../ActivityLib";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import WorkingIndicator from "../infrastructure/WorkingIndicator";

import axios from "axios";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";
import { useNavigate } from "react-router-dom";
import { DateTime } from "luxon";
import StandardListToolbar from "../StandardListToolbar";

interface IActivity {
  id: number;
  name: string;
  type: string;
  link: string | null;
  course_name: string;
  course_number: string;
  close_date: DateTime;
  performance: number;
  other: number;
}

type Props = {
  retrievalUrl: string;
  activitiesList: Array<IActivity>;
  activitiesListUpdateFunc: (activitiesList: Array<IActivity>) => void;
};

export default function UserActivityList(props: Props) {
  // const [addUsersPath, setAddUsersPath] = useState("");
  // const [procRegReqPath, setProcRegReqPath] = useState("");
  const dispatch = useDispatch();

  const category = "profile";
  const { t } = useTranslation(`${category}s`);
  const navigate = useNavigate();

  const getActivities = () => {
    dispatch(startTask());
    var url = props.retrievalUrl;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        props.activitiesListUpdateFunc(data);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (true) {
      getActivities();
    }
  }, []);

  var activityColumns: GridColDef[] = [
    {
      headerName: t("activities.name"),
      field: "name",
      width: 250,
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("activities.type"),
      field: "type",
      width: 75,
      renderCell: params => {
        return iconForType(params.value);
      }
    },
    {
      headerName: t("activities.course_name"),
      field: "course_name",
      width: 250,
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("activities.course_number"),
      field: "course_number",
      renderCell: renderTextCellExpand
    }
  ];

  const activityList =
    undefined !== props.activitiesList ? (
      <DataGrid
        isCellEditable={() => false}
        columns={activityColumns}
        getRowId={row => {
          return `${row.type}-${row.id}`;
        }}
        rows={props.activitiesList}
        onCellClick={(params, event, details) => {
          if (params.row.link !== null) {
            navigate(`/home/${params.row.link}`);
          }
        }}
        slots={{
          toolbar: StandardListToolbar
        }}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 5 }
          }
        }}
        pageSizeOptions={[5, 10, 100]}
      />
    ) : (
      "The activities are loading"
    );

  return (
    <Paper>
      <WorkingIndicator identifier="activity_list_loading" />
      {activityList}
    </Paper>
  );
}
