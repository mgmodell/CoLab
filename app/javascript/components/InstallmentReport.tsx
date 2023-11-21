import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";
import { useNavigate, useParams } from "react-router-dom";

import Button from "@mui/material/Button";
import IconButton from "@mui/material/IconButton";
import Paper from "@mui/material/Paper";
import Skeleton from "@mui/material/Skeleton";
import Accordion from "@mui/material/Accordion";
import AccordionSummary from "@mui/material/AccordionSummary";
import AccordionDetails from "@mui/material/AccordionDetails";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import TextField from "@mui/material/TextField";
import Alert from "@mui/material/Alert";
import Collapse from "@mui/material/Collapse";
import CloseIcon from "@mui/icons-material/Close";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "./infrastructure/AppReducers";

// import LinkedSliders from './LinkedSliders';
import LinkedSliders from "linked-sliders/dist/LinkedSliders";
import axios from "axios";
import parse from "html-react-parser";

interface Props {
  rootPath?: string;
};

export default function InstallmentReport(props : Props) {
  const endpointSet = "installment";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const navigate = useNavigate();

  const { installmentId } = useParams();

  const dispatch = useDispatch();
  const [dirty, setDirty] = useState(false);
  const [debug, setDebug] = useState(false);
  const [t, i18n] = useTranslation("installments");

  const [initialised, setInitialised] = useState(false);
  // I need to fix this to use the standard
  const [messages, setMessages] = useState({});
  const [curPanel, setCurPanel] = useState(0);
  const [showAlerts, setShowAlerts] = useState(false);
  const [commentPanelOpen, setCommentPanelOpen] = useState(false);
  const [group, setGroup] = useState({});
  const [factors, setFactors] = useState({});

  const [project, setProject] = useState({});
  const [sliderSum, setSliderSum] = useState(0);

  const [contributions, setContributions] = useState({});
  const [installment, setInstallment] = useState({ comments: "" });

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

  useEffect(() => {
    if (endpointStatus) {
      getContributions();
    }
  }, [endpointStatus]);

  //Use this to sort team members with the user on top
  const userCompare = (b, a) => {
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

  const saveButton = (
    <Button variant="contained" onClick={() => saveContributions()}>
      <Suspense fallback={<Skeleton variant="text" />}>{t("submit")}</Suspense>
    </Button>
  );

  //Retrieve the latest data
  const getContributions = () => {
    const url =
      props.rootPath === undefined
        ? `${endpoints.baseUrl}${installmentId}.json`
        : `/${props.rootPath}${endpoints.baseUrl}${installmentId}.json`;

    dispatch(startTask());
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const factorsData = Object.assign({}, data.factors);
        setFactors(factorsData);

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
        setInitialised(true);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  //Store what we've got
  const saveContributions = () => {
    dispatch(startTask("saving"));
    const url = ( props.rootPath === undefined ? '' : `/${props.rootPath}` ) +
      endpoints.saveInstallmentUrl +
      (Boolean(installment.id) ? `/${installment.id}` : ``) +
      ".json";
    const method = Boolean(installment.id) ? "PATCH" : "POST";

    const body = {
      contributions: contributions,
      installment: installment
    };
    axios({
      url: url,
      method: method,
      data: body
    })
      .then(response => {
        const data = response.data;
        //Process Contributions
        if (!data.error) {
          setInstallment(data.installment);
          const receivedContributions = data.installment.values.reduce(
            (valuesAccum, value) => {
              const values = valuesAccum[value.factor_id] || [];
              values.push({
                userId: value.user_id,
                factorId: value.factor_id,
                name: group["users"][value.user_id].name || "",
                value: value.value
              });
              valuesAccum[value.factor_id] = values.sort(userCompare);
              return valuesAccum;
            },
            {}
          );
          setContributions(receivedContributions);
          navigate(`..`);
        }
        setMessages(data.messages);
        setShowAlerts(true);
        dispatch(endTask("saving"));
        setDirty(false);
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  return (
    <Paper>
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
      <Suspense fallback={<Skeleton variant="text" height={15} />}>
        <h1>{t("subtitle")}</h1>
        <p>
          {parse(
            t("instructions", {
              group_name: group['name'],
              project_name: project['name'],
              member_count: Object.keys(group['users'] || {}).length,
              factor_count: Object.keys(factors || {}).length
            })
          )}
        </p>
        <p>{t("slider.instructions")}</p>
      </Suspense>
      <Suspense fallback={<Skeleton variant="rectangular" height={300} />}>
        {Object.keys(contributions).map(sliceId => {
          return (
            <Accordion
              expanded={sliceId == String(curPanel)}
              onChange={() => setPanel(sliceId)}
              key={sliceId}
            >
              <AccordionSummary expandIcon={<ExpandMoreIcon />} id={sliceId}>
                {factors[sliceId].name}
              </AccordionSummary>
              <AccordionDetails>
                <LinkedSliders
                  key={"f_" + sliceId}
                  id={Number(sliceId)}
                  sum={6000}
                  updateContributions={updateSlice.bind(null, sliceId)}
                  description={factors[sliceId].description}
                  contributions={contributions[sliceId]}
                  debug={debug}
                />
              </AccordionDetails>
            </Accordion>
          );
        })}
        <br />
        <br />
        <Accordion
          expanded={commentPanelOpen}
          onChange={() => setCommentPanelOpen(!commentPanelOpen)}
        >
          <AccordionSummary expandIcon={<ExpandMoreIcon />} id={"comment"}>
            {t("comment_prompt")}
          </AccordionSummary>
          <AccordionDetails>
            <TextField
              value={installment.comments || ""}
              name="Comments"
              id="Comments"
              placeholder={"Enter your comments"}
              helperText={messages["comments"]}
              multiline={true}
              fullWidth={true}
              onChange={updateComments}
            />
          </AccordionDetails>
        </Accordion>
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

