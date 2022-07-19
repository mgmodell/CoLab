import React, { Suspense, useState, useEffect, lazy } from "react";
import PropTypes from "prop-types";
import classNames from "classnames";

import Skeleton from '@mui/material/Skeleton';

import BingoGameDataAdmin from "./BingoGameDataAdmin";

export default function BingoGameDataAdminWrapper(props) {
  return (
    <Suspense fallback={<Skeleton variant="rectangular" height={300} />}>
      <BingoGameDataAdmin
        courseId={props.courseId}
        bingoGameId={props.bingoGameId}
      />
    </Suspense>
  );
}

BingoGameDataAdminWrapper.propTypes = {
  courseId: PropTypes.number.isRequired,
  bingoGameId: PropTypes.number
};
