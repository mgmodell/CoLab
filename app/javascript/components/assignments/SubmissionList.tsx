import React, { Fragment, useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";
import { Settings } from "luxon";

import CloseIcon from "@mui/icons-material/Close";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { DataGrid, GridRowModel, GridColDef, GridRenderCellParams } from "@mui/x-data-grid";
import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";

import FileCopyIcon from "@mui/icons-material/FileCopy";
import DeleteIcon from "@mui/icons-material/Delete";

import { ISubmissionCondensed } from "./AssignmentViewer";
import SubmissionListToolbar from "../course_admin/SubmissionListToolbar";

type Props = {
  submissions: Array<ISubmissionCondensed>;
  selectSubmissionFunc: (selectedSub:string) => void;
}

export default function SubmissionList(props:Props) {
  const category = "assignment";

  const { t } = useTranslation(`${category}s`);

  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const navigate = useNavigate();

  const dispatch = useDispatch();
  const columns: GridColDef[] = [
    { field: "recordedScore", headerName: t("submissions.score") },
    { field: "submitted", headerName: t("submissions.submitted") },
    { field: "withdrawn", headerName: t("submissions.withdrawn") },
    { field: "user", headerName: t("submissions.submitter") },
  ];

  return (
    <React.Fragment>
      <div style={{ display: "flex", height: "100%" }}>
        <div style={{ flexGrow: 1 }}>
          <DataGrid
            getRowId={(model: GridRowModel) => {
              return model.id;
            }}
            autoHeight
            rows={props.submissions}
            columns={columns}
            isCellEditable={params => {
              return false;
            }}
            onCellClick={(params, event, details) => {
              props.selectSubmissionFunc( params.row.id );
                //navigate(String(params.row.id));
            }}
            slots={{
              toolbar: SubmissionListToolbar
            }}
            slotProps={{
              toolbar: {
                selectSubmissionFunc: props.selectSubmissionFunc
              }
            }}
          />
        </div>
      </div>
    </React.Fragment>
  );
}