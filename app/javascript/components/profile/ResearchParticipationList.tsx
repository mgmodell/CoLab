import React, { useState, useEffect } from "react";
import Link from "@mui/material/Link";
import Paper from "@mui/material/Paper";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import axios from "axios";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";
import { DateTime } from "luxon";
import StandardListToolbar from "../StandardListToolbar";

interface IConsentForm {
  id: number;
  name: string;
  link: string;
  accepted: boolean;
  active: boolean;
  end_date: DateTime;
  open_date: DateTime;
}
type Props = {
  retrievalUrl: string;
  consentFormList: Array<IConsentForm>;
  consentFormListUpdateFunc: (consentFormsList: Array<IConsentForm>) => void;
};

export default function ResearchParticipationList(props: Props) {
  const dispatch = useDispatch();

  const category = "profile";
  const { t } = useTranslation(`${category}s`);

  const getCourses = () => {
    dispatch(startTask());
    var url = props.retrievalUrl;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        props.consentFormListUpdateFunc(data);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (null == props.consentFormList || props.consentFormList.length < 1) {
      getCourses();
    }
  }, []);

  var consentColumns: GridColDef[] = [
    {
      headerName: t("consent.name"),
      field: "name",
      width: 300,
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("consent.status"),
      field: "id",
      width: 150,
      renderCell: params => {
        var output;
        if (params.row.active) {
          if (Date.now() < Date.parse(params.row.end_date)) {
            output = t("consent.accepted");
          } else {
            output = t("consent.expired");
          }
        } else {
          output = t("consent.inactive");
        }
        return <span>{output}</span>;
      }
    },
    {
      headerName: t("consent.accept_status"),
      field: "accepted",
      renderCell: params => {
        return (
          <span>
            {params.value ? t("consent.accepted") : t("consent.declined")}
          </span>
        );
      }
    },
    {
      headerName: t("consent.action"),
      field: "link",
      renderCell: params => {
        return <Link href={params.value}>Review/Update</Link>;
      }
    }
  ];

  const consentFormList =
    null != props.consentFormList ? (
      <DataGrid
        isCellEditable={() => false}
        columns={consentColumns}
        rows={props.consentFormList}
        getRowId={row => {
          return `consent-${row.id}`;
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
      "The course data is loading"
    );

  return <Paper>{consentFormList}</Paper>;
}
