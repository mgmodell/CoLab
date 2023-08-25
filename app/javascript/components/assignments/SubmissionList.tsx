import React, { useState } from "react";
import { useNavigate } from "react-router-dom";


import { useDispatch } from "react-redux";

import { DataGrid, GridRowModel, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";


import { ISubmissionCondensed } from "./AssignmentViewer";
import SubmissionListToolbar from "./SubmissionListToolbar";

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
            pageSizeOptions={[5, 10, 100 ]}
          />
        </div>
      </div>
    </React.Fragment>
  );
}