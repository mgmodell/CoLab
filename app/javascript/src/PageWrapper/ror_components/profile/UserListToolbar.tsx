import React, { useState } from "react";

import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import axios from "axios";

import { Toolbar } from "primereact/toolbar";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import { Dialog } from "primereact/dialog";
import { InputText } from "primereact/inputtext";
import { Button } from "primereact/button";

type Props = {
  emailListUpdateFunc: (email: string) => void;
  addEmailUrl: string;
  addMessagesFunc: (messages: Record<string, string>) => void;
};

export default function UserListToolbar(props) {
  const category = "profile";
  const { t } = useTranslation(`${category}s`);
  const dispatch = useDispatch();

  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newEmail, setNewEmail] = useState("");

  const closeDialog = () => {
    setNewEmail("");
    setAddDialogOpen(false);
  };

  return (
    <Toolbar
      end={
        <React.Fragment>
          <Button
            label={t("emails.add_btn")}
            icon="pi pi-plus"
            onClick={() => setAddDialogOpen(true)}
            className="p-button-success p-mr-2"
          />
          <Dialog
            header={t("emails.add_dlg_title")}
            visible={addDialogOpen}
            closable
            modal
            onHide={() => closeDialog()}
            footer={
              <>
                <Button
                  label={t("cancel")}
                  icon="pi pi-times"
                  onClick={() => closeDialog()}
                  className="p-button-text"
                />
                <Button
                  label={t("emails.add_btn")}
                  icon="pi pi-check"
                  onClick={() => {
                    dispatch(startTask("updating"));
                    axios
                      .put(props.addEmailUrl + ".json", {
                        email_address: newEmail
                      })
                      .then(response => {
                        const data = response.data;
                        props.emailListUpdateFunc(data.emails);
                        props.addMessagesFunc(data.messages);
                      })
                      .catch(error => {
                        console.log("error", error);
                      })
                      .finally(() => {
                        dispatch(endTask("updating"));
                        closeDialog();
                      });
                  }}
                  autoFocus
                />
              </>
            }
          >
            <p>{t("emails.add_dlg")}</p>
            <label htmlFor="address">{t("emails.email_lbl")}</label>
            <InputText
              autoFocus
              id="address"
              type="email"
              value={newEmail}
              onChange={event => setNewEmail(event.target.value)}
            />
            <br />
          </Dialog>
        </React.Fragment>
      }
    />
  );
}
