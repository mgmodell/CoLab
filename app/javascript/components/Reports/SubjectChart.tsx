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
import { arc, Pie, LinePath, Arc } from '@visx/shape';
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
  const factorCount = Object.keys( factors ).length;
  const factorLegendWidth = factorCount > 1 ? ( 2 * lbw ) : lbw;
  const factorLegendRows = Math.round( factorCount / 2 );

  const userCount = Object.keys( users ).length;
  const userLegendWidth =  userCount > 1 ? (2 * lbw ) : lbw;
  const userLegendRows = Math.round( userCount / 2 );

  return (
    <div ref={ref} >
      {
        ( props.hidden || false ) ? null : (
      <XYChart height={height} xScale={xScale}  yScale={yScale} >
        <AnimatedAxis orientation='bottom' />
        <AnimatedAxis orientation='left' />
        <g
          className='userLegend'
          transform={`translate( 50, 40 )`}
          factorlegendwidth={userLegendWidth}
          opacity={0.7}
        >
          <rect
            x1={0}
            y={0}
            width={userLegendWidth}
            height={userLegendRows * lbh}
            fill="oldlace"
            stroke="black"
          />
          {
            Object.values( users ).map( (user,index) =>{
              return(
                <React.Fragment key={`user_legend_${index}`}>
                  <text
                    x={10 + (index %2 * lbw )}
                    y={13 + Math.floor( index / 2 ) * lbh }
                    fill="black"
                    fontSize='10px'
                  >
                    {user.name}
                  </text>
                </React.Fragment>
              )
            })
          }
        </g>
        <g
          className='factorLegend'
          transform={`translate( ${chartWidth - 50 - factorLegendWidth}, 40 )`}
          factorlegendwidth={factorLegendWidth}
          opacity={0.7}
        >
          <rect
            x1={0}
            y={0}
            width={factorLegendWidth}
            height={factorLegendRows * lbh}
            fill="oldlace"
            stroke="black"
          />
          {
            Object.values( factors ).map( (factor,index) =>{
              return(
                <React.Fragment key={`factor_legend_${index}`}>
                  <circle
                    cx={10 + (index %2 * lbw )}
                    cy={10 + Math.floor(index /2) * lbh }
                    r={7}
                    stroke="black"
                    strokeWidth={1}
                    fill={ hsl( (index * 60 ) , 40, 30)}
                  />
                  <text
                    x={24 + (index %2 * lbw )}
                    y={13 + Math.floor( index / 2 ) * lbh }
                    fill="black"
                    fontSize='10px'
                  >
                    {factor.name}
                  </text>
                </React.Fragment>
              )
            })
          }
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
              {
                range( 130, 470, 5 ).map( ( val, index ) =>{
                  return(
                    <Arc
                      key={`arc-${index}`}
                      className="rainbow"
                      startAngle={1.05 + ( index / 80 ) }
                      endAngle={1.05 + ( ( 1 + index ) / 80 )}
                      outerRadius={40}
                      innerRadius={3}
                      fill={hsl( val, 100, 50 ).toString( )}
                    />
                  )

                })

              }
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
