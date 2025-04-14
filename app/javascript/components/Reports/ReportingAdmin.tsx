import React from "react";
import { useTranslation } from "react-i18next";

import ChartContainer from "./ChartContainer";
import { Panel } from "primereact/panel";
import { useTypedSelector } from "../infrastructure/AppReducers";

export default function ReportingAdmin(props) {
  const category = "graphing";
  const { t, i18n } = useTranslation(category);
  const user = useTypedSelector(state => state.profile.user);

  const layText = ! (user.is_admin || user.is_instructor) ?
    t("lay_instructions") :
    t("admin_instructions");

  return (
    <Panel header={t("instructions")}>
      <p>
        {layText}
      </p>

      <ChartContainer unitOfAnalysis="group" />
    </Panel>
  );
}

ReportingAdmin.propTypes = {};
