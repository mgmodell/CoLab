import React, { useState, Suspense } from "react";

import { useTranslation } from "react-i18next";

import axios from "axios";

import { Dialog } from "primereact/dialog";
import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { Container, Row, Col } from "react-grid-system";

type Props = {
  diversityScoreFor: string;
};

export default function DiversityCheck(props: Props) {
  const [emails, setEmails] = useState("");
  const [dialogOpen, setDialogOpen] = useState(false);
  const [diversityScore, setDiversityScore] = useState(null);
  const [foundUsers, setFoundUsers] = useState([]);

  const [t] = useTranslation();

  function calcDiversity() {
    const url = props.diversityScoreFor + ".json";
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

  function openDialog() {
    setDialogOpen(true);
  }

  function closeDialog() {
    setDialogOpen(false);
  }

  function handleChange(event) {
    setEmails(event.target.value);
  }

  return (
    <Suspense fallback={<div>Loading...</div>}>
      <React.Fragment>
        <Button
          label={t("calc_diversity")}
          icon="pi pi-calculator"
          link
          onClick={() => {
            openDialog();
          }}
        />
        <Dialog
          header={t("calc_it")}
          visible={dialogOpen}
          onHide={() => closeDialog()}
          aria-labelledby={t("calc_it")}
          footer={
            <>
              <Button onClick={calcDiversity}>{t("calc_diversity_sub")}</Button>
              <Button onClick={handleClear}>{t("clear")}</Button>
            </>
          }
        >
          <InputText value={emails} onChange={handleChange} />

          {foundUsers.length > 0 ? (
            <Container>
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
            </Container>
          ) : null}
        </Dialog>
      </React.Fragment>
    </Suspense>
  );
}
