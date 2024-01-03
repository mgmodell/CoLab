import React, { useRef, useState } from "react";

import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import AddIcon from "@mui/icons-material/Add";

import { iconForType } from "../ActivityLib";
import { Toolbar } from "primereact/toolbar";
import { Button } from "primereact/button";
import { Menu } from "primereact/menu";
import { InputText } from "primereact/inputtext";
import { MultiSelect } from "primereact/multiselect";

interface IActivityLink {
  name: string;
  link: string;
}
type Props = {
  newActivityLinks: Array<IActivityLink>;
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

export default function CourseAdminListToolbar(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);
  const navigate = useNavigate();
  const addMenu = useRef(null);

  const title = (
    <h3>{t('activities_list_ttl')}&nbsp;</h3>
  )
  const [menuAnchorEl, setMenuAnchorEl] = useState(null);
  const menuModel = props.newActivityLinks.map(linkData => {
    return (
      {
        label: ` New ${linkData.name}…`,
        key: linkData.name,
        icon: iconForType(linkData.name),
        command: (event) => {
          setMenuAnchorEl(null);
          navigate(`${linkData.link}/new`);
        }
      }
    )
  });
  const onColumnToggle = event => {
    props.columnToggle.setVisibleColumnsFunc(event.value);
  }

  const columnToggle = undefined !== props.columnToggle ? (
    <MultiSelect
      value={props.columnToggle.visibleColumns}
      options={props.columnToggle.optColumns}
      placeholder={t("toggle_columns_plc")}
      onChange={onColumnToggle}
      className="w-full sm:w-20rem"
      display="chip"
      /> ) : null;

  const search = undefined !== props.filtering ? (
              <div className="flex justify-content-end">
                <span className="p-input-icon-left">
                    <i className="pi pi-search" />
                    <InputText
                      id={`${props.userType}-search`}
                      value={props.filtering.filterValue}
                      onChange={(event) =>{
                        props.filtering.setFilterFunc( event.target.value );
                      }}
                      placeholder="Search" />
                </span>
            </div>

  ) : null;
  const addButton = (
    <React.Fragment>
      <Menu
        popup
        model={menuModel}
        ref={addMenu}
      />
      <Button
        tooltip={t("new_activity")}
        id={`new_activity`}
        onClick={event => {
          addMenu.current.toggle(event);
        }}
        icon="pi pi-plus"
        className="p-button-success p-mr-2"
      />
    </React.Fragment>
  );
  return (
    <Toolbar
      start={
        (<>
          {title}
          {addButton}
        </>)
        }
      end={(
        <>
          {columnToggle}
          {search}
        </>
      )}
    />
  );
}
