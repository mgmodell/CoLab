import React from "react";
import PropTypes from "prop-types";
import { useTranslation } from "react-i18next";
import ChartContainer from "./ChartContainer";
import { Grid } from '@mui/material';

export default function ReportingAdmin(props) {
  const category = "graphing";
  const { t, i18n } = useTranslation( category );

  return (
    <Grid container>
      <Grid item xs={12} >
        <h1>
          {t('instruction')}
        </h1>
      </Grid>
        <ChartContainer
          unitOfAnalysis="group"
        />
      <Grid item xs={12} >
      </Grid>
    </Grid>
  );
}

ReportingAdmin.propTypes = {
};