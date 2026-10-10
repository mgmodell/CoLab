import React from "react";

import { useNavigate } from "react-router";
import { useTranslation } from "react-i18next";

import { InputText } from "primereact/inputtext";
import { MultiSelect } from "primereact/multiselect";
import { Dropdown } from "primereact/dropdown";

import { Toolbar } from "primereact/toolbar";

export type GroupBy = "type" | "course" | "week";

type Props = {
  filtering?: {
    filterValue: string;
    setFilterFunc: (string) => void;
  };
  grouping?: {
    label: string;
    value: GroupBy;
    options: Array<{ label: string; value: GroupBy }>;
    setGroupByFunc: (value: GroupBy) => void;
  };
  columnToggle?: {
    optColumns: Array<string>;
    visibleColumns: Array<string>;
    setVisibleColumnsFunc: (Array) => void;
  };
};

export default function TaskListToolbar(props: Props) {
  const { t } = useTranslation(`admin`);
  const navigate = useNavigate();
  const groupingId = React.useId();
  const onColumnToggle = event => {
    props.columnToggle.setVisibleColumnsFunc(event.value);
  };

  const columnToggle =
    undefined !== props.columnToggle ? (
      <MultiSelect
        aria-label="View Columns"
        inputId="task-view-columns"
        value={props.columnToggle.visibleColumns}
        options={props.columnToggle.optColumns}
        placeholder={t("toggle_columns_plc")}
        onChange={onColumnToggle}
        className="w-full sm:w-20rem"
        display="chip"
      />
    ) : null;

  const groupingProps = props.grouping;
  const grouping = groupingProps ? (
    <div className="flex align-items-center gap-2">
      <label htmlFor={groupingId}>{groupingProps.label}</label>
      <Dropdown
        inputId='task-group-by'
        value={groupingProps.value}
        options={groupingProps.options}
        onChange={event => groupingProps.setGroupByFunc(event.value)}
      />
    </div>
  ) : null;

  const search =
    undefined !== props.filtering ? (
      <div className="flex justify-content-end">
        <span className="p-input-icon-left">
          <i className="pi pi-search" />
          <InputText
            id={`task-search`}
            value={props.filtering.filterValue}
            onChange={event => {
              props.filtering.setFilterFunc(event.target.value);
            }}
            placeholder="Search"
          />
        </span>
      </div>
    ) : null;

  return (
    <Toolbar
      center={columnToggle}
      end={
        <>
          {grouping}
          {search}
        </>
      }
    />
  );
}
