import React, { useState } from "react";
import { useLocation } from "react-router";

// Icons
import {driver } from "driver.js";
import "driver.js/dist/driver.css";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTour } from "../infrastructure/TourContext";
import { Button } from "primereact/button";
import { Sidebar } from "primereact/sidebar";
import LangButton from "./LangButton";

type Props = {
  lookupUrl: string;
};

export default function HelpMenu(props: Props) {
  const [t, i18n] = useTranslation();

  const location = useLocation();
  const [showInfo, setShowInfo] = useState(false);
  const { tourSteps } = useTour();

  const driverObj = driver({
    showProgress: true
  });

  const feedbackOpts = useTypedSelector(
    state => state.context.lookups["candidate_feedbacks"]
  );
  const candidateFeedbackInfo = () => {
    if (undefined === feedbackOpts || null === feedbackOpts) {
      return <p>{t("help_not_loaded")}</p>;
    } else {
      return (
        <table>
          <thead>
            <tr>
              <td>{t("help_feedback_col")}</td>
              <td>{t("help_definition_col")}</td>
              <td>{t("help_points_col")}</td>
            </tr>
          </thead>
          <tbody>
            {feedbackOpts.map(feedbackOpt => {
              return (
                <tr key={feedbackOpt.id}>
                  <td>
                    <strong>{feedbackOpt.name}</strong>
                  </td>
                  <td>{feedbackOpt.definition}</td>
                  <td>.{feedbackOpt.credit}%</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      );
    }
  };

  const pathComponents = location.pathname.split("/");
  return (
    <React.Fragment>
      <Sidebar
        visible={showInfo}
        position="right"
        onHide={() => setShowInfo(false)}
      >
        {candidateFeedbackInfo()}
      </Sidebar>
      <LangButton />
      <Button
        id="help-menu-button"
        color="secondary"
        aria-controls="help-menu"
        aria-haspopup="true"
        onClick={event => {
          const noHelpStep = [
            {
              element: "body",
              popover: {
                title: t("no_help_title"),
                description: t("no_help_description"),
                align: "center" as const,
                side: "left" as const
              }
            }
          ];
          const steps = tourSteps.length > 0 ? tourSteps : noHelpStep;
          driverObj.setSteps(steps);
          driverObj.drive();
        }}
        size="small"
        rounded
        text
        outlined
        icon="pi pi-question"
      />
      {pathComponents.includes("bingo") ? (
        <Button
          icon="pi pi-info"
          size="small"
          rounded
          text
          outlined
          onClick={event => {
            setShowInfo(!showInfo);
          }}
        />
      ) : null}
    </React.Fragment>
  );
}

