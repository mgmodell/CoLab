import React from "react";

import { useTranslation } from "react-i18next";

import { Toolbar } from "primereact/toolbar";
import { Button } from "primereact/button";

type Props = {
  itemType: string;
  newItemFunc: () => void;
};

export default function RubricCriteriaToolbar(props: Props) {
  const category = "rubric";
  const { t } = useTranslation(`${category}s`);

  const title = (
    <h3>{props.itemType.charAt(0).toUpperCase() + props.itemType.slice(1)}</h3>
  );

  return (
    <Toolbar
      start={title}
      end={
        <Button
          label={t("new.criteria")}
          icon="pi pi-plus"
          onClick={() => {
            props.newItemFunc();
          }}
        />
      }
    />
  );
}
