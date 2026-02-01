import React, { useEffect, useState } from "react";
import { useLocation } from "react-router";
import parse from "html-react-parser";

// Icons
import {driver } from "driver.js";
import "driver.js/dist/driver.css";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
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

  const stepHash = {
    home: [
      {
        element: "body",
        popover: {
          title: "Welcome to the Application!",
          description: "This stuff is awesome. More information soon!",
          align: "center",
          side: "left"
        }
      }
    ],
    bingo: [
      {
        element: "body",
        popover: {
          title: "No Help Available",
          description: "There is no help available for this topic",
          align: "center",
          side: "left"
        }
      }
    ],
    experience: [
      {
        element: ".journal_entry",
        popover: {
          description: parse(t("experiences.inst_p1")),
          align: "center",
          side: "left"
        }
      },
      {
        element: ".behaviors",
        popover: {
          description: parse(t("experiences.inst_p4")),
          align: "center",
          side: "right"
        }
      },
      {
        target: "body",
        popover: {
          description: parse(t("experiences.inst_p3")),
          align: "center",
          side: "top"
        }
      },
    ],
    default: [
      {
        element: "body",
        popover: {
          title: "No Help Available",
          description: "There is no help available for this topic",
          align: "center",
          side: "left"
        }
      }
    ]
  };
  //const [steps, setSteps] = useState(stepHash.default);

  const pathComponents = location.pathname.split("/");
  const pathLoc =
    "demo" === pathComponents[1] ? pathComponents[2] : pathComponents[1];
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
          console.log("Help requested for ", pathLoc);
          switch (pathLoc) {
            case "":
              driverObj.setSteps(stepHash.home);
              driverObj.drive();
              break;
            case "bingo":
              driverObj.setSteps(stepHash.bingo);
              driverObj.drive();
              break;
            case "experience":
              driverObj.setSteps(stepHash.experience);
              driverObj.drive();
              break;
            default:
              driverObj.setSteps(stepHash.default);
              driverObj.drive();
          }

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
