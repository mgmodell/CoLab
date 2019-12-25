import React, { Suspense, useState, useEffect, lazy } from "react";
import PropTypes from "prop-types";
import classNames from "classnames";

import Skeleton from '@material-ui/lab/Skeleton';

import BingoGameDataAdmin from "./BingoGameDataAdmin";


export default function BingoGameDataAdminWrapper( props ){

    return (
    <Suspense fallback={
      <Skeleton variant='rect' height={300} />}
    >
      <BingoGameDataAdmin
        bingoGameUrl={props.bingoGameUrl}
        token={props.token}
        conceptUrl={props.conceptUrl}
        gameResultsUrl={props.gameResultsUrl}
      />
    </Suspense>
    );
}

BingoGameDataAdminWrapper.propTypes = {
  bingoGameUrl: PropTypes.string.isRequired,
  token: PropTypes.string.isRequired,
  conceptUrl: PropTypes.string.isRequired,
  gameResultsUrl: PropTypes.string.isRequired
};
