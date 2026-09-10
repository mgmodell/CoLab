import React, { useState } from "react";
import { useLocation } from "react-router";

// Icons
import { driver } from "driver.js";
import "driver.js/dist/driver.css";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTour } from "../infrastructure/TourContext";
import { Button } from "primereact/button";
import { Sidebar } from "primereact/sidebar";
import LangButton from "./LangButton";
import DirtyIndicator from "../infrastructure/DirtyIndicator";

type Props = {
  lookupUrl: string;
};

const NO_HELP_STEP = [
  {
    element: "body",
    popover: {
      title: "No Help Available",
      description: "There is no help available for this topic",
      align: "center" as const,
      side: "left" as const
    }
  }
];

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
      return <p>Not loaded</p>;
    } else {
      return (
        <table>
          <thead>
            <tr>
              <td>Feedback</td>
              <td>Definition</td>
              <td>Points</td>
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
    <div className="help-grid">
      <div className="help-stacked">
        <div>
          <LangButton />
        </div>
        <div>
          <DirtyIndicator />
        </div>

      </div>
      <div className="help-info">
        <Sidebar
          visible={showInfo}
          position="right"
          onHide={() => setShowInfo(false)}
        >
          {candidateFeedbackInfo()}
        </Sidebar>
        <Button
          id="help-menu-button"
          color="secondary"
          aria-controls="help-menu"
          aria-haspopup="true"
          onClick={event => {
            const steps = tourSteps.length > 0 ? tourSteps : NO_HELP_STEP;
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
      </div>
    </div>
  );
}

