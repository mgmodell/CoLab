import React, { useState } from "react";
import { useNavigate } from "react-router";

import { useDispatch } from "react-redux";

import { useTranslation } from "react-i18next";
import {Temporal, TemporalSettings} from "../infrastructure/TemporalSettings";
  
import { ISubmissionCondensed } from "./AssignmentViewer";
import { DataTable } from "primereact/datatable";
import AdminListToolbar from "../toolbars/AdminListToolbar";
import { Column } from "primereact/column";

type Props = {
  submissions: Array<ISubmissionCondensed>;
  selectSubmissionFunc: (selectedSub: string) => void;
};

enum OPT_COLS {
  RECORDED_SCORE = "recorded_score",
  SUBMITTED = "submitted",
  WITHDRAWN = "withdrawn",
  USER = "user"
}

export default function SubmissionList(props: Props) {
  const category = "assignment";

  const { t } = useTranslation(`${category}s`);

  const [showErrors, setShowErrors] = useState(false);

  const [filterText, setFilterText] = useState("");
  const optColumns = [
    OPT_COLS.RECORDED_SCORE,
    OPT_COLS.SUBMITTED,
    OPT_COLS.USER,
    OPT_COLS.WITHDRAWN
  ];
  const [visibleColumns, setVisibleColumns] = useState([]);

  return (
    <React.Fragment>
      <div style={{ display: "flex", height: "100%" }}>
        <div style={{ flexGrow: 1 }}>
          <DataTable
            value={props.submissions.filter(submission => {
              return (
                filterText.length === 0 || submission.user.includes(filterText)
              );
            })}
            resizableColumns
            tableStyle={{
              minWidth: "50rem"
            }}
            reorderableColumns
            paginator
            rows={5}
            rowsPerPageOptions={[5, 10, 20, props.submissions.length]}
            header={
              <AdminListToolbar
                itemType={"response"}
                newItemFunc={props.selectSubmissionFunc}
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
            sortField={OPT_COLS.SUBMITTED}
            paginatorDropdownAppendTo={"self"}
            paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
            currentPageReportTemplate="{first} to {last} of {totalRecords}"
            itemID="submissionList"
            name="submissionList"
            id="submissionList"
            dataKey="id"
            onRowClick={event => {
              props.selectSubmissionFunc(event.data.id);
            }}
          >
            <Column
              header={t("submissions.score")}
              field={OPT_COLS.RECORDED_SCORE}
              sortable
              filter
              key={OPT_COLS.RECORDED_SCORE}
            />
            <Column
              header={t("submissions.submitted")}
              field={OPT_COLS.SUBMITTED}
              sortable
              filter
              key={OPT_COLS.SUBMITTED}
              body={rowData => {

                if (rowData.submitted) {
                  const tDate = Temporal.Instant.from(rowData.submitted);
                  return tDate.toZonedDateTimeISO(TemporalSettings.defaultZone)
                  .toLocaleString('en-US', {
                    year: "numeric",
                    month: "2-digit",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit",
                    hour12: false
                  }).toString();
                } else {
                  return t("submissions.not_submitted");
                }
              }}
            />
            <Column
              header={t("submissions.withdrawn")}
              field={OPT_COLS.WITHDRAWN}
              sortable
              filter
              key={OPT_COLS.WITHDRAWN}
            />
            <Column
              header={t("submissions.user")}
              field={OPT_COLS.USER}
              sortable
              filter
              key={OPT_COLS.USER}
            />
          </DataTable>
        </div>
      </div>
    </React.Fragment>
  );
}
