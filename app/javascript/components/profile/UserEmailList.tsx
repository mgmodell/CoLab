import React, { useState } from "react";
import Paper from "@mui/material/Paper";

import CheckIcon from "@mui/icons-material/Check";

import WorkingIndicator from "../infrastructure/WorkingIndicator";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { useTranslation } from "react-i18next";
import UserListToolbar from "./UserListToolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Tooltip } from "primereact/tooltip";

interface IEmail {
  id: number;
  email: string;
  primary: boolean;
  confirmed?: boolean;
}
type Props = {
  emailList: Array<IEmail>;
  emailListUpdateFunc: (emails: Array<IEmail>) => void;
  addEmailUrl: string;
  removeEmailUrl: string;
  addMessagesFunc: (messages: Record<string, string>) => void;
  primaryEmailUrl: string;
};

export default function UserEmailList(props: Props) {
  const category = "profile";
  const { t } = useTranslation(`${category}s`);
  const [addUsersPath, setAddUsersPath] = useState("");
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newEmail, setNewEmail] = useState("");
  const dispatch = useDispatch();

  const closeDialog = () => {
    setNewEmail("");
    setAddDialogOpen(false);
  };

  const emailList =
    null != props.emailList ? (
      <>
        <Tooltip target={".primary-email"} />
        <Tooltip target={".remove-email"} />
        <DataTable
          value={props.emailList}
          resizableColumns
          tableStyle={{
            minWidth: "50rem"
          }}
          header={
            <UserListToolbar
              emailListUpdateFunc={props.emailListUpdateFunc}
              addEmailUrl={props.addEmailUrl}
              addMessagesFunc={props.addMessagesFunc}
            />
          }
          reorderableColumns
          sortField="email"
          sortOrder={-1}
          paginatorDropdownAppendTo={"self"}
          paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
          currentPageReportTemplate="{first} to {last} of {totalRecords}"
        >
          <Column
            header={t("emails.registered_col")}
            field={"email"}
            sortable
            key={"email"}
            body={params => {
              return <a href={`mailto:${params.email}`}>{params.email}</a>;
            }}
          />
          <Column
            header={t("emails.primary_col")}
            field={"primary"}
            sortable
            body={params => {
              const resp = params.primary ? (
                <>
                  <i
                    className="pi pi-star-fill primary-email"
                    data-pr-tooltip={t("emails.primary_col")}
                  />
                </>
              ) : (
                <>
                  <button
                    className="pi pi-star primary-email"
                    data-pr-tooltip={t("emails.set_primary")}
                    aria-label={t("emails.set_primary")}
                    onClick={event => {
                      dispatch(startTask("updating"));
                      const url = props.primaryEmailUrl + params.id + ".json";
                      axios
                        .get(url, {})
                        .then(response => {
                          const data = response.data;
                          props.emailListUpdateFunc(data.emails);
                          props.addMessagesFunc(data.messages);
                          dispatch(endTask("updating"));
                        })
                        .then(error => {
                          console.log("error", error);
                        });
                    }}
                  />
                </>
              );
              return resp;
            }}
          />
          <Column
            header={t("emails.confirmed_col")}
            field={"confirmed"}
            sortable
            key={"confirmed"}
            body={params => {
              const resp = params["confirmed?"] ? <CheckIcon /> : null;
              return resp;
            }}
          />
          <Column
            header={t("emails.remove_btn")}
            field={"id"}
            sortable
            key={"id"}
            body={params => {
              return (
                <button
                  className="pi pi-trash remove-email"
                  data-pr-tooltip={t("emails.remove_tltp")}
                  aria-label={t("emails.remove_tltp")}
                  onClick={event => {
                    const url = props.removeEmailUrl + params.id + ".json";
                    dispatch(startTask("removing"));
                    axios
                      .get(url, {})
                      .then(response => {
                        const data = response.data;
                        props.emailListUpdateFunc(data.emails);
                        props.addMessagesFunc(data.messages);
                        dispatch(endTask("removing"));
                      })
                      .catch(error => {
                        console.log("error", error);
                      });
                  }}
                />
              );
            }}
          />
        </DataTable>
      </>
    ) : null;

  return (
    <Paper>
      <WorkingIndicator identifier="email_actions" />
      {null != props.emailList ? (
        <React.Fragment>
          {emailList}
          <br />
        </React.Fragment>
      ) : (
        <div>{t("emails.none_yet")}</div>
      )}
    </Paper>
  );
}
