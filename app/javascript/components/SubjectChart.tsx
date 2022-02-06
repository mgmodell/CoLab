import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";
import { LinePath } from "@visx/shape";
import { scaleLinear } from "@visx/scale";
import { curveMonotoneX } from "@visx/curve";
import { Text } from "@visx/text";
import axios from "axios";

export default function SubjectChart(props) {

  const endpointSet = "graphing";
  const endpoints = useTypedSelector(state=>state.context.endpoints[endpointSet]);
  const endpointStatus = useTypedSelector(state=>state.context.status.endpointsLoaded );

  useEffect( () =>{
    if( endpointStatus ){
      const url = endpoints.dataUrl + '.json';

      axios.post( url, {
        unit_of_analysis: props.unit_of_analysis,
        subject: props.subjectId,
        project: props.projectId,
        for_research: props.forResearch,
        anonymous: props.anonymize
      })
        .then( (resp) =>{
          console.log( 'graphing data', resp );

        })
        .catch( (error) =>{
          console.lof( 'graphing data error', error );
        })

    }

  }, [endpointStatus])

  return (
    <React.Fragment>
      <svg width={props.width} height={props.height}>
      </svg>
    </React.Fragment>
  );
}

SubjectChart.propTypes = {
  height: PropTypes.number.isRequired,
  width: PropTypes.number.isRequired,
  subjectId: PropTypes.number.isRequired,
  projectId: PropTypes.number.isRequired,
  unitOfAnalysis: PropTypes.oneOf( ['individual', 'group'] ),
  forResearch: PropTypes.bool,
  anonymize: PropTypes.bool
};
