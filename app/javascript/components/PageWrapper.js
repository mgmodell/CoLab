import React, { useState, Suspense } from "react"
import Skeleton from '@material-ui/lab/Skeleton'
import PropTypes from "prop-types"
import AppHeader from "./AppHeader"

export default function PageWrapper(props) {
  return (
    <Suspense
      fallback={<Skeleton variant='rect' height={50} />}>

      <AppHeader
        token={props.token}
        getEndpointsUrl={props.getEndpointsUrl}
      />
    </Suspense>
  );
}

PageWrapper.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired

};
