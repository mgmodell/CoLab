/* eslint-disable no-console */
import React, { useEffect, useState } from "react";

import WorkingIndicator from "./infrastructure/WorkingIndicator";

import axios from "axios";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";

import { useTranslation } from "react-i18next";
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Button } from "primereact/button";
import { Panel } from "primereact/panel";
import StandardListToolbar from "./StandardListToolbar";


type Props = {
  init_url: string,
  update_url: string
};

export default function DecisionEnrollmentsTable(props: Props) {
  const category = "admin";
  const { t } = useTranslation(category);
  const dispatch = useDispatch();

  const [requests_raw, setRequestsRaw] = useState([]);
  const [requests, setRequests] = useState([]);
  const [working, setWorking] = useState(true);
  const [filterText, setFilterText] = useState("");

  useEffect(() => {
    //Retrieve requests
    getRequests();
  }, []);

  const getRequests = () => {
    const url = `${props.init_url}.json`;
    dispatch(startTask());
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setRequests(data);
        setRequestsRaw(data);
        setWorking(false);
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      }).finally(() => {
        dispatch(endTask());
      });
  };


  const decision = (id, accept) => {
    setWorking(true);
    const url = props.update_url + ".json";
    dispatch(startTask());
    axios
      .patch(url, {
        roster_id: id,
        decision: accept
      })
      .then(response => {
        const data = response.data;
        setRequests(data);
        setRequestsRaw(data);
        setWorking(false);
      })
      .catch(error => {
        const fail_data = new Object();
        fail_data.notice = "The operation failed";
        fail_data.success = false;
        console.log("error", error);
        return fail_data;
      }).finally(() => {
        dispatch(endTask());
      });
  };

  return 0 < requests.length ? (
    <Panel>

      <h1>Decision Enrollment Requests</h1>
      <p>
        The following students are trying to enroll in your course. Please
        accept or decline each enrollment.
      </p>
      <WorkingIndicator identifier="loading_enrollments" />
      <DataTable
        value={requests.filter(request => {
          return filterText.length === 0 || request.cap_name.includes(filterText.toUpperCase());
        })}
        resizableColumns
        tableStyle={{
          minWidth: '50rem'
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={
          [5, 10, 20, 100]
        }
        virtualScrollerOptions={{ itemSize: 100 }}
        onRowClick={drillDown}
        header={
          <StandardListToolbar
            itemType={'invitation'}
            filtering={
              {
                filterValue: filterText,
                setFilterFunc: setFilterText
              }
            }
          />}
        sortField="name"
        paginatorDropdownAppendTo={'self'}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
      >
        <Column
          header='First Name'
          field='first_name'
          sortable

        />
        <Column
          header='Last Name'
          field='last_name'
          sortable

        />
        <Column
          header='Course Name'
          field='course_name'
          sortable

        />
        <Column
          header='Course Number'
          field='course_number'
          sortable

        />
        <Column
          header={t("accept_decline")}
          field='id'
          sortable
          body={(rowData) => {
            const id = rowData.id;
            return (
              <React.Fragment>
                <Button
                  onClick={() => {
                    decision(id, true);
                  }}
                  aria-label="Accept"
                  tooltip="Accept"
                  size="small"
                  rounded
                  raised
                  icon="pi pi-thumbs-up"
                  disabled={working}
                />
                <Button
                  onClick={() => {
                    decision(id, false);
                  }}
                  aria-label="Reject"
                  tooltip="Reject"
                  size="small"
                  rounded
                  raised
                  icon="pi pi-thumbs-down"
                  disabled={working}
                />
              </React.Fragment>
            )
          }}

        />

      </DataTable>
    </Panel>
  ) : null;
}
