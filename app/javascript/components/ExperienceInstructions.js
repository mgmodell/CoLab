import React, { Suspense } from "react";
import PropTypes from "prop-types";

import Button from "@mui/material/Button";
import Paper from "@mui/material/Paper";
import Skeleton from "@mui/material/Skeleton";
//For debug purposes

import { useTypedSelector } from "./infrastructure/AppReducers";
import { useTranslation } from "react-i18next";


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
        <p
          dangerouslySetInnerHTML={{
            __html: t("inst_p1")
          }}
        />
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p
          dangerouslySetInnerHTML={{
            __html: t("inst_p2")
          }}
        />
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p
          dangerouslySetInnerHTML={{
            __html: t("inst_p3")
          }}
        />
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
                <dd
                  dangerouslySetInnerHTML={{
                    __html: behavior.description
                  }}
                />
              </React.Fragment>
            );
          })}
        </dl>
      </Suspense>
      <Suspense fallback={<Skeleton variant="text" />}>
        <h3>{t("scenario_lbl")}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p
          dangerouslySetInnerHTML={{
            __html: t("scenario_p1")
          }}
        />
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p
          dangerouslySetInnerHTML={{
            __html: t("scenario_p2")
          }}
        />
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" />}>
        <p
          dangerouslySetInnerHTML={{
            __html: t("scenario_p3")
          }}
        />
      </Suspense>
      {saveButton}
    </Paper>
  );
}

Experience.propTypes = {
  acknowledgeFunc: PropTypes.func.isRequired
};
