import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";

import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import parse from "html-react-parser";

import { Button } from "primereact/button";
import { Panel } from "primereact/panel";
import { Checkbox } from "primereact/checkbox";
import { Container, Row, Col } from "react-grid-system";

interface Props {
  consentFormId?: number;
  parentUpdateFunc?: () => void;
}

export default function ConsentLog(props: Props) {
  const { t } = useTranslation("consent_logs");
  const endpointSet = "consent_log";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { consentFormId } = useParams();

  const dispatch = useDispatch();
  const [logId, setLogId] = useState();
  const [formName, setFormName] = useState("");
  const [formText, setFormText] = useState("");
  const [, setFormPresented] = useState(false);
  const [formPdfLink, setFormPdfLink] = useState("");
  const [formAccepted, setFormAccepted] = useState(false);
  const [logLastUpdated, setLogLastUpdated] = useState(new Date());

  const getLog = () => {
    var url =
      endpoints["baseUrl"] + (consentFormId || props.consentFormId) + ".json";

    dispatch(startTask("loading"));
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //Process the data
        setLogId(data.consent_log.id);
        setFormName(data.consent_log.name);
        setFormText(data.consent_log.formText);
        setFormPdfLink(data.consent_log.pdfLink);
        setFormAccepted(data.consent_log.accepted || false);
        setFormPresented(data.consent_log.presented);
        setLogLastUpdated(new Date(data.consent_log.updatedAt));

        dispatch(endTask("loading"));
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  const updateLog = () => {
    var url = endpoints["consentLogSaveUrl"] + logId + ".json";
    dispatch(startTask("saving"));

    axios
      .patch(url, {
        consent_log: {
          accepted: formAccepted
        }
      })
      .then(response => {
        const data = response.data;
        //Process the data
        setFormAccepted(data.accepted);
        if (null != props.parentUpdateFunc) {
          props.parentUpdateFunc();
        } else {
          history.back();
        }

        dispatch(endTask("saving"));
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getLog();
    }
  }, [endpointStatus]);

  return (
    <Panel>
      <Container>
        <Row>
        <Col xs={12}>
          <h1>{t("edit.opening")}</h1>
          <h2>
            {t("edit.title")}: {formName}
          </h2>
        </Col>
        <Col xs={12}>
          <p>{t("edit.instructions")}</p>
          <p>
            {// Good candidate for dataloading API
              parse(formText || "")}
          </p>
        </Col>
        <Col xs={12} sm={6}>
          <a href={formPdfLink}>{t("edit.consent_dl")}</a>
        </Col>
        <Col xs={12} sm={6}>
          <div className="flex align-items-center">
            <Checkbox
              id="accepted"
              checked={formAccepted}
              onChange={() => setFormAccepted(!formAccepted)}
            />
            <label htmlFor="accepted">{t("edit.accept")}</label>
          </div>
        </Col>
        <Col xs={12}>
          <Button onClick={updateLog}>
            {t("edit.submit_response")}
          </Button>
        </Col>
        </Row>
      </Container>
    </Panel>
  );
}
