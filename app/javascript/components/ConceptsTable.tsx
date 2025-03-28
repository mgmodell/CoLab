/* eslint-disable no-console */
import React, { useEffect, useState } from "react";
import axios from "axios";

import { SortDirection } from "react-virtualized";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { useTranslation } from "react-i18next";

import WorkingIndicator from "./infrastructure/WorkingIndicator";
import StandardListToolbar from "./toolbars/StandardListToolbar";

import { Button } from "primereact/button";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Dialog } from "primereact/dialog";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";
import { InputText } from "primereact/inputtext";

enum OPT_COLS {
  NAME = "name",
  USE_COUNT = "use_count",
  COURSES = "courses",
  GAMES = "games"
}

export default function ConceptsTable() {
  const category = "concept";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status["endpointsLoaded"]
  );
  const { t } = useTranslation(`${category}s`);
  const dispatch = useDispatch();

  const [conceptsRaw, setConceptsRaw] = useState([]);
  const [concepts, setConcepts] = useState([]);
  const [filterText, setFilterText] = useState("");
  const optColumns = [
    t(OPT_COLS.USE_COUNT),
    t(OPT_COLS.COURSES),
    t(OPT_COLS.GAMES)
  ];
  const [visibleColumns, setVisibleColumns] = useState([]);

  //const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState("name");
  const [sortDirection, setSortDirection] = useState(SortDirection.DESC);

  const [editing, setEditing] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [conceptName, setConceptName] = useState("");
  const [conceptId, setConceptId] = useState(-1);

  useEffect(() => {
    if (endpointStatus) {
      getConcepts();
    }
  }, [endpointStatus]);

  const setName = newName => {
    setConceptName(newName);
    setDirty(true);
  };

  const getConcepts = () => {
    dispatch(startTask("load"));
    //statusActions.startTask("load");
    axios
      .get(endpoints.baseUrl + ".json", {})
      .then(response => {
        const data = response.data;
        setConcepts(data);
        setConceptsRaw(data);
        dispatch(endTask("load"));
      })
      .catch(error => {
        console.log(error);
        return [{ id: -1, name: "no data" }];
        dispatch(endTask("load"));
      });
  };

  const drillDown = event => {
    setConceptId(event.data.id);
    setConceptName(event.data.name);
    setEditing(true);
    setDirty(false);
  };
  const updateConcept = (id, name) => {
    dispatch(startTask("load"));
    //statusActions.startTask("load");
    axios
      .patch(endpoints.baseUrl + "/" + id + ".json", {
        concept: {
          id: id,
          name: name
        }
      })
      .then(resp => {
        const data = resp.data;
        const tmpConcepts = Object.assign([], conceptsRaw);
        const updatedObject = tmpConcepts.find(element => element.id == id);
        updatedObject.name = data.name;
        updatedObject.cap_name = data.name.toUpperCase();

        setConcepts(tmpConcepts);
        setConceptsRaw(tmpConcepts);
        dispatch(endTask("load"));
        //statusActions.endTask("load");
        setEditing(false);
      })
      .catch(error => {
        console.log("error:", error);
        return [{ id: -1, name: "no data" }];
      });
  };
  return (
    <React.Fragment>
      <DataTable
        value={concepts.filter(concept => {
          return (
            filterText.length === 0 ||
            concept.cap_name.includes(filterText.toUpperCase())
          );
        })}
        resizableColumns
        tableStyle={{
          minWidth: "50rem"
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={[5, 10, 20, 100]}
        virtualScrollerOptions={{ itemSize: 100 }}
        onRowClick={drillDown}
        header={
          <StandardListToolbar
            itemType={"concept"}
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
        sortField="name"
        paginatorDropdownAppendTo={"self"}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
      >
        <Column header={t("name")} field="name" sortable filter key="name" />
        {visibleColumns.includes(t(OPT_COLS.USE_COUNT)) ? (
          <Column
            header={t("use_count")}
            field="times"
            sortable
            filter
            key="times"
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.COURSES)) ? (
          <Column
            header={t("courses")}
            field="courses"
            sortable
            filter
            key="courses"
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.GAMES)) ? (
          <Column
            header={t("games")}
            field="bingos"
            sortable
            filter
            key="bingos"
          />
        ) : null}
      </DataTable>
      <Dialog
        visible={editing}
        onHide={() => setEditing(false)}
        aria-labelledby="edit"
        header={t("edit.title")}
        footer={
          <>
            <Button onClick={() => setEditing(false)}>{t("cancel")}</Button>
            <Button
              id="update_concept"
              onClick={() => updateConcept(conceptId, conceptName)}
              disabled={!dirty}
            >
              {t("update_con")}
            </Button>
          </>
        }
      >
        <WorkingIndicator identifier="saving_concept" />
        {t("concept_name")}
        <InputText
          id="conceptName"
          value={conceptName}
          onChange={event => setName(event.target.value)}
        />
      </Dialog>
    </React.Fragment>
  );
}
