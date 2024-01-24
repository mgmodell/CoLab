import React from "react";
import { useTranslation } from "react-i18next";

import ChartContainer from "./ChartContainer";
import { Container, Row, Col } from "react-grid-system";

export default function ReportingAdmin(props) {
  const category = "graphing";
  const { t, i18n } = useTranslation(category);

  return (
    <Container>
      <Row>
        <Col xs={12}>
          <h1>{t('instructions')}</h1>
        </Col>
        <Col xs={12}>
          <ChartContainer unitOfAnalysis="group" />
        </Col>

      </Row>
    </Container>

  );
}

ReportingAdmin.propTypes = {};
