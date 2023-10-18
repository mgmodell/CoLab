import React, { useState, useEffect } from "react";
import Paper from "@mui/material/Paper";
import Popover from "@mui/material/Popover";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import Link from "@mui/material/Link";
import Container from "@mui/material/Container";
import axios from "axios";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import StandardListToolbar from "../StandardListToolbar";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";

export interface IReaction {
  id: number;
  user: {
    email: string;
    name: string;
  };
  status: string;
  student_status: string;
  narrative: string;
  scenario: string;
  behavior: string;
  other_name: string;
  improvements: string;
}
type Props = {
  retrievalUrl: string;
  reactionsList: Array<IReaction>;
  reactionsListUpdateFunc: (reactionList: Array<IReaction>) => void;
};

export default function ReactionsList(props: Props) {
  const category = "experience";
  const { t } = useTranslation(`${category}s`);

  const [anchorEl, setAnchorEl] = useState();
  const [popMsg, setPopMsg] = useState();

  const dispatch = useDispatch();
  const getReactions = () => {
    var url = props.retrievalUrl + ".json";
    dispatch(startTask());
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        props.reactionsListUpdateFunc(data.reactions);

        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (null == props.reactionsList) {
      getReactions();
    }
  }, []);

  const openPop = (event, msg) => {
    setAnchorEl(event.currentTarget);
    setPopMsg(msg);
  };

  const closePop = () => {
    setAnchorEl(null);
    setPopMsg(null);
  };

  const reactionColumns: GridColDef[] = [
    {
      headerName: t("reactions.student_lbl"),
      field: "user",
      renderCell: params => {
        const user = params.value;
        return <Link href={`mailto:${user.email}`}>{user.name}</Link>;
      }
    },
    {
      headerName: t("reactions.email_lbl"),
      field: "email",
      renderCell: params => {
        const user = params.value;
        return <Link href={`mailto:${user.email}`}>{user.email}</Link>;
      }
    },
    {
      headerName: t("reactions.completion_lbl"),
      field: "status",
      renderCell: params => {
        return params.value + "%";
      }
    },
    {
      headerName: t("reactions.narrative_lbl"),
      field: "narrative",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("reactions.scenario_lbl"),
      field: "scenario",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("reactions.response_lbl"),
      field: "behavior",
      renderCell: params => {
        if ("Other" == params.value) {
          return (
            <Link onClick={event => openPop(event, params.row.other_name)}>
              {params.value}
            </Link>
          );
        } else {
          return params.value;
        }
      }
    },
    {
      headerName: t("reactions.improvements_lbl"),
      field: "improvements",
      renderCell: params => {
        if ("" != params.value) {
          return (
            <Link onClick={event => openPop(event, params.row.improvements)}>
              {t("reactions.suggestions_lbl")}
            </Link>
          );
        } else {
          return "N/A";
        }
      }
    }
  ];

  return (
    <Paper>
      {null != props.reactionsList ? (
        <React.Fragment>
          <DataGrid
            isCellEditable={() => false}
            columns={reactionColumns}
            rows={props.reactionsList}
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
          <Popover
            open={Boolean(anchorEl)}
            onClose={closePop}
            anchorEl={anchorEl}
          >
            <Container maxWidth="sm">{popMsg}</Container>
          </Popover>
        </React.Fragment>
      ) : (
        <div>{t("reactions.none_yet")}</div>
      )}
    </Paper>
  );
}
