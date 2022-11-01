import React, { useState } from "react";
import { useLocation } from "react-router-dom";

import IconButton from "@mui/material/IconButton";

// Icons
import HelpIcon from "@mui/icons-material/Help";
import Joyride, {
  ACTIONS
} from "react-joyride";

import { useTranslation } from "react-i18next";


export default function HelpMenu(props) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [t, i18n] = useTranslation();

  const location = useLocation();
  const [helpMe, setHelpMe] = useState(false);

  const endHelp = data => {
    if (
      data.action === ACTIONS.RESET ||
      data.action === ACTIONS.CLOSE ||
      data.action === ACTIONS.STOP
    ) {
      setHelpMe(false);
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
    experience: [
      {
        target: ".journal_entry",
        content: (
          <p
            dangerouslySetInnerHTML={{
              __html: t("experiences.inst_p1")
            }}
          />
        ),
        placement: "center"
      },
      {
        target: ".behaviors",
        content: (
          <p
            dangerouslySetInnerHTML={{
              __html: t("experiences.inst_p2")
            }}
          />
        ),
        placement: "center"
      },
      {
        target: "body",
        content: (
          <p
            dangerouslySetInnerHTML={{
              __html: t("experiences.inst_p3")
            }}
          />
        ),
        placement: "center"
      },
      {
        target: "body",
        content: (
          <p
            dangerouslySetInnerHTML={{
              __html: t("experiences.scenario_p1")
            }}
          />
        ),
        placement: "center"
      },
      {
        target: "body",
        content: (
          <p
            dangerouslySetInnerHTML={{
              __html: t("experiences.scenario_p2")
            }}
          />
        ),
        placement: "center"
      },
      {
        target: "body",
        content: (
          <p
            dangerouslySetInnerHTML={{
              __html: t("experiences.scenario_p3")
            }}
          />
        ),
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

  return (
    <React.Fragment>
      <Joyride
        callback={endHelp}
        continuous={true}
        scrollToFirstStep={true}
        showProgress={steps.length > 1}
        steps={steps}
        debug={false}
        showSkipButton={steps.length > 1}
        run={helpMe}
      />
      <IconButton
        id="help-menu-button"
        color="secondary"
        aria-controls="help-menu"
        aria-haspopup="true"
        onClick={event => {
          const pathComponents = location.pathname.split("/");

          switch (pathComponents[1]) {
            case "":
              setSteps(stepHash.home);
              break;
            case "experience":
              setSteps(stepHash.experience);
              break;
          }

          setHelpMe(true);
        }}
        size="large"
      >
        <HelpIcon />
      </IconButton>
    </React.Fragment>
  );
}

HelpMenu.propTypes = {};
