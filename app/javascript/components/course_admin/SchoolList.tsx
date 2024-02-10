import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import AdminListToolbar from "../infrastructure/AdminListToolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";

enum OPT_COLS {
  STUDENTS = "students",
  COURSES = "courses",
  INSTRS = "instructors",
  PROJS = "projects",
  EXPS = "experiences",
  BINGO = "bingo!"
}

export default function SchoolList(props) {
  const category = "school";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t } = useTranslation(`${category}s`);

  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const navigate = useNavigate();

  const dispatch = useDispatch();

  const [schools, setSchools] = useState([]);
  const [filterText, setFilterText] = useState("");

  const optColumns = [
    OPT_COLS.STUDENTS,
    OPT_COLS.COURSES,
    OPT_COLS.INSTRS,
    OPT_COLS.PROJS,
    OPT_COLS.EXPS,
    OPT_COLS.BINGO
  ];
  const [visibleColumns, setVisibleColumns] = useState([]);

  const getSchools = () => {
    const url = endpoints.baseUrl + ".json";

    dispatch(startTask());
    axios.get(url, {}).then(response => {
      //Process the data
      setSchools(response.data);
      dispatch(endTask("loading"));
    });
  };

  useEffect(() => {
    if (endpointStatus) {
      getSchools();
      dispatch(endTask("loading"));
    }
  }, [endpointStatus]);

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
  };

  const schoolTable = (
    <DataTable
      value={schools.filter(school => {
        return filterText.length === 0 || school.name.includes(filterText);
      })}
      resizableColumns
      reorderableColumns
      paginator
      rows={5}
      tableStyle={{
        minWidth: "50rem"
      }}
      rowsPerPageOptions={[5, 10, 20, schools.length]}
      header={
        <AdminListToolbar
          itemType={category}
          filtering={{
            filterValue: filterText,
            setFilterFunc: setFilterText
          }}
          columnToggle={{
            setVisibleColumnsFunc: setVisibleColumns,
            optColumns: optColumns,
            visibleColumns: visibleColumns
          }}
        />
      }
      sortField="name"
      sortOrder={1}
      paginatorDropdownAppendTo={"self"}
      paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
      currentPageReportTemplate="{first} to {last} of {totalRecords}"
      dataKey="id"
      onRowClick={event => {
        navigate(String(event.data.id));
      }}
    >
      <Column
        header={t("index.name_lbl")}
        field="name"
        sortable
        filter
        key={"name"}
      />
      {visibleColumns.includes(OPT_COLS.COURSES) ? (
        <Column
          header={t("index.courses_lbl")}
          field="courses"
          sortable
          filter
          key={"courses"}
        />
      ) : null}
      {visibleColumns.includes(OPT_COLS.STUDENTS) ? (
        <Column
          header={t("index.students_lbl")}
          field="students"
          sortable
          filter
          key={"students"}
        />
      ) : null}
      {visibleColumns.includes(OPT_COLS.INSTRS) ? (
        <Column
          header={t("index.instructors_lbl")}
          field="instructors"
          sortable
          filter
          key={"instructors"}
        />
      ) : null}
      {visibleColumns.includes(OPT_COLS.PROJS) ? (
        <Column
          header={t("index.project_lbl")}
          field="project"
          sortable
          filter
          key={"project"}
        />
      ) : null}
      {visibleColumns.includes(OPT_COLS.EXPS) ? (
        <Column
          header={t("index.experience_lbl")}
          field="experience"
          sortable
          filter
          key={"experience"}
        />
      ) : null}
      {visibleColumns.includes(OPT_COLS.BINGO) ? (
        <Column
          header={t("index.terms_list_lbl")}
          field="terms_lists"
          sortable
          filter
          key={"terms_list"}
        />
      ) : null}
    </DataTable>
  );

  return (
    <React.Fragment>
      <div style={{ maxWidth: "100%" }}>{schoolTable}</div>
    </React.Fragment>
  );
}
