import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";
import useResizeObserver from 'resize-observer-hook';
import {scaleLinear, scaleTime} from '@visx/scale';
import {
  AnimatedAxis,
  AnimatedGrid,
  AnimatedLineSeries,
  XYChart,
  Tooltip
  } from '@visx/xychart';
import axios from "axios";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { timeParse } from 'd3-time-format';

  export const unit_codes ={
    group: 2,
    individual: 1
  };

  export const code_units=[
    'individual', 'group'
  ]

export default function SubjectChart(props) {

  const endpointSet = "graphing";
  const endpoints = useTypedSelector(state=>state.context.endpoints[endpointSet]);
  const endpointStatus = useTypedSelector(state=>state.context.status.endpointsLoaded );
  const [ xDateDomain, setTimeRange ] = useState( [ new Date( ), new Date( ) ] );

  const height = 400;
  const [ref, chartWidth, chartHeight] = useResizeObserver( );

  const margin ={
    top: 40,
    bottom: 40,
    left: 40,
    right: 40
  }

  const parseTime = timeParse( "%Y-%m-%dT%H:%M:%S.%L%Z" );
  const yScale = scaleLinear({
    domain: [0,6000],
    rangeRound: [ (chartHeight - margin.top - margin.bottom), 0 ]
  })
  const xScale = scaleTime({
    domain: xDateDomain,
    rangeRound: [ 0, ( chartWidth - margin.left - margin.right ) ],
  })


  // Retrieve data
  const pullData = ()=>{
      const url = endpoints.dataUrl + '.json';

      axios.post( url, {
        unit_of_analysis: unit_codes[ props.unitOfAnalysis ],
        subject: props.subjectId,
        project: props.projectId,
        for_research: props.forResearch,
        anonymous: props.anonymize
      })
        .then( (resp) =>{
          console.log( 'graphing data', resp );
          const data = resp.data;
          setTimeRange( 
            [ parseTime( data.start_date ), parseTime( data.end_date ) ]
          );

        })
        .catch( (error) =>{
          console.lof( 'graphing data error', error );
        })
  }

  useEffect( () =>{
    if( endpointStatus ){
      pullData( );

    }

  }, [endpointStatus])


  return (
    <div ref={ref} >
      <XYChart height={height} xScale={xScale}  yScale={yScale} >
        <AnimatedAxis orientation='bottom' />
        <AnimatedAxis orientation='left' />

      </XYChart>
    </div>
  );
}

SubjectChart.propTypes = {
  subjectId: PropTypes.number.isRequired,
  projectId: PropTypes.number.isRequired,
  unitOfAnalysis: PropTypes.oneOf( ['individual', 'group'] ).isRequired,
  forResearch: PropTypes.bool,
  anonymize: PropTypes.bool
};
