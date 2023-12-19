import React, { useState, useEffect } from "react";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import axios from "axios";
import { useTranslation } from "react-i18next";
import { DateTime } from "luxon";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Panel } from "primereact/panel";

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


  const consentFormList =
    null != props.consentFormList ? (
      <>
      <DataTable
        value={props.consentFormList}
        resizableColumns
        tableStyle={{
          minWidth: '50rem'
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={
          [5, 10, 20, props.consentFormList.length]
        }
        sortField="start_date"
        sortOrder={-1}
        paginatorDropdownAppendTo={'self'}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
        >
          <Column
            header={t("consent.name")}
            field="name"
            sortable
            filter
            />
          <Column
            header={t("consent.status")}
            field="id"
            sortable
            filter
            body={(rowData) => {
              var output;
              if (rowData.active) {
                if (Date.now() < Date.parse(rowData.end_date)) {
                  output = t("consent.accepted");
                } else {
                  output = t("consent.expired");
                }
              } else {
                output = t("consent.inactive");
              }
              return <span>{output}</span>;
            }}
            />
          <Column
            header={t("consent.accept_status")}
            field="accepted"
            body={(rowData) => {
              return (
                <span>
                  {rowData.accepted ? t("consent.accepted") : t("consent.declined")}
                </span>
              );
            }}
            />
          <Column
            header={t("consent.action")}
            field="link"
            body={(rowData) => {
              return (<a href={rowData.link}>Review/Update</a>);
            }}
            />

        </DataTable>
      </>
    ) : (
      "The course data is loading"
    );

  return (
  <Panel>
    {consentFormList}
  </Panel>) ;
}
