import React, { Suspense, useState, useEffect, lazy } from "react";
import PropTypes from "prop-types";
import classNames from "classnames";

import Skeleton from "@material-ui/lab/Skeleton";

import BingoGameDataAdmin from "./BingoGameDataAdmin";

export default function BingoGameDataAdminWrapper(props) {
  return (
    <Suspense fallback={<Skeleton variant="rect" height={300} />}>
      <BingoGameDataAdmin
        token={props.token}
        getEndpointsUrl={props.getEndpointsUrl}
        courseId={props.courseId}
        bingoGameId={props.bingoGameId}
      />
    </Suspense>
  );
}

BingoGameDataAdminWrapper.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  courseId: PropTypes.number.isRequired,
  bingoGameId: PropTypes.number
};
