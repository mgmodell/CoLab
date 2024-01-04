import React, { useState } from "react";

import { useTranslation } from "react-i18next";
import axios from "axios";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { InputText } from "primereact/inputtext";
import { Button } from "primereact/button";
import { PrimeIcons } from "primereact/api";
import { MultiSelect } from "primereact/multiselect";
import { Dialog } from "primereact/dialog";
import { StudentData } from "./CourseUsersList";

import { Toolbar } from "primereact/toolbar";

type Props = {
  courseId: number;
  userType: string;
  retrievalUrl: string;
  usersListUpdateFunc: (usersList: Array<StudentData>) => void;
  addMessagesFunc: ({}) => void;
  refreshUsersFunc: () => void;
  addUsersPath: string;

  filtering?: {
    filterValue: string;
    setFilterFunc: (string) => void;
  };
  columnToggle?: {
    optColumns: Array<string>;
    visibleColumns: Array<string>;
    setVisibleColumnsFunc: (selectedColumns: Array<string>) => void;
  };
};

export default function UserListAdminToolbar(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);
  const dispatch = useDispatch();

  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newUserAddresses, setNewUserAddresses] = useState("");

  const closeDialog = () => {
    setNewUserAddresses("");
    setAddDialogOpen(false);
  };

  const lbl = t("add_lbl", { user_type: props.userType });

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
    <h3>{props.userType.charAt(0).toUpperCase() + props.userType.slice(1)}s</h3>
  );

  const createButton = (
    <Button
      tooltip={t("new_user", { user_type: props.userType })}
      id={`new_${props.userType}`}
      onClick={event => {
        setAddDialogOpen(true);
      }}
      aria-label={`New ${props.userType}`}
      icon={PrimeIcons.PLUS}
      rounded
      raised
    >
      {t("new_user", { user_type: props.userType })}
    </Button>
  );

  const search =
    undefined !== props.filtering ? (
      <div className="flex justify-content-end">
        <span className="p-input-icon-left">
          <i className="pi pi-search" />
          <InputText
            id={`${props.userType}-search`}
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
    <>
      <Dialog
        header={lbl}
        visible={addDialogOpen}
        onHide={closeDialog}
        aria-labelledby="adduser-dialog"
        footer={() => {
          return (
            <>
              <Button
                onClick={() => {
                  dispatch(startTask("adding_email"));
                  //dispatch<AsyncThunkAction<any, any, any>>(startTask("adding_email"));

                  axios
                    .put(props.addUsersPath, {
                      id: props.courseId,
                      addresses: newUserAddresses
                    })
                    .then(response => {
                      const data = response.data;
                      props.addMessagesFunc(data.messages);
                      props.refreshUsersFunc();
                    })
                    .finally(() => {
                      dispatch(endTask("adding_email"));
                    });
                  closeDialog();
                }}
                color="primary"
              >
                {t("show.add_btn", { user_type: props.userType })}
              </Button>
              <Button onClick={() => closeDialog()}>{t("Cancel")}</Button>
            </>
          );
        }}
      >
        <p>Add {props.userType}s by email:</p>
        <label htmlFor="addresses" className="p-d-block">
          Email Address
        </label>
        <InputText
          id="addresses"
          placeholder="Email Address"
          type="email"
          value={newUserAddresses}
          onChange={event => setNewUserAddresses(event.target.value)}
        />
      </Dialog>

      <Toolbar
        start={title}
        center={createButton}
        end={
          <>
            {columnToggle}
            {search}
          </>
        }
      />
    </>
  );
}
