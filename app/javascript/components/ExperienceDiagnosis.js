import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";

import { useSelector, useDispatch } from "react-redux";
import { setDirty, setClean } from "./infrastructure/StatusActions";

import Button from "@mui/material/Button";
import IconButton from "@mui/material/IconButton";
import Paper from "@mui/material/Paper";
import Skeleton from "@mui/material/Skeleton";
import FormControl from "@mui/material/FormControlLabel";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";
import InputLabel from "@mui/material/InputLabel";
import Accordion from "@mui/material/Accordion";
import AccordionSummary from "@mui/material/AccordionSummary";
import AccordionDetails from "@mui/material/AccordionDetails";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import TextField from "@mui/material/TextField";
import Alert from "@mui/material/Alert";
import Collapse from "@mui/material/Collapse";
import CloseIcon from "@mui/icons-material/Close";
//For debug purposes

import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "./infrastructure/AppReducers";

import Radio from "@mui/material/Radio";
import Grid from "@mui/material/Grid";
import FormControlLabel from "@mui/material/FormControlLabel";
import RadioGroup from "@mui/material/RadioGroup";
import FormLabel from "@mui/material/FormLabel";

export default function ExperienceDiagnosis(props) {
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
      <Suspense fallback={<Skeleton variant="text" />}>
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
    setShowComments(false);
  };

  return (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant="text" />}>
            <h3 className="journal_entry">
              {t("next.journal", { week_num: props.weekNum })}
            </h3>
          </Suspense>
        </Grid>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant="rectangular" />}>
            <p
              dangerouslySetInnerHTML={{
                __html: props.weekText
              }}
            />
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
                    <p
                      dangerouslySetInnerHTML={{
                        __html: behavior.description
                      }}
                    />
                  </React.Fragment>
                );
              })}
            </RadioGroup>
          ) : (
            <Skeleton variant="rectangular" />
          )}
        </Grid>
        <Grid item xs={12}>
          {otherPnl}
        </Grid>
        <Grid item xs={12}>
          <Accordion
            expanded={showComments}
            onChange={() => setShowComments(!showComments)}
          >
            <AccordionSummary id="comments_pnl">
              {t("next.click_for_comment")}
            </AccordionSummary>
            <AccordionDetails>
              <TextField
                variant="filled"
                label={t("next.comments")}
                value={comments}
                id="comments"
                onChange={event => {
                  setComments(event.target.value);
                }}
              />
            </AccordionDetails>
          </Accordion>
        </Grid>
      </Grid>
      {saveButton}
    </Paper>
  );
}

ExperienceDiagnosis.propTypes = {
  diagnoseFunc: PropTypes.func.isRequired,
  weekNum: PropTypes.number.isRequired,
  weekText: PropTypes.string.isRequired
};
