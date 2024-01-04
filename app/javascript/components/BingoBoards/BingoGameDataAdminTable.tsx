/* eslint-disable no-console */
import React from "react";

import { useTranslation } from "react-i18next";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import StandardListToolbar from "../StandardListToolbar";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { Panel } from "primereact/panel";

const BingoGameResults = React.lazy(() => import("./BingoGameResults"));

type Props = {
  results_raw: Array<any>;
};

enum OPT_COLS {
  PERFORMANCE = "List Performance",
  SCORE = "Worksheet Score",
  STUDENT = "Student",
  GROUP = "Group",
  EXPECTED = "Expected",
  ENTERED = "Entered",
  CREDITED = "Credited",
  TERM_PROBLEMS = "Term Problems"
}

export default function BingoGameDataAdminTable(props: Props) {
  const { t } = useTranslation();
  const user = useTypedSelector(state => state.profile.user);
  const [individual, setIndividual] = React.useState({
    student: "",
    board: [],
    candidates: [],
    score: 0
  });
  const [dialogOpen, setDialogOpen] = React.useState(false);

  const [filterText, setFilterText] = React.useState("");
  const optColumns = [
    OPT_COLS.GROUP,
    OPT_COLS.EXPECTED,
    OPT_COLS.ENTERED,
    OPT_COLS.CREDITED,
    OPT_COLS.TERM_PROBLEMS
  ];
  const [visibleColumns, setVisibleColumns] = React.useState([]);

  const openDialog = event => {
    const index = event.index;
    setIndividual({
      student: props.results_raw[index].student,
      board: props.results_raw[index].practice_answers,
      candidates: props.results_raw[index].candidates,
      score: props.results_raw[index].score
    });
    setDialogOpen(true);
  };

  return (
    <Panel>
      <DataTable
        value={props.results_raw}
        resizableColumns
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={[5, 10, 20, 100]}
        tableStyle={{
          width: "100%"
        }}
        scrollable
        scrollHeight="calc(100vh - 20rem)"
        className="p-datatable-striped p-datatable-gridlines"
        dataKey="id"
        onRowClick={event => {
          openDialog(event);
        }}
        header={
          <StandardListToolbar
            itemType={"invitation"}
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
      >
        <Column
          header={OPT_COLS.PERFORMANCE}
          field={"performance"}
          sortable
          filter
          key={"performance"}
        />

        <Column
          header={OPT_COLS.SCORE}
          field={"score"}
          sortable
          filter
          key={"score"}
        />
        <Column
          header={OPT_COLS.STUDENT}
          field={"student"}
          sortable
          filter
          key={"student"}
        />
        {visibleColumns.includes(OPT_COLS.GROUP) ? (
          <Column
            header={OPT_COLS.GROUP}
            field={"group"}
            sortable
            filter
            key={"group"}
          />
        ) : null}
        {visibleColumns.includes(OPT_COLS.EXPECTED) ? (
          <Column
            header={OPT_COLS.EXPECTED}
            field={"concepts_expected"}
            sortable
            filter
            key={"concepts_expected"}
          />
        ) : null}
        {visibleColumns.includes(OPT_COLS.ENTERED) ? (
          <Column
            header={OPT_COLS.ENTERED}
            field={"concepts_entered"}
            sortable
            filter
            key={"concepts_entered"}
          />
        ) : null}
        {visibleColumns.includes(OPT_COLS.CREDITED) ? (
          <Column
            header={OPT_COLS.CREDITED}
            field={"concepts_credited"}
            sortable
            filter
            key={"concepts_credited"}
          />
        ) : null}
        {visibleColumns.includes(OPT_COLS.TERM_PROBLEMS) ? (
          <Column
            header={OPT_COLS.TERM_PROBLEMS}
            field={"term_problems"}
            sortable
            filter
            key={"term_problems"}
          />
        ) : null}
      </DataTable>
      <BingoGameResults
        open={dialogOpen}
        student={individual.student}
        board={individual.board}
        score={individual.score}
        close={() => setDialogOpen(false)}
        candidates={individual.candidates}
      />
    </Panel>
  );
}
