import React, { useState, useEffect } from "react";
import { iconForType } from "../ActivityLib";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import WorkingIndicator from "../infrastructure/WorkingIndicator";

import axios from "axios";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router";
import { DateTime } from "luxon";
import StandardListToolbar from "../toolbars/StandardListToolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Panel } from "primereact/panel";

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

enum OPT_COLS {
  NAME = "name",
  TYPE = "type",
  COURSE_NAME = "course_name",
  COURSE_NUMBER = "course_number"
}

export default function UserActivityList(props: Props) {
  // const [addUsersPath, setAddUsersPath] = useState("");
  // const [procRegReqPath, setProcRegReqPath] = useState("");
  const dispatch = useDispatch();

  const category = "profile";
  const { t } = useTranslation(`${category}s`);
  const navigate = useNavigate();
  const [filterText, setFilterText] = useState("");

  const optColumns = [
    t(`activities.${OPT_COLS.TYPE}`),
    t(`activities.${OPT_COLS.COURSE_NAME}`),
    t(`activities.${OPT_COLS.COURSE_NUMBER}`)
  ];
  const [visibleColumns, setVisibleColumns] = useState([]);

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

  const activityList =
    undefined !== props.activitiesList ? (
      <DataTable
        value={props.activitiesList.filter(activity => {
          return (
            filterText.length === 0 ||
            activity.course_name.includes(filterText) ||
            activity.course_number.includes(filterText) ||
            activity.name.includes(filterText)
          );
        })}
        resizableColumns
        tableStyle={{
          minWidth: "50rem"
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={[5, 10, 20, props.activitiesList.length]}
        header={
          <StandardListToolbar
            itemType={"activity"}
            filtering={{
              filterValue: filterText,
              setFilterFunc: setFilterText
            }}
            columnToggle={{
              optColumns: optColumns,
              visibleColumns: visibleColumns,
              setVisibleColumnsFunc: setVisibleColumns
            }}
          />
        }
        sortField="course_name"
        sortOrder={-1}
        paginatorDropdownAppendTo={"self"}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
        onRowClick={event => {
          if (event.data.link !== null) {
            navigate(
              `/home/${event.data.link}`,
              { relative: "route" }
            );
          }
        }}
      >
        <Column header={t("activities.name")} field="name" sortable filter />
        <Column
          header={t("activities.type")}
          field="type"
          sortable
          filter
          body={rowData => {
            return iconForType(rowData.type);
          }}
        />
        <Column
          header={t("activities.course_name")}
          field="course_name"
          sortable
          filter
        />
        <Column
          header={t("activities.course_number")}
          field="course_number"
          sortable
          filter
        />
      </DataTable>
    ) : (
      "The activities are loading"
    );

  return (
    <Panel>
      <WorkingIndicator identifier="activity_list_loading" />
      {activityList}
    </Panel>
  );
}
