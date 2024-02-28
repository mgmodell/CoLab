/* eslint-disable no-console */
import React from "react";
import { useDispatch } from "react-redux";

import { useTypedSelector } from "./infrastructure/AppReducers";
import { startTask, endTask } from "./infrastructure/StatusSlice";

import { useTranslation } from "react-i18next";

import axios from "axios";

import { DateTime } from "luxon";
import { DataTable } from "primereact/datatable";
import StandardListToolbar from "./toolbars/StandardListToolbar";
import { Column } from "primereact/column";
import { Button } from "primereact/button";

interface IInvitation {
  id: number;
  name: string;
  startDate: DateTime;
  endDate: DateTime;
  acceptPath: string;
  declinePath: string;
}
type Props = {
  invitations: Array<IInvitation>;
  parentUpdateFunc: () => void;
};

export default function DecisionInvitationsTable(props: Props) {
  const dispatch = useDispatch();
  const { t, i18n } = useTranslation();
  const user = useTypedSelector(state => state.profile.user);

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
      <DataTable
        value={props.invitations}
        resizableColumns
        tableStyle={{
          minWidth: "50rem"
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={[5, 10, 20, props.invitations.length]}
        header={<StandardListToolbar itemType={"invitation"} />}
        sortField="name"
        sortOrder={-1}
        paginatorDropdownAppendTo={"self"}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
      >
        <Column
          header={t("task_name")}
          field="id"
          sortable
          filter
          body={rowData => {
            return (
              <>
                <Button
                  label={t("accept")}
                  raised
                  rounded
                  text
                  icon="pi pi-thumbs-up"
                  onClick={event => {
                    const url = rowData.acceptPath + ".json";
                    dispatch(startTask("accepting"));
                    axios
                      .get(url, {})
                      .then(response => {
                        const data = response.data;
                        //Process the data
                        props.parentUpdateFunc();
                      })
                      .catch(error => {
                        console.log("error", error);
                      })
                      .finally(() => {
                        dispatch(endTask("accepting"));
                      });
                  }}
                />
                <Button
                  label={t("decline")}
                  raised
                  rounded
                  text
                  icon="pi pi-thumbs-down"
                  onClick={event => {
                    const url = rowData.declinePath + ".json";
                    dispatch(startTask("declining"));
                    axios
                      .get(url, {})
                      .then(response => {
                        const data = response.data;
                        //Process the data
                        props.parentUpdateFunc();
                      })
                      .catch(error => {
                        console.log("error", error);
                      })
                      .finally(() => {
                        dispatch(endTask("declining"));
                      });
                  }}
                />
              </>
            );
          }}
        />
        <Column header={t("course_name")} field="name" sortable filter />
        <Column
          header={t("open_date")}
          field="startDate"
          sortable
          filter
          body={rowData => {
            var retVal = <React.Fragment>{t("not_available")}</React.Fragment>;
            if (null !== rowData.startDate) {
              const dt = DateTime.fromISO(rowData.startDate);
              retVal = <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
            }
            return retVal;
          }}
        />
        <Column
          header={t("close_date")}
          field="endDate"
          sortable
          filter
          body={rowData => {
            var retVal = <React.Fragment>{t("not_available")}</React.Fragment>;
            if (null !== rowData.endDate) {
              const dt = DateTime.fromISO(rowData.endDate);
              retVal = <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
            }
            return retVal;
          }}
        />
      </DataTable>
    </React.Fragment>
  );
}
