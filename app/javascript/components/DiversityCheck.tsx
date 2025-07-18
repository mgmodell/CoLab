import React, { Fragment, useState } from "react";

import { useTranslation } from "react-i18next";

import axios from "axios";

import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { Container, Row, Col } from "react-grid-system";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { Panel } from "primereact/panel";

type Props = {
};

export default function DiversityCheck(props: Props) {
  const endpointSet = "home";
  const [emails, setEmails] = useState("");
  const [diversityScore, setDiversityScore] = useState(null);
  const [foundUsers, setFoundUsers] = useState([]);

  const { t } = useTranslation( /* endpointSet */);
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );

  function calcDiversity() {
    const url = endpoints.diversityScoreFor + ".json";
    axios
      .post(url, {
        emails: emails
      })
      .then(response => {
        const data = response.data;
        setDiversityScore(data.diversity_score);
        setFoundUsers(data.found_users);
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      });
  }
  function handleClear() {
    setEmails("");
    setDiversityScore(null);
    setFoundUsers([]);
  }

  function handleChange(event) {
    setEmails(event.target.value);
  }

  return (
    <Panel header={t("calc_diversity_hdr")}>

      <Container>
        <Row>
          <Col>{t("calc_diversity_instr")}</Col>
        </Row>
        <Row>
          <Col>
            <InputText value={emails} onChange={handleChange} />
          </Col>
        </Row>
        {foundUsers.length > 0 ? (
          <Fragment>
            <Row>
              <Col>{t("found_users")}</Col>
              <Col>{t("perspective_score")}</Col>
            </Row>
            <Row>
              <Col>
                {foundUsers.map(user => {
                  return (
                    <a key={user.email} href={"mailto:" + user.email}>
                      {user.name}
                      <br />
                    </a>
                  );
                })}
              </Col>
              <Col>{diversityScore}</Col>
            </Row>
          </Fragment>
        ) : null}
        <Row>
          <Col><br /></Col>
        </Row>
        <Row>
          <Col>
            <Button onClick={calcDiversity}>{t("calc_diversity_sub")}</Button>
          </Col>
          <Button onClick={handleClear}>{t("clear")}</Button>
          <Col>
          </Col>
        </Row>
      </Container>
    </Panel>
  );
}
