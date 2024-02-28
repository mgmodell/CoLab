import React, { useState } from "react";
import { useLocation } from "react-router-dom";
import parse from "html-react-parser";

// Icons
import Joyride, { ACTIONS } from "react-joyride";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { Button } from "primereact/button";
import { Sidebar } from "primereact/sidebar";
import LangButton from "./LangButton";

type Props = {
  lookupUrl: string;
};

export default function HelpMenu(props: Props) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [t, i18n] = useTranslation();

  const location = useLocation();
  const [helpMe, setHelpMe] = useState(false);
  const [showInfo, setShowInfo] = useState(false);

  const endHelp = data => {
    if (
      data.action === ACTIONS.RESET ||
      data.action === ACTIONS.CLOSE ||
      data.action === ACTIONS.STOP
    ) {
      setHelpMe(false);
    }
  };

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
        target: "body",
        content: "This stuff is awesome",
        placement: "center"
      }
    ],
    bingo: [
      {
        target: "body",
        content: "There is no help available for this topic",
        placement: "center"
      }
    ],
    experience: [
      {
        target: ".journal_entry",
        content: <p>{parse(t("experiences.inst_p1"))}</p>,
        placement: "center"
      },
      {
        target: ".behaviors",
        content: <p>{parse(t("experiences.inst_p2"))}</p>,
        placement: "center"
      },
      {
        target: "body",
        content: <p>{parse(t("experiences.inst_p3"))}</p>,
        placement: "center"
      },
      {
        target: "body",
        content: <p>{parse(t("experiences.scenario_p1"))}</p>,
        placement: "center"
      },
      {
        target: "body",
        content: <p>{parse(t("experiences.scenario_p2"))}</p>,
        placement: "center"
      },
      {
        target: "body",
        content: <p>{parse(t("experiences.scenario_p3"))}</p>,
        placement: "center"
      }
    ],
    default: [
      {
        target: "body",
        content: "There is no help available for this topic",
        placement: "center"
      }
    ]
  };
  const [steps, setSteps] = useState(stepHash.default);

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
      <Joyride
        callback={endHelp}
        continuous={true}
        scrollToFirstStep={true}
        showProgress={steps.length > 1}
        steps={steps}
        debug={false}
        showSkipButton={steps.length > 1}
        run={helpMe}
        styles={{
          options: {
            width: "100%"
          }
        }}
      />
      <LangButton />
      <Button
        id="help-menu-button"
        color="secondary"
        aria-controls="help-menu"
        aria-haspopup="true"
        onClick={event => {
          switch (pathLoc) {
            case "":
              setSteps(stepHash.home);
              break;
            case "bingo":
              setSteps(stepHash.bingo);
              break;
            case "experience":
              setSteps(stepHash.experience);
              break;
          }

          setHelpMe(true);
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
