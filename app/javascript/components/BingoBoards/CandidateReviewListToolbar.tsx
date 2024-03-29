import React, { useState } from "react";

import { useTranslation } from "react-i18next";

import { Button } from "primereact/button";
import { Checkbox } from "primereact/checkbox";
import { Tooltip } from "primereact/tooltip";
import { Toolbar } from "primereact/toolbar";
import { IColumnMeta } from "../infrastructure/Types";
import { MultiSelect } from "primereact/multiselect";
import { Knob } from "primereact/knob";

type Props = {
  progress: number;
  uniqueConcepts: number;
  acceptableUniqueConcepts: number;
  dirty: boolean;
  reviewStatus: string;
  reviewComplete: boolean;
  setReviewCompleteFunc: (boolean) => void;
  saveFeedbackFunc: () => void;
  reloadFunc: () => void;
  optColumns: Array<IColumnMeta>;
  visibleColumns: Array<IColumnMeta>;
  setVisibleColumnsFunc: (Array) => void;
};

export default function CandidateReviewListToolbar(props: Props) {
  const category = "bingo_games";
  const { t } = useTranslation(category);

  const onColumnToggle = event => {
    props.setVisibleColumnsFunc(event.value);
  };

  const columnToggle = (
    <MultiSelect
      value={props.visibleColumns}
      options={props.optColumns}
      dataKey="field"
      optionLabel="header"
      placeholder={t("review.toggle_columns_plc")}
      onChange={onColumnToggle}
      className="w-full sm:w-20rem"
      display="chip"
    />
  );

  const notify =
    props.progress < 100 ? null : (
      <React.Fragment>
        <Checkbox
          id="review_complete"
          onClick={() => {
            console.log("before", props.reviewComplete);
            props.setReviewCompleteFunc(!props.reviewComplete);
          }}
          checked={props.reviewComplete}
        />
        <label htmlFor="review_complete">
          {t("review.review_complete_msg")}
        </label>
      </React.Fragment>
    );

  const saveButton = (
    <Button disabled={!props.dirty} onClick={() => props.saveFeedbackFunc()}>
      Save
    </Button>
  );

  const progress = (
    <React.Fragment>
      <Tooltip target=".progress-bar" />
      <i
        className="progress-bar"
        data-pr-tooltip={t("review.progress_key", {
          unique: props.uniqueConcepts,
          acceptable: props.acceptableUniqueConcepts
        })}
        data-pr-position="left"
      >
        <Knob
          value={props.progress}
          showValue
          size={50}
          valueTemplate="{value}%"
        />
        {props.reviewStatus}
      </i>
    </React.Fragment>
  );

  const actionsGrp = (
    <React.Fragment>
      <Button onClick={() => props.reloadFunc()}>
        {t("review.reload_btn")}
      </Button>
      {saveButton}
      {notify}
    </React.Fragment>
  );

  return <Toolbar start={columnToggle} center={progress} end={actionsGrp} />;
}
