import React, { Suspense, useState } from "react";
import PropTypes from "prop-types";

import { useDispatch } from "react-redux";
import { setDirty } from "../infrastructure/StatusSlice";

import Button from "@mui/material/Button";
import Paper from "@mui/material/Paper";
import TextField from "@mui/material/TextField";
//For debug purposes

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";

import Radio from "@mui/material/Radio";
import Grid from "@mui/material/Grid";
import FormControlLabel from "@mui/material/FormControlLabel";
import RadioGroup from "@mui/material/RadioGroup";
import FormLabel from "@mui/material/FormLabel";
import parse from "html-react-parser";
import { Accordion, AccordionTab } from "primereact/accordion";
import { Skeleton } from "primereact/skeleton";

type Props = {
  diagnoseFunc: (
    behaviorId: number,
    otherName: string,
    comments: string,
    resetData: () => void
  ) => void;
  weekNum: number;
  weekText: string;
};

export default function ExperienceDiagnosis(props : Props) {
  const [t, i18n] = useTranslation("experiences");
  const [behaviorId, setBehaviorId] = useState(0);
  const [otherName, setOtherName] = useState("");
  const [comments, setComments] = useState("");
  const [showComments, setShowComments] = useState(false);

  const dirtyStatus = useTypedSelector(
    state => state.status.dirtyStatus["diagnosis"]
  );
  const dispatch = useDispatch();

  const getById = (list, id) => {
    return list.filter(item => {
      return id === item.id;
    })[0];
  };

  const behaviors = useTypedSelector(state => state.context.lookups.behaviors);

  const detailNeeded =
    0 === behaviorId ? true : getById(behaviors, behaviorId).needs_detail;
  const detailPresent = otherName.length > 0;
  const saveButton = (
    <Button
      disabled={
        !dirtyStatus || 0 === behaviorId || (detailNeeded && !detailPresent)
      }
      variant="contained"
      onClick={() =>
        props.diagnoseFunc(behaviorId, otherName, comments, resetData)
      }
    >
      <Suspense fallback={<Skeleton className="mb-2" />}>
        {t("next.save_and_continue")}
      </Suspense>
    </Button>
  );

  const otherPnl =
    0 !== behaviorId && detailNeeded ? (
      <TextField
        variant="filled"
        label={t("next.other")}
        id="other_name"
        value={otherName}
        onChange={event => {
          setOtherName(event.target.value);
        }}
      />
    ) : null;

  const resetData = () => {
    setBehaviorId(0);
    setOtherName("");
    setComments("");
  };

  return (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton className="mb-2" />}>
            <h3 className="journal_entry">
              {t("next.journal", { week_num: props.weekNum })}
            </h3>
          </Suspense>
        </Grid>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton className="mb-2" />}>
            <p>{parse(props.weekText)}</p>
          </Suspense>
        </Grid>
        <Grid item xs={12}>
          <FormLabel>{t("next.prompt")}</FormLabel>
          {behaviors !== undefined ? (
            <RadioGroup
              className="behaviors"
              aria-label="behavior"
              value={behaviorId}
              onChange={event => {
                dispatch(setDirty("diagnosis"));
                setBehaviorId(Number(event.target.value));
              }}
            >
              {behaviors.map(behavior => {
                return (
                  <React.Fragment key={"behavior_" + behavior.id}>
                    <FormControlLabel
                      value={behavior.id}
                      label={behavior.name}
                      control={<Radio />}
                    />
                    <p>{parse(behavior.description)}</p>
                  </React.Fragment>
                );
              })}
            </RadioGroup>
          ) : (
            <Skeleton className="mb-2" />
          )}
        </Grid>
        <Grid item xs={12}>
          {otherPnl}
        </Grid>
        <Grid item xs={12}>
          <Accordion >
            <AccordionTab header={t("next.click_for_comment")}>
              <TextField
                variant="filled"
                label={t("next.comments")}
                value={comments}
                id="comments"
                onChange={event => {
                  setComments(event.target.value);
                }}
              />
            </AccordionTab>
          </Accordion>
        </Grid>
      </Grid>
      {saveButton}
    </Paper>
  );
}

