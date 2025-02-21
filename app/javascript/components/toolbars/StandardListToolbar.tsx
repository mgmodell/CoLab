import React from "react";

import { useTranslation } from "react-i18next";

import { InputText } from "primereact/inputtext";
import { MultiSelect } from "primereact/multiselect";

import { Toolbar } from "primereact/toolbar";

type Props = {
  itemType: string;
  filtering?: {
    filterValue: string;
    setFilterFunc: (string) => void;
  };
  columnToggle?: {
    optColumns: Array<string>;
    visibleColumns: Array<string>;
    setVisibleColumnsFunc: (Array) => void;
  };
};

export default function StandardListToolbar(props: Props) {
  const { t } = useTranslation(`admin`);
  const onColumnToggle = event => {
    props.columnToggle.setVisibleColumnsFunc(event.value);
  };

  const columnToggle =
    undefined !== props.columnToggle ? (
      <MultiSelect
        value={props.columnToggle.visibleColumns}
        options={props.columnToggle.optColumns}
        placeholder={t("toggle_columns_plc")}
        onChange={onColumnToggle}
        className="w-full sm:w-20rem"
        display="chip"
      />
    ) : null;

  const title = (
    <h3>{props.itemType.charAt(0).toUpperCase() + props.itemType.slice(1)}s</h3>
  );

  const search =
    undefined !== props.filtering ? (
      <div className="flex justify-content-end">
        <span className="p-input-icon-left">
          <i className="pi pi-search" />
          <InputText
            id={`${props.itemType}-search`}
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
      start={title}
      end={
        <>
          {columnToggle}
          {search}
        </>
      }
    />
  );
}
