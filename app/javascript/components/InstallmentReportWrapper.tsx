import React, { Suspense, useState, useEffect, lazy } from "react";
import PropTypes from "prop-types";
import classNames from "classnames";

import Skeleton from "@material-ui/lab/Skeleton";

import InstallmentReport from "./InstallmentReport";

/*
export default function InstallmentReportWrapper(props: {
  token: any;
  installmentId: any;
  getInstallmentUrl: any;
  setInstallmentUrl: any;
}) {
  */
export default function InstallmentReportWrapper(props) {
  return (
    <Suspense fallback={<Skeleton variant="rect" height={300} />}>
      <InstallmentReport
        token={props.token}
        installmentId={props.installmentId}
        getInstallmentUrl={props.getInstallmentUrl}
        setInstallmentUrl={props.setInstallmentUrl}
      />
    </Suspense>
  );
}

InstallmentReportWrapper.propTypes = {
  token: PropTypes.string.isRequired,
  installmentId: PropTypes.number.isRequired,
  getInstallmentUrl: PropTypes.string.isRequired,
  setInstallmentUrl: PropTypes.string.isRequired
};
