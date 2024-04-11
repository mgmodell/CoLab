import React from "react";
import { useTranslation } from "react-i18next";

import ChartContainer from "./ChartContainer";
import { Container, Row, Col } from "react-grid-system";
import { Panel } from "primereact/panel";

export default function ReportingAdmin(props) {
  const category = "graphing";
  const { t, i18n } = useTranslation(category);

  return (
    <Panel header={t("instructions")}>
      <ChartContainer unitOfAnalysis="group" />
    </Panel>
  );
}

ReportingAdmin.propTypes = {};
