import React, { useState, useEffect } from "react";
import axios from "axios";

import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";

import { Button } from "primereact/button";
import { FloatLabel } from "primereact/floatlabel";
import { InputText } from "primereact/inputtext";
import { Panel } from "primereact/panel";
import { Tag } from "primereact/tag";
import { Container, Row, Col } from "react-grid-system";

interface ILtiConnection {
  id: number | null;
  line_item_url: string;
  ags_access_token_url: string;
  client_id: string;
  deployment_id: string;
  iss: string;
}

interface Props {
  // URL to GET and PATCH the LTI connection (e.g. `/api-backend/bingo_games/lti/42.json`)
  connectionUrl: string;
  // URL to POST grade push (e.g. `/api-backend/bingo_games/push_grades/42.json`)
  gradePushUrl: string;
  // i18n translation function bound to the activity namespace
  t: (key: string) => string;
}

const EMPTY_CONNECTION: ILtiConnection = {
  id: null,
  line_item_url: "",
  ags_access_token_url: "",
  client_id: "",
  deployment_id: "",
  iss: ""
};

export default function LtiConnectionPanel(props: Props) {
  const { connectionUrl, gradePushUrl, t } = props;
  const dispatch = useDispatch();

  const [connection, setConnection] = useState<ILtiConnection>({
    ...EMPTY_CONNECTION
  });
  const [configured, setConfigured] = useState(false);
  const [dirty, setDirty] = useState(false);

  useEffect(() => {
    if (connectionUrl) {
      loadConnection();
    }
  }, [connectionUrl]);

  const loadConnection = () => {
    dispatch(startTask("loading_lti"));
    axios
      .get(connectionUrl)
      .then(response => {
        const data = response.data;
        setConnection(data.lti_connection || { ...EMPTY_CONNECTION });
        setConfigured(data.configured || false);
        setDirty(false);
      })
      .catch(error => {
        console.error("LTI connection load error:", error);
      })
      .finally(() => {
        dispatch(endTask("loading_lti"));
      });
  };

  const saveConnection = () => {
    dispatch(startTask("saving_lti"));
    axios
      .patch(connectionUrl, { lti_connection: connection })
      .then(response => {
        const data = response.data;
        setConnection(data.lti_connection || { ...EMPTY_CONNECTION });
        setConfigured(data.configured || false);
        setDirty(false);
        if (data.messages?.main) {
          dispatch(addMessage(data.messages.main, new Date(), Priorities.INFO));
        }
      })
      .catch(error => {
        console.error("LTI connection save error:", error);
        dispatch(
          addMessage(
            t("lti.connection_save_failed"),
            new Date(),
            Priorities.ERROR
          )
        );
      })
      .finally(() => {
        dispatch(endTask("saving_lti"));
      });
  };

  const pushGrades = () => {
    if (!window.confirm(t("lti.push_confirm"))) return;

    dispatch(startTask("pushing_lti_grades"));
    axios
      .post(gradePushUrl)
      .then(response => {
        const data = response.data;
        if (data.messages?.main) {
          dispatch(
            addMessage(
              data.messages.main,
              new Date(),
              data.success ? Priorities.INFO : Priorities.WARNING
            )
          );
        }
      })
      .catch(error => {
        const msg =
          error?.response?.data?.messages?.main || t("lti.not_configured");
        dispatch(addMessage(msg, new Date(), Priorities.ERROR));
      })
      .finally(() => {
        dispatch(endTask("pushing_lti_grades"));
      });
  };

  const handleChange = (field: keyof ILtiConnection, value: string) => {
    setConnection(prev => ({ ...prev, [field]: value }));
    setDirty(true);
  };

  return (
    <Panel header={t("lti.panel_title")}>
      <Container>
        <Row>
          <Col xs={12}>
            <Tag
              value={configured ? t("lti.configured") : t("lti.not_configured")}
              severity={configured ? "success" : "warning"}
              style={{ marginBottom: "1rem" }}
            />
          </Col>
          <Col xs={12}>
            <FloatLabel>
              <InputText
                id="lti_line_item_url"
                value={connection.line_item_url || ""}
                onChange={e => handleChange("line_item_url", e.target.value)}
                placeholder={t("lti.line_item_url_placeholder")}
                style={{ width: "100%" }}
              />
              <label htmlFor="lti_line_item_url">
                {t("lti.line_item_url_lbl")}
              </label>
            </FloatLabel>
          </Col>
          <Col xs={12}>
            <FloatLabel>
              <InputText
                id="lti_ags_token_url"
                value={connection.ags_access_token_url || ""}
                onChange={e =>
                  handleChange("ags_access_token_url", e.target.value)
                }
                placeholder={t("lti.ags_token_url_placeholder")}
                style={{ width: "100%" }}
              />
              <label htmlFor="lti_ags_token_url">
                {t("lti.ags_token_url_lbl")}
              </label>
            </FloatLabel>
          </Col>
          <Col xs={6}>
            <FloatLabel>
              <InputText
                id="lti_client_id"
                value={connection.client_id || ""}
                onChange={e => handleChange("client_id", e.target.value)}
                style={{ width: "100%" }}
              />
              <label htmlFor="lti_client_id">{t("lti.client_id_lbl")}</label>
            </FloatLabel>
          </Col>
          <Col xs={6}>
            <FloatLabel>
              <InputText
                id="lti_deployment_id"
                value={connection.deployment_id || ""}
                onChange={e => handleChange("deployment_id", e.target.value)}
                style={{ width: "100%" }}
              />
              <label htmlFor="lti_deployment_id">
                {t("lti.deployment_id_lbl")}
              </label>
            </FloatLabel>
          </Col>
          <Col xs={12}>
            <FloatLabel>
              <InputText
                id="lti_iss"
                value={connection.iss || ""}
                onChange={e => handleChange("iss", e.target.value)}
                style={{ width: "100%" }}
              />
              <label htmlFor="lti_iss">{t("lti.iss_lbl")}</label>
            </FloatLabel>
          </Col>
          <Col xs={6}>
            <Button
              label={t("lti.save_btn")}
              icon="pi pi-save"
              disabled={!dirty}
              onClick={saveConnection}
            />
          </Col>
          <Col xs={6}>
            <Button
              label={t("lti.push_btn")}
              icon="pi pi-send"
              severity="secondary"
              disabled={!configured}
              onClick={pushGrades}
            />
          </Col>
        </Row>
      </Container>
    </Panel>
  );
}
