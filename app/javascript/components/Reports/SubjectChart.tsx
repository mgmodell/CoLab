import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";
import useResizeObserver from 'resize-observer-hook';
import {scaleLinear, scaleOrdinal, scaleTime} from '@visx/scale';
import {
  AnimatedAxis,
  AnimatedGrid,
  AnimatedLineSeries,
  AnimatedGlyphSeries,
  XYChart,
  Tooltip
  } from '@visx/xychart';
import {curveLinearClosed, curveMonotoneX, curveNatural } from '@visx/curve';
import { arc, Pie, LinePath, Arc } from '@visx/shape';
import axios from "axios";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";
import {range} from 'd3-array';
import {hsl} from 'd3-color';
import {schemeCategory10 as factorColors } from 'd3-scale-chromatic';
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
  const category = "graphing";
  const endpoints = useTypedSelector(state=>state.context.endpoints[category]);
  const endpointStatus = useTypedSelector(state=>state.context.status.endpointsLoaded );
  const { t, i18n } = useTranslation( category );

  const [ xDateDomain, setTimeRange ] = useState( [ new Date( ), new Date( ) ] );
  const [factors, setFactors] = useState( { } );
  const [users, setUsers] = useState( { } );

  const [subject, setSubject ] = useState( '' );
  const [projectName, setProjectName ] = useState( '' );
  const [streams, setStreams] = useState( { } );
  const [comments, setComments ] = useState( {} );


  const chartHeight = 400;
  const [ref, chartWidth, discard] = useResizeObserver( );

  const margin ={
    top: 100,
    bottom: 40,
    left: 40,
    right: 40
  }

  const parseTime = timeParse( "%Y-%m-%dT%H:%M:%S.%L%Z" );


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

          const factorColor = scaleOrdinal( {
            domain: [ 0, Object.keys( factors ).length ],
            range: factorColors,
          });

          let index : number = 0;

          //Set up the factors
          for( let id of Object.keys( data.factors ) ){
            data.factors[id]['color'] = factorColor( index );
            index ++;
          };
          setFactors( data.factors );

          //Set up the users
          index = 0;
          for( let id of Object.keys( data.users ) ){
            data.users[ id ][ 'index' ] = index;
            data.users[ id ][ 'dasharray' ] = `${( index * 5 )} ${(index * 5)}`;
            index++
          }
          setUsers( data.users );
          setSubject( data.subject );
          setProjectName( data.project_name );
          setStreams( data.streams );
          setComments( data.comments );

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


  const titleX = chartWidth / 2;
  const titleY = 20;
  const lbw = 160; //Legend Base Width
  const lbh = 20; //Legend Base Height
  const factorCount = Object.keys( factors ).length;
  const factorLegendWidth = factorCount > 1 ? ( 2 * lbw ) : lbw;
  const factorLegendRows = Math.round( factorCount / 2 );

  const userCount = Object.keys( users ).length;
  const userLegendWidth =  userCount > 1 ? (2 * lbw ) : lbw;
  const userLegendRows = Math.round( userCount / 2 );

  const today = Date.now( );

  const accessors = {
    xAccessor: d => {
      //return parseTime( undefined != d ? d.date : today );
      return parseTime( d.date );
    },
    yAccessor: d => d.value,
  };


  return (
    <div ref={ref} >
      {
        ( props.hidden || false ) ? null : (
          <React.Fragment>

      <XYChart height={chartHeight} 
        margin={ margin } 
        xScale={{ type: "time", domain: xDateDomain }}
        yScale={{ type: "linear", domain: [0, 6000] }} >
        <AnimatedAxis orientation='bottom' label="Date" />
        <AnimatedAxis orientation='left' label="Contribution Level" numTicks={6} />
        <g
          transform={ `translate( ${titleX}, ${titleY})`}
          className="title"
        >
          <text
            x={0}
            y={0}
            textAnchor="middle"
            fontSize="16px"
            textDecoration="underline"
          >
            {t(`chart_for_${props.unitOfAnalysis}`)} {subject}
          </text>
          <text
            x={0}
            y={15}
            textAnchor="middle"
            fontSize="10px"
            textDecoration="underline"
          >
            {t("chart_for_project")}: {projectName}
          </text>

        </g>
        <g
          className='legends'
          transform='translate( 0, 45 )'
        >

        <g
          className='userLegend'
          transform={`translate( 50, 0 )`}
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
                  <line
                    x1={10 + (index %2 * lbw )}
                    y1={15 + Math.floor( index / 2 ) * lbh }
                    x2={ lbw + (index %2 * lbw ) - 30 }
                    y2={15 + Math.floor( index / 2 ) * lbh }
                    stroke="black"
                    strokeWidth={3}
                    strokeDasharray={ `${( index * 5 )} ${(index * 5)}` }
                  />
                </React.Fragment>
              )
            })
          }
        </g>
        <g
          className='factorLegend'
          transform={`translate( ${chartWidth - 50 - factorLegendWidth}, 0 )`}
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
                    fill={ factor.color }
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
        {
          <Tooltip
            detectBounds
            snapTooltipToDatumX
            snapTooltipToDatumY
            showVerticalCrosshair
            renderTooltip={({ tooltipData, colorScale }) =>{
              const comment = comments[ tooltipData.nearestDatum.datum.installment_id ];
              return (
                <div>
                  <p>
                    <strong>Teammate:</strong> {comment.commentor}<br />
                    {comment.comment}
                  </p>
                </div>
              )
            } }
          />
        }
        <g className="data">
        {Object.values( streams ).map( (stream)=>{
          return(
            <React.Fragment key={`stream-target-${stream.target_id}`}>
              {
                Object.values( stream.sub_streams ).map( (subStream) =>{
                  return(
                    <React.Fragment key={`sub-assessor-${subStream.assessor_id}`}>
                      {
                          Object.values( subStream.factor_streams).map( (factorStream)=>{
                            const datakey = `${subStream.assessor_name} - ${factorStream.factor_name}`;
                            return(
                              <React.Fragment
                                key={ `factor-${factorStream.factor_id}` }
                                >
                              <AnimatedLineSeries
                                data={ factorStream.values }
                                dataKey={ datakey }
                                {...accessors}
                                curve={curveMonotoneX}
                                stroke={ factors[ factorStream.factor_id]['color']}
                                strokeDasharray={users[ stream.target_id ].dasharray}
                              />
                              <AnimatedGlyphSeries
                                data={ factorStream.values }
                                dataKey={ `glyph-${datakey}` }
                                {...accessors}
                                stroke={ factors[ factorStream.factor_id]['color']}
                                
                              />
                              </React.Fragment>
                            )

                          } )

                      }
                    </React.Fragment>
                  )
                }
                )
              }
            </React.Fragment>
          )

          } )
        }

        </g>

      </XYChart>
          </React.Fragment>

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
