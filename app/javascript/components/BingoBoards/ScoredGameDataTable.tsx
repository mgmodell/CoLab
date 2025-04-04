import React, { useState } from "react";

import { useTranslation } from "react-i18next";

import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import StandardListToolbar from "../toolbars/StandardListToolbar";
import { IBingoCandidate } from "./BingoBuilder";

enum OPT_COLS {
  TERM = "term",
  DEFINITION = "definition",
  FEEDBACK = "feedback",
  CONCEPT = "concept",
  CREDIT = "credit"
}

type Props = {
  candidates: Array< IBingoCandidate >
};

export default function ScoredGameDataTable(props: Props) {
  const category = "bingo_game";
  const { t } = useTranslation(`${category}s`);
  const optColumns = [
    t(`scored_game.${OPT_COLS.DEFINITION}`),
    t(`scored_game.${OPT_COLS.FEEDBACK}`),
    t(`scored_game.${OPT_COLS.CONCEPT}`),
    t(`scored_game.${OPT_COLS.CREDIT}`)
  ];
  const [visibleColumns, setVisibleColumns] = useState(optColumns);

  return (
    <DataTable
      value={props.candidates}
      resizableColumns
      tableStyle={{
        minWidth: "50rem"
      }}
      reorderableColumns
      paginator
      rows={5}
      rowsPerPageOptions={[5, 10, 20, props.candidates.length]}
      virtualScrollerOptions={{ itemSize: 100 }}
      header={
        <StandardListToolbar
          itemType={t("scored_game.list_title")}
          columnToggle={{
            optColumns: optColumns,
            visibleColumns: visibleColumns,
            setVisibleColumnsFunc: setVisibleColumns
          }}
        />
      }
      sortField="term"
      paginatorDropdownAppendTo={"self"}
      paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
      currentPageReportTemplate="{first} to {last} of {totalRecords}"
      //paginatorLeft={paginatorLeft}
      //paginatorRight={paginatorRight}
      dataKey="id"
    >
      <Column
        header={t(`scored_game.${OPT_COLS.TERM}`)}
        field="term"
        sortable
        key="term"
      />
      {visibleColumns.includes(t(`scored_game.${OPT_COLS.DEFINITION}`)) ? (
        <Column
          header={t(`scored_game.${OPT_COLS.DEFINITION}`)}
          field="definition"
          sortable
          key="definition"
        />
      ) : null}
      {visibleColumns.includes(t(`scored_game.${OPT_COLS.FEEDBACK}`)) ? (
        <Column
          header={t(`scored_game.${OPT_COLS.FEEDBACK}`)}
          field="feedback"
          sortable
          filter
          key="feedback"
        />
      ) : null}
      {visibleColumns.includes(t(`scored_game.${OPT_COLS.CONCEPT}`)) ? (
        <Column
          header={t(`scored_game.${OPT_COLS.CONCEPT}`)}
          field="concept"
          sortable
          key="concept"
        />
      ) : null}
      {visibleColumns.includes(t(`scored_game.${OPT_COLS.CREDIT}`)) ? (
        <Column
          header={t(`scored_game.${OPT_COLS.CREDIT}`)}
          field="credit"
          sortable
          filter
          key="credit"
        />
      ) : null}
    </DataTable>
  );
}
