import React from "react";

import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import { InputText } from "primereact/inputtext";
import { Button } from "primereact/button";
import { PrimeIcons } from "primereact/api";
import { MultiSelect } from "primereact/multiselect";

import { Toolbar } from "primereact/toolbar";

type Props = {
  itemType: string;
  newItemFunc?: (string) => void;
  filtering?: {
    filterValue: string;
    setFilterFunc: (string) => void;
  };
  columnToggle?: {
    optColumns: Array<string>;
    visibleColumns: Array<string>;
    setVisibleColumnsFunc: (Array) => void;

  }
};

export default function AdminListToolbar(props: Props) {
  const { t } = useTranslation(`admin`);
  const navigate = useNavigate();
  const onColumnToggle = event => {
    props.columnToggle.setVisibleColumnsFunc(event.value);

  };

  const columnToggle = undefined !== props.columnToggle ? (
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
            <h3>{props.itemType.charAt(0).toUpperCase() + props.itemType.slice( 1 )}s</h3>
  );

  const createButton = (

            <Button
              tooltip={t('new_activity', {activity_type: props.itemType})}
              id={`new_${props.itemType}`}
              onClick={event => {
                if( undefined === props.newItemFunc ){
                  navigate("new");
                } else {
                  props.newItemFunc( 'new' );
                }
              }}
              aria-label={`New ${props.itemType}`}
              icon={ PrimeIcons.PLUS} rounded raised >
                {t("new_activity", { activity_type: props.itemType })}

              </Button>
  );

  const search = undefined !== props.filtering ? (
              <div className="flex justify-content-end">
                <span className="p-input-icon-left">
                    <i className="pi pi-search" />
                    <InputText
                      id={`${props.itemType}-search`}
                      value={props.filtering.filterValue}
                      onChange={(event) =>{
                        props.filtering.setFilterFunc( event.target.value );
                      }}
                      placeholder="Search" />
                </span>
            </div>

  ) : null;


  return (
    <Toolbar
      start={title}
      center={createButton}
      end={(
        <>
          {columnToggle}
          {search}
        </>
      )}
    />
  );
}
