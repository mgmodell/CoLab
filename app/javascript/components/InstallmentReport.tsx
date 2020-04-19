import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";

import Button from "@material-ui/core/Button";
import IconButton from "@material-ui/core/IconButton";
import Paper from "@material-ui/core/Paper";
import Skeleton from "@material-ui/lab/Skeleton";
import LinearProgress from "@material-ui/core/LinearProgress";
import ExpansionPanel from "@material-ui/core/ExpansionPanel";
import ExpansionPanelSummary from "@material-ui/core/ExpansionPanelSummary";
import ExpansionPanelDetails from "@material-ui/core/ExpansionPanelDetails";
import ExpandMoreIcon from "@material-ui/icons/ExpandMore";
import TextField from "@material-ui/core/TextField";
import Alert from "@material-ui/lab/Alert";
import Collapse from "@material-ui/core/Collapse";
import CloseIcon from "@material-ui/icons/Close";
//For debug purposes

import { useUserStore } from "./UserStore";
import i18n from "./i18n";
import { useTranslation } from "react-i18next";

import LinkedSliders from "./LinkedSliders";
export default function InstallmentReport(props) {
  const [working, setWorking] = useState(true);
  const [dirty, setDirty] = useState(false);
  const [debug, setDebug] = useState(false);
  const [t, i18n] = useTranslation("installments");

  const [messages, setMessages] = useState({});
  const [curPanel, setCurPanel] = useState(0);
  const [showAlerts, setShowAlerts] = useState(false);
  const [commentPanelOpen, setCommentPanelOpen] = useState(false);
  const [factors, setFactors] = useState({});
  const [group, setGroup] = useState({});
  const [project, setProject] = useState({});
  const [sliderSum, setSliderSum] = useState(0);

  const [contributions, setContributions] = useState({});
  const [installment, setInstallment] = useState({ comments: "" });

  const [user, userActions] = useUserStore();

  const updateSlice = (id, update) => {
    const lContributions = Object.assign({}, contributions);
    lContributions[id] = update;
    setContributions(lContributions);
  };

  const updateComments = event => {
    const inst = Object.assign({}, installment);
    inst.comments = event.target.value;
    setInstallment(inst);
  };

  useEffect(() => setDirty(true), [contributions, installment]);

  useEffect(() => getContributions(), []);

  useEffect(() => {
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  //Use this to sort team members with the user on top
  const userCompare = (a, b) => {
    var retVal = 0;
    if (user.id == a.userId) {
      retVal = +1;
    } else {
      retVal = a.name.localeCompare(b.name);
    }
    return retVal;
  };
  const setPanel = panelId => {
    //If the panel is already selected...
    if (panelId == curPanel) {
      //...close it.
      setCurPanel(null);
      //Otherwise...
    } else {
      //...open it
      setCurPanel(panelId);
    }
  };

  const progBar = working ? <LinearProgress /> : null;
  const saveButton = (
    <Button variant="contained" onClick={() => saveContributions()}>
      <Suspense fallback={<Skeleton variant="text" />}>{t("submit")}</Suspense>
    </Button>
  );

  //Retrieve the latest data
  const getContributions = () => {
    fetch(props.getInstallmentUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          setMessages({});
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        setFactors(data.factors);
        setSliderSum(data.sliderSum);

        //Process Contributions
        const contributions = data.installment.values.reduce(
          (valuesAccum, value) => {
            const values = valuesAccum[value.factor_id] || [];
            values.push({
              userId: value.user_id,
              factorId: value.factor_id,
              name: data.group.users[value.user_id].name,
              value: value.value
            });
            valuesAccum[value.factor_id] = values.sort(userCompare);
            return valuesAccum;
          },
          {}
        );
        delete data.installment.values;
        setInstallment(data.installment);
        setContributions(contributions);
        setDirty(false);
        setGroup(data.group);
        data.installment.group_id = data.group.id;
        setProject(data.installment.project);
        setWorking(false);
      });
  };
  //Store what we've got
  const saveContributions = () => {
    const url =
      props.setInstallmentUrl +
      (Boolean(installment["id"]) ? "/" + installment["id"] : "") +
      ".json";
    const method = Boolean(installment["id"]) ? "PATCH" : "POST";
    fetch(url, {
      method: method,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        contributions: contributions,
        installment: installment
      })
    })
      .then(response => {
        if (response.ok) {
          setMessages({});
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        //Process Contributions
        if (!data.error) {
          setInstallment(data.installment);
          const receivedContributions = data.installment.values.reduce(
            (valuesAccum, value) => {
              const values = valuesAccum[value.factor_id] || [];
              values.push({
                userId: value.user_id,
                factorId: value.factor_id,
                name: group["users"][value.user_id].name,
                value: value.value
              });
              valuesAccum[value.factor_id] = values.sort(userCompare);
              return valuesAccum;
            },
            {}
          );
          setContributions(receivedContributions);
        }
        console.log(data.messages);
        setMessages(data.messages);
        setShowAlerts(true);
        setWorking(false);
        setDirty(false);
      });
  };

  return (
    <Paper>
      {progBar}
      <Collapse in={showAlerts}>
        <Alert
          action={
            <IconButton
              aria-label="close"
              color="inherit"
              size="small"
              onClick={() => {
                setShowAlerts(false);
              }}
            >
              <CloseIcon fontSize="inherit" />
            </IconButton>
          }
        >
          {messages["status"]}
        </Alert>
      </Collapse>
      <p>
        <Suspense fallback={<Skeleton variant="text" height={15} />}>
          {t("slider.instructions")}
        </Suspense>
      </p>
      <Suspense fallback={<Skeleton variant="rect" height={300} />}>
        {Object.keys(contributions).map(sliceId => {
          return (
            <ExpansionPanel
              expanded={sliceId == String(curPanel)}
              onChange={() => setPanel(sliceId)}
              key={sliceId}
            >
              <ExpansionPanelSummary
                expandIcon={<ExpandMoreIcon />}
                id={sliceId}
              >
                {factors[sliceId].name}
              </ExpansionPanelSummary>
              <ExpansionPanelDetails>
                <LinkedSliders
                  key={"f_" + sliceId}
                  id={Number(sliceId)}
                  sum={6000}
                  updateContributions={updateSlice.bind(null, sliceId)}
                  description={factors[sliceId].description}
                  contributions={contributions[sliceId]}
                  debug={debug}
                />
              </ExpansionPanelDetails>
            </ExpansionPanel>
          );
        })}
        <br />
        <br />
        <ExpansionPanel
          expanded={commentPanelOpen}
          onChange={() => setCommentPanelOpen(!commentPanelOpen)}
        >
          <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />} id={"comment"}>
            {t("comment_prompt")}
          </ExpansionPanelSummary>
          <ExpansionPanelDetails>
            <TextField
              value={installment.comments}
              name="Comments"
              id="Comments"
              placeholder={"Enter your comments"}
              helperText={messages["comments"]}
              multiline={true}
              fullWidth={true}
              onChange={updateComments}
            />
          </ExpansionPanelDetails>
        </ExpansionPanel>
      </Suspense>
      {saveButton}
      <div
        id="installment_debug_div"
        style={{
          height: "10px",
          margin: "auto",
          width: "10px",
          opacity: 0,
          border: "0px"
        }}
      >
        <input
          type="checkbox"
          value={String(debug)}
          id="debug"
          onChange={() => setDebug(!debug)}
        />
      </div>
    </Paper>
  );
}

InstallmentReport.propTypes = {
  token: PropTypes.string.isRequired,
  installmentId: PropTypes.number,
  getInstallmentUrl: PropTypes.string.isRequired,
  setInstallmentUrl: PropTypes.string.isRequired
};
