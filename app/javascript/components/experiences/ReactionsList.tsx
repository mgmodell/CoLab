import React, { useState, useEffect, useRef } from "react";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import axios from "axios";
import { useTranslation } from "react-i18next";
import StandardListToolbar from "../toolbars/StandardListToolbar";

import { OverlayPanel } from "primereact/overlaypanel";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";

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
  total_time: number | null;
  avg_diagnosis_time: number | null;
  std_dev_diagnosis_time: number | null;
  reaction_time: number | null;
}

const formatDuration = (seconds: number | null | undefined) => {
  if (null === seconds || undefined === seconds) {
    return "N/A";
  }
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${h}:${pad(m)}:${pad(s)}`;
};
type Props = {
  retrievalUrl: string;
  reactionsList: Array<IReaction>;
  reactionsListUpdateFunc: (reactionList: Array<IReaction>) => void;
};

enum OPT_COLS {
  USER = "reactions.student_lbl",
  EMAIL = "reactions.email_lbl",
  STATUS = "reactions.completion_lbl",
  NARRATIVE = "reactions.narrative_lbl",
  SCENARIO = "reactions.scenario_lbl",
  RESPONSE = "reactions.response_lbl",
  IMPROVEMENTS = "reactions.improvements_lbl",
  TOTAL_TIME = "reactions.total_time_lbl",
  AVG_DIAGNOSIS_TIME = "reactions.avg_diagnosis_time_lbl",
  STD_DEV_DIAGNOSIS_TIME = "reactions.std_dev_diagnosis_time_lbl",
  REACTION_TIME = "reactions.reaction_time_lbl"
}

export default function ReactionsList(props: Props) {
  const category = "experience";
  const { t } = useTranslation(`${category}s`);
  const [filterText, setFilterText] = useState("");
  const optColumns = [
    t(OPT_COLS.EMAIL),
    t(OPT_COLS.STATUS),
    t(OPT_COLS.NARRATIVE),
    t(OPT_COLS.SCENARIO),
    t(OPT_COLS.RESPONSE),
    t(OPT_COLS.IMPROVEMENTS),
    t(OPT_COLS.TOTAL_TIME),
    t(OPT_COLS.AVG_DIAGNOSIS_TIME),
    t(OPT_COLS.STD_DEV_DIAGNOSIS_TIME),
    t(OPT_COLS.REACTION_TIME)
  ];
  const [visibleColumns, setVisibleColumns] = useState([
    t(OPT_COLS.STATUS),
    t(OPT_COLS.IMPROVEMENTS),
    t(OPT_COLS.TOTAL_TIME),
    t(OPT_COLS.AVG_DIAGNOSIS_TIME),
    t(OPT_COLS.STD_DEV_DIAGNOSIS_TIME),
    t(OPT_COLS.REACTION_TIME)
  ]);

  const [anchorEl, setAnchorEl] = useState();
  const [popMsg, setPopMsg] = useState();
  const op = useRef(null);

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
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  useEffect(() => {
    if (undefined == props.reactionsList) {
      getReactions();
    }
  }, []);

  return undefined !== props.reactionsList ? (
    <React.Fragment>
      <DataTable
        value={props.reactionsList.filter(reaction => {
          return (
            filterText.length === 0 ||
            reaction.course_name.includes(filterText) ||
            reaction.course_number.includes(filterText) ||
            reaction.name.includes(filterText)
          );
        })}
        resizableColumns
        tableStyle={{
          minWidth: "50rem"
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={[5, 10, 20, props.reactionsList.length]}
        header={
          <StandardListToolbar
            itemType={"Response"}
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
        sortField="user.last_name"
        sortOrder={1}
        paginatorDropdownAppendTo={"self"}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        dataKey="id"
      >
        <Column
          header={t(OPT_COLS.USER)}
          field="user"
          sortable
          filter
          body={rowData => {
            const user = rowData.user;
            return <a href={`mailto:${user.email}`}>{user.name}</a>;
          }}
        />
        {visibleColumns.includes(t(OPT_COLS.EMAIL)) ? (
          <Column
            header={t(OPT_COLS.EMAIL)}
            field="id"
            sortable
            filter
            body={rowData => {
              const user = rowData.user;
              return <a href={`mailto:${user.email}`}>{user.email}</a>;
            }}
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.STATUS)) ? (
          <Column
            header={t(OPT_COLS.STATUS)}
            field={"status"}
            sortable
            filter
            body={rowData => {
              return rowData.status + "%";
            }}
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.NARRATIVE)) ? (
          <Column
            header={t(OPT_COLS.NARRATIVE)}
            field={"narrative"}
            sortable
            filter
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.SCENARIO)) ? (
          <Column
            header={t(OPT_COLS.SCENARIO)}
            field="scenario"
            sortable
            filter
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.RESPONSE)) ? (
          <Column
            header={t(OPT_COLS.RESPONSE)}
            field="behavior"
            sortable
            filter
            body={rowData => {
              if ("Other" == rowData.behavior) {
                return (
                  <a
                    onClick={event => {
                      setPopMsg(rowData.other_name);
                      op.current.toggle(event);
                    }}
                  >
                    {rowData.behavior}
                  </a>
                );
              } else {
                return rowData.behavior;
              }
            }}
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.IMPROVEMENTS)) ? (
          <Column
            header={t(OPT_COLS.IMPROVEMENTS)}
            field="improvements"
            sortable
            filter
            body={rowData => {
              if ("" != rowData.improvements) {
                return (
                  <a
                    onClick={event => {
                      setPopMsg(rowData.improvements);
                      op.current.toggle(event);
                    }}
                  >
                    {t("reactions.suggestions_lbl")}
                  </a>
                );
              } else {
                return "N/A";
              }
            }}
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.TOTAL_TIME)) ? (
          <Column
            header={t(OPT_COLS.TOTAL_TIME)}
            field="total_time"
            sortable
            body={rowData => formatDuration(rowData.total_time)}
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.AVG_DIAGNOSIS_TIME)) ? (
          <Column
            header={t(OPT_COLS.AVG_DIAGNOSIS_TIME)}
            field="avg_diagnosis_time"
            sortable
            body={rowData => formatDuration(rowData.avg_diagnosis_time)}
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.STD_DEV_DIAGNOSIS_TIME)) ? (
          <Column
            header={t(OPT_COLS.STD_DEV_DIAGNOSIS_TIME)}
            field="std_dev_diagnosis_time"
            sortable
            body={rowData => formatDuration(rowData.std_dev_diagnosis_time)}
          />
        ) : null}
        {visibleColumns.includes(t(OPT_COLS.REACTION_TIME)) ? (
          <Column
            header={t(OPT_COLS.REACTION_TIME)}
            field="reaction_time"
            sortable
            body={rowData => formatDuration(rowData.reaction_time)}
          />
        ) : null}
      </DataTable>
      <OverlayPanel
        ref={op}
        showCloseIcon
        dismissable
        style={{ width: "50rem" }}
      >
        <p>{popMsg}</p>
      </OverlayPanel>
    </React.Fragment>
  ) : (
    <div>Loading...</div>
  );
}
