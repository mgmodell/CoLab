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
import {curveLinearClosed } from '@visx/curve';
import { Pie, LinePath, arc } from '@visx/shape';
import axios from "axios";
import { useTypedSelector } from "../infrastructure/AppReducers";
import {range} from 'd3-array';
import {hsl} from 'd3-color';
import { timeParse } from 'd3-time-format';
import { identity } from "lodash";

  export const unit_codes ={
    group: 2,
    individual: 1
  };

  export const code_units=[
    'individual', 'group'
  ]

export default function SubjectChart(props) {
  const π = Math.PI;
  const τ = .35 * π;
  const n = 500;

  const endpointSet = "graphing";
  const endpoints = useTypedSelector(state=>state.context.endpoints[endpointSet]);
  const endpointStatus = useTypedSelector(state=>state.context.status.endpointsLoaded );

  const [ xDateDomain, setTimeRange ] = useState( [ new Date( ), new Date( ) ] );
  const [factors, setFactors] = useState( { } );
  const [users, setUsers] = useState( { } );


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
    range: [ (chartHeight - margin.top - margin.bottom), 0 ],
    round: true,
  })
  const xScale = scaleTime({
    domain: xDateDomain,
    range: [ 0, ( chartWidth - margin.left - margin.right ) ],
    round: true,
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

          const factorColor = scaleLinear( {
            domain: [ 0, Object.keys( factors ).length ],
            range: ['red', 'orange', 'yellow', 'green', 'purple', 'blue'],
          });

          let index : number = 0;

          //Set up the factors
          for( let id of Object.keys( data.factors ) ){
            data.factors[ id ][ 'color' ] = factorColor( index );
            index ++;
          };
          setFactors( data.factors );

          //Set up the users
          index = 0;
          for( let id of Object.keys( data.users ) ){
            data.users[ id ][ 'index' ] = index;
            index++
          }
          setUsers( data.users );

        })
        .catch( (error) =>{
          console.log( 'graphing data error', error );
        })
  }

  useEffect( () =>{
    if( endpointStatus ){
      pullData( );

    }

  }, [endpointStatus])


  const lbw = 170; //Legend Base Width
  const lbh = 20; //Legend Base Height
  const factor_count = Object.keys( factors ).length;
  const factor_legend_width = factor_count > 1 ? ( 2 * lbw ) : lbw;
  const factor_legend_rows = Math.round( factor_count / 2 );
  return (
    <div ref={ref} >
      {
        ( props.hidden || false ) ? null : (
      <XYChart height={height} xScale={xScale}  yScale={yScale} >
        <AnimatedAxis orientation='bottom' />
        <AnimatedAxis orientation='left' />
        <g
          className='factorLegend'
          transform={`translate( ${chartWidth - 50 - factor_legend_width}, 40 )`}
          factorlegendwidth={factor_legend_width}
          opacity={0.7}
        >


        </g>
        {
          ( undefined === props.hideFunc ) ? null :
          (
        <g
          className='buttonBar'
          transform={`translate( ${ chartWidth - 25 }, 25 )`}
        >
          <g className="closeButton" onClick={props.hideFunc}>
            <circle cx={0} cy={0} r={17} stroke='red' fill="white" />
            <line x1={10} y1={-10} x2={-10} y2={10} strokeWidth={2} stroke="black" />
            <line x1={-10} y1={-10} x2={10} y2={10} strokeWidth={2} stroke="black" />
          </g>
          <g className="export" transform='translate( 0, 45)' >
            <circle
              cx={0}
              cy={0}
              r={17}
              stroke="red"
              fill="white"
              />
              <rect
                x={-2.5}
                y={-12}
                width={5}
                height={14}
                fill="black"
                stroke="black"
                />
              <rect
                x={-9}
                y={8}
                width={18}
                height={3}
                fill="black"
                stroke="black"
                />
              <LinePath
                curve={curveLinearClosed}
                data={[
                  { x: -8, y: -3 },
                  { x: 0, y: 6 },
                  { x: 8, y: -3 } ]}
                fill='black'
                stroke="black"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1}
                x={ (d)=> d.x}
                y={ (d)=> d.y}
              />
          </g>
          <g className="focus" transform="translate( 0, 100 )">
              <LinePath
                curve={curveLinearClosed}
                data={[
                  { x: -40, y: 0 },
                  { x: 0, y: -1.5 },
                  { x: 0, y: 1.5 } ]}
                fill='orange'
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1}
                x={ (d)=> d.x}
                y={ (d)=> d.y}
              />
              <Pie
                className="rainbow"
                data={ range( 0, τ, τ / n  ) }
                outerRadius={40}
                innerRadius={3}
                startAngle={-π}
                endAngle={π}
                fill={ (d)=>{
                  return hsl(d * 360 / τ, 1, .5)
                }
                }

              />
              <LinePath
                curve={curveLinearClosed}
                data={[
                  { x: 0, y: -15 },
                  { x: 3, y: 18 },
                  { x: -18, y: 13 } ]}
                fill='steelblue'
                stroke="black"
                opacity={0.6}
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1}
                x={ (d)=> d.x}
                y={ (d)=> d.y}
              />
              <LinePath
                curve={curveLinearClosed}
                data={[
                  { x: 0, y: -15 },
                  { x: 3, y: 18 },
                  { x: 18, y: 13 } ]}
                fill='lightsteelblue'
                stroke="black"
                opacity={0.4}
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1}
                x={ (d)=> d.x}
                y={ (d)=> d.y}
              />

          </g>
        </g>

          )
        }

      </XYChart>

        )

      }
    </div>
  );
}

SubjectChart.propTypes = {
  subjectId: PropTypes.number.isRequired,
  projectId: PropTypes.number.isRequired,
  unitOfAnalysis: PropTypes.oneOf( ['individual', 'group'] ).isRequired,
  forResearch: PropTypes.bool,
  anonymize: PropTypes.bool,
  hideFunc: PropTypes.func,
  hidden: PropTypes.bool
};
