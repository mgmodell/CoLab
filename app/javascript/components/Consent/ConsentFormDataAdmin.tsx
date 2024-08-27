import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";

import { Panel } from "primereact/panel";
import { Button } from "primereact/button";

import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { Editor } from "primereact/editor";
import { TabView, TabPanel } from "primereact/tabview";
import EditorToolbar from "../toolbars/EditorToolbar";
import { Calendar } from "primereact/calendar";
import { InputSwitch } from "primereact/inputswitch";
import { InputText } from "primereact/inputtext";
import { Col, Container, Row } from "react-grid-system";

enum ConsentFormTabs {
  English = 1,
  Korean = 2
}

export default function ConsentFormDataAdmin(props) {
  const category = "consent_form";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t } = useTranslation(`${category}s`);
  const { consentFormIDParam } = useParams();

  const dispatch = useDispatch();
  const [dirty, setDirty] = useState(false);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [consentFormId, setConsentFormId] = useState(consentFormIDParam);
  const [consentFormName, setConsentFormName] = useState("");
  const [consentFormActive, setConsentFormActive] = useState(false);
  const now = new Date();
  const [consentFormStartDate, setConsentFormStartDate] = useState(now);
  const [consentFormEndDate, setConsentFormEndDate] = useState(() => {
    now.setFullYear(now.getFullYear() + 1);
    return now;
  });
  const [consentFormFormTextEn, setConsentFormFormTextEn] = useState("");
  const [consentFormFormTextKo, setConsentFormFormTextKo] = useState("");
  const [consentFormDoc, setConsentFormDoc] = useState(null);

  const consentFormDataId = "consent_form";

  const handleFileSelect = evt => {
    const file = evt.target.files[0];

    if (file) {
      setConsentFormDoc(file);
    }
  };

  const getConsentForm = () => {
    dispatch(startTask());
    setDirty(true);
    var url = endpoints.baseUrl + "/";
    if (null == consentFormId) {
      url = url + "new.json";
    } else {
      url = url + consentFormId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const consentForm = data.consent_form;

        setConsentFormName(consentForm.name || "");
        setConsentFormActive(consentForm.active || false);

        var receivedDate = new Date(Date.parse(consentForm.start_date));
        setConsentFormStartDate(receivedDate);

        receivedDate = new Date(Date.parse(consentForm.end_date));
        setConsentFormEndDate(receivedDate);

        setConsentFormFormTextEn(consentForm.form_text_en || "");
        setConsentFormFormTextKo(consentForm.form_text_ko || "");

        dispatch(endTask());
        setDirty(false);
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  const saveConsentForm = () => {
    const method = null == consentFormId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null == consentFormId ? null : consentFormId) +
      ".json";

    const formData = new FormData();
    if (consentFormDoc) {
      formData.append;
    }
    axios({
      method: method,
      url: url,
      data: {
        consent_form: {
          name: consentFormName,
          start_date: consentFormStartDate,
          end_date: consentFormEndDate,
          form_text_en: consentFormFormTextEn,
          form_text_ko: consentFormFormTextKo,
          active: consentFormActive
        }
      }
    })
      .then(response => {
        const data = response.data;
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const consentForm = data.consent_form;
          console.log(response);
          setConsentFormId(consentForm.id);
          setConsentFormName(consentForm.name);

          setConsentFormActive(consentForm.active || false);
          var receivedDate = new Date(Date.parse(consentForm.start_date));
          setConsentFormStartDate(receivedDate);
          var receivedDate = new Date(Date.parse(consentForm.end_date));
          setConsentFormEndDate(receivedDate);

          setConsentFormFormTextEn(consentForm.form_text_en || "");
          setConsentFormFormTextKo(consentForm.form_text_ko || "");

          setShowErrors(true);
          setDirty(false);
          setMessages(data.messages);
          dispatch(endTask("saving"));
        } else {
          setShowErrors(true);
          setMessages(data.messages);
          dispatch(endTask("saving"));
        }
      })
      .catch(error => {
        console.log("error", error);
        dispatch(endTask("saving"));
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getConsentForm();
    }
  }, [endpointStatus]);

  useEffect(() => setDirty(true), [
    consentFormName,
    consentFormActive,
    consentFormStartDate,
    consentFormEndDate
  ]);

  const saveButton = dirty ? (
    <Button onClick={saveConsentForm}>
      {null == consentFormId ? t("edit.create_btn") : t("edit.save_btn")}
    </Button>
  ) : null;

  const detailsComponent = (
    <Panel>
      <Container>
        <Row>
          <Col xs={12}>
            <span className="p-float-label">
              <InputText
                id="consent_form-name"
                itemID="consent_form-name"
                value={consentFormName}
                onChange={event => setConsentFormName(event.target.value)}
              />
              <label htmlFor="consent_form-name">{t("name")}</label>
            </span>
          </Col>
          <Col xs={12} sm={5}>
            <span className="p-float-label">
              <Calendar
                id="consent_form_dates"
                inputId="consent_form_dates"
                name="consent_form_dates"
                value={[consentFormStartDate, consentFormEndDate]}
                onChange={event => {
                  const changeTo = event.value;
                  if (null != changeTo && changeTo.length > 1) {
                    setConsentFormStartDate(changeTo[0]);
                    setConsentFormEndDate(changeTo[1]);
                  }
                }}
                selectionMode="range"
                showOnFocus={false}
                showIcon={true}
              />
              <label htmlFor="consent_form_dates">{t("study_dates")}</label>
            </span>
          </Col>
          <Col xs={12} sm={2}>
            <InputSwitch
              checked={consentFormActive}
              onChange={() => setConsentFormActive(!consentFormActive)}
              id="active"
              name="active"
              inputId="active"
              itemID="active"
            />
            <label htmlFor="active">{t("active")}</label>
          </Col>
        </Row>
      </Container>
      <TabView>
        <TabPanel header="English">
          <Editor
            id="english_form"
            placeholder={"en_form"}
            aria-label={"en_form"}
            headerTemplate={<EditorToolbar />}
            onTextChange={event => {
              setConsentFormFormTextEn(event.htmlValue);
            }}
            value={consentFormFormTextEn}
          />
        </TabPanel>
        <TabPanel header="Korean">
          <Editor
            id="korean_form"
            placeholder={"ko_form"}
            aria-label={"ko_form"}
            headerTemplate={<EditorToolbar />}
            onTextChange={event => {
              setConsentFormFormTextKo(event.htmlValue);
            }}
            value={consentFormFormTextKo}
          />
        </TabPanel>
      </TabView>
      &nbsp;
      <label htmlFor={consentFormDataId}>
        <input
          style={{ display: "none" }}
          id={consentFormDataId}
          name={consentFormDataId}
          onChange={handleFileSelect}
          type="file"
        />
        <Button>{t("edit.file_select_btn")}</Button>
      </label>
      <br />
      <br />
      {saveButton}
    </Panel>
  );

  return <Panel>{detailsComponent}</Panel>;
}
