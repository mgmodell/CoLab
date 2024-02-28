import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";

import { Button } from "primereact/button";
import { Dialog } from "primereact/dialog";


type Props = {
  isOpen: boolean;
  closeFunc: Function;
};

export default function ConfirmDialog(props : Props) {
  const category = "graphing";
  const { t, i18n } = useTranslation(category);

  return (
    <Dialog 
      header={t("anon_confirm_title")} 
      visible={props.isOpen} 
      modal={true} 
      onHide={() => props.closeFunc(false)}
      footer={
        <div>
        <Button onClick={() => props.closeFunc(false)}>Disagree</Button>
        <Button onClick={() => props.closeFunc(true)} autoFocus>
          Agree
        </Button>
        </div>
      }
      >
      <p>
        {t("anon_confirm")}
      </p>
    </Dialog>
  );
}

