import React, { Suspense } from "react";
import PropTypes from "prop-types";

import Button from "@mui/material/Button";
import Paper from "@mui/material/Paper";
import Skeleton from "@mui/material/Skeleton";
//For debug purposes

import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";
import parse from "html-react-parser";

export default function Experience(props) {
  const [t, i18n] = useTranslation("experiences");

  const behaviors = useTypedSelector(state => state.context.lookups.behaviors);

  const saveButton = (
    <Button variant="contained" onClick={() => props.acknowledgeFunc()}>
      {t("instructions.next")}
    </Button>
  );

  return (
    <Paper>
      <Suspense fallback={<Skeleton variant="text" />}>
        <h3>{t("instructions.title")}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p>{parse(t("inst_p1"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p>{parse(t("inst_p2"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p>{parse(t("inst_p3"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton variant="text" />}>
        <h3>{t("instructions.behaviors_lbl")}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <dl>
          {(behaviors || []).map(behavior => {
            return (
              <React.Fragment key={behavior.id}>
                <dt>{behavior.name}</dt>
                <dd>{parse(behavior.description)}</dd>
              </React.Fragment>
            );
          })}
        </dl>
      </Suspense>
      <Suspense fallback={<Skeleton variant="text" />}>
        <h3>{t("scenario_lbl")}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p>{parse(t("scenario_p1"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p>{parse(t("scenario_p2"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p>{parse(t("scenario_p3"))}</p>
      </Suspense>
      {saveButton}
    </Paper>
  );
}

Experience.propTypes = {
  acknowledgeFunc: PropTypes.func.isRequired
};
