import React from "react";

import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import { InputText } from "primereact/inputtext";
import { Button } from "primereact/button";
import { PrimeIcons } from "primereact/api";

type Props = {
  itemType: string;
  filterValue: string;
  setFilterFunc: (string) => void
};

export default function AdminListToolbar(props: Props) {
  const { t } = useTranslation(`admin`);
  const navigate = useNavigate();
  return (
    <div className="flex flex-wrap align-items-center justify-content-between gap-2">
            <span className="text-xl text-900 font-bold">{props.itemType}s</span>
            <Button
              tooltip={t('new_activity', {activity_type: props.itemType})}
              id={`new_${props.itemType}`}
              onClick={event => {
                navigate("new");
              }}
              aria-label={`New ${props.itemType}`}
              icon={ PrimeIcons.PLUS} rounded raised >
                {t("new_activity", { activity_type: props.itemType })}

              </Button>
              <div className="flex justify-content-end">
                <span className="p-input-icon-left">
                    <i className="pi pi-search" />
                    <InputText
                      id={`${props.itemType}-search`}
                      value={props.filterValue}
                      onChange={(event) =>{
                        props.setFilterFunc( event.target.value );
                      }}
                      placeholder="Search" />
                </span>
            </div>
        </div>
  );
}
