import React, { Suspense, useState, useEffect, useReducer } from "react";
import { useParams } from "react-router-dom";

//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
} from "../infrastructure/StatusSlice";
import parse from "html-react-parser";

import RubricViewer, { CLEAN_RUBRIC, ICriteria } from "./RubricViewer";
import { IRubricData } from "./RubricViewer";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { DateTime, Settings } from "luxon";

import { useTranslation } from "react-i18next";

import AssignmentSubmission from "./AssignmentSubmission";
import { TabView, TabPanel } from "primereact/tabview";
import { Skeleton } from "primereact/skeleton";
import { Container, Col, Row } from "react-grid-system";
import {
  AnimatedAreaSeries,
  AnimatedAreaStack,
  AnimatedAxis,
  AnimatedBarGroup,
  AnimatedBarSeries,
  AnimatedBarStack,
  AnimatedGrid,
  AreaSeries,
  AreaStack,
  Axis,
  BarGroup,
  BarSeries,
  BarStack,
  LineSeries,
  Tooltip,
  XYChart
} from "@visx/xychart";

import { scaleOrdinal } from '@visx/scale';
import { schemeSet1 } from 'd3-scale-chromatic';

interface ISubmissionCondensed {
  id: number;
  recordedScore: number;
  submitted: DateTime;
  withdrawn: DateTime;
  user: string;
  group: string;
  submission_feedback: ISubmissionFeedback;
  rubric_row_feedbacks: Array<IRubricRowFeedback>;
}

interface ISubmissionFeedback {
  feedback: string;
  submitted: DateTime;
}

interface IRubricRowFeedback {
  id: number;
  feedback: string;
  score: number;
  criterium_id: number;
}
interface IAssignment {
  id: number | null;
  name: string;
  description: string;
  startDate: DateTime;
  endDate: DateTime;
  textSub: boolean;
  linkSub: boolean;
  fileSub: boolean;
  submissions: Array<ISubmissionCondensed>;
  rubric: IRubricData;
}

const CLEAN_ASSIGNMENT: IAssignment = {
  id: null,
  name: "",
  description: "",
  startDate: DateTime.local(),
  endDate: DateTime.local(),
  textSub: false,
  linkSub: false,
  fileSub: false,
  submissions: [],
  rubric: CLEAN_RUBRIC,
};


export default function AssignmentViewer(props) {
  const endpointSet = "assignment";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const { assignmentId } = useParams();

  const dispatch = useDispatch();
  const [t, i18n] = useTranslation(`${endpointSet}s`);

  const [curTab, setCurTab] = useState(0);
  const [progressData, setProgressData] = useState([]);

  enum AssignmentActions {
    setAssignment = "SET ASSIGNMENT",
    setValue = "SET VALUE"
  }

  const assignmentReducer = (state, action) => {
    switch (action.type) {
      case AssignmentActions.setAssignment:
        return { ...(action.assignment as IAssignment) };
      case AssignmentActions.setValue:
        return { ...state, [action.field]: action.value };
      default:
        throw new Error();
    }
  };
  const [assignment, modifyAssignment] = React.useReducer(
    assignmentReducer,
    CLEAN_ASSIGNMENT
  );

  useEffect(() => {
    if (endpointsLoaded) {
      loadAssignment();
    }
  }, [endpointsLoaded]);

  //Retrieve the latest data
  const loadAssignment = () => {
    const url = `${endpoints.statusUrl}${assignmentId}.json`;
    dispatch(startTask());
    axios(url, {})
      .then(response => {
        const data = response.data;

        //Process, clean and set the data received
        const receivedAssignment: IAssignment = { ...data.assignment };
        let receivedDate = DateTime.fromISO(data.assignment.start_date).setZone(
          Settings.timezone
        );
        receivedAssignment.startDate = receivedDate;
        receivedDate = DateTime.fromISO(data.assignment.end_date).setZone(
          Settings.timezone
        );
        receivedAssignment.endDate = receivedDate;
        receivedAssignment.rubric = data.rubric;
        receivedAssignment.submissions = data.submissions;
        //Convert snake- to camel-case properties
        receivedAssignment.textSub = receivedAssignment.text_sub;
        delete receivedAssignment.text_sub;
        receivedAssignment.fileSub = receivedAssignment.file_sub;
        delete receivedAssignment.file_sub;
        receivedAssignment.linkSub = receivedAssignment.link_sub;
        delete receivedAssignment.link_sub;

        modifyAssignment({
          type: AssignmentActions.setAssignment,
          assignment: receivedAssignment
        });

        //Prepare the progress data
        const localProgressData = receivedAssignment.submissions.map((submission: ISubmissionCondensed) => {
          const feedbacks = {};
          if (submission.rubric_row_feedbacks.length > 0) {
            submission.rubric_row_feedbacks.forEach((lFeedback: IRubricRowFeedback) => {
              feedbacks[lFeedback.criterium_id] = {
                feedback: lFeedback.feedback,
                score: lFeedback.score,
              }
            });
            return {
              submitted: submission.submitted,
              feedbacks: feedbacks,
            };
          } else {
            return null;
          }
        }).filter((feedback) => {
          return feedback !== null;
        });
        setProgressData(localProgressData);
      })

      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };
  const maxId = assignment.rubric.criteria.reduce((
    (maximum, next) => {
      return Math.max(maximum, next.id);
    }
  ), 0);
  const minId = assignment.rubric.criteria.reduce((
    (maximum, next) => {
      return Math.min(maximum, next.id);
    }
  ), maxId);
  const keys = [];
  for (let i = minId; i <= maxId; i++) {
    keys.push(i);
  }
  const colorScale = scaleOrdinal({
    domain: keys,
    range: schemeSet1,
  });


  let output = null;
  const curDate = DateTime.local();
  if (!endpointsLoaded) {
    output = <Skeleton className="mb-2" />;
  } else {
    output = (
      <TabView activeIndex={curTab} onTabChange={e => setCurTab(e.index)}>
        <TabPanel header={"Overview"}>
          <Container fluid>
            <Row>
              <Col xs={12} sm={3}>
                <h6>{t("name")}:</h6>
              </Col>
              <Col xs={12} sm={9}>
                <span>{assignment.name}</span>
              </Col>
            </Row>
            <Row>
              <Col xs={12} sm={3}>
                <h6>{t("status.brief")}:</h6>
              </Col>
              <Col xs={12} sm={9}>
                <span>{assignment.description}</span>
              </Col>
            </Row>
            <Row>
              <Col xs={12}>
                <h6>{t("status.eval_criteria")}:</h6>

              </Col>
            </Row>
            <Row>
              <Col xs={12}>
                <RubricViewer rubric={assignment.rubric} />
              </Col>
            </Row>
          </Container>
        </TabPanel>
        <TabPanel header={t("submissions.response_tab_lbl")}>
          <AssignmentSubmission
            assignment={assignment}
            reloadCallback={loadAssignment}
          />
        </TabPanel>
        <TabPanel
          header={t("progress.progress_tab_lbl")}
          disabled={
            assignment.startDate > curDate || assignment.endDate < curDate
          }
        >
          <XYChart
            xScale={{ type: "band" }}
            yScale={{ type: "linear" }}
            width={500}
            height={300}
          >
            <AnimatedAxis
              orientation='bottom'
            />
            <AnimatedAxis
              orientation='left'
            />
            <AnimatedGrid
              columns={true}
              rows={true}
            />
            <Tooltip
              snapTooltipToDatumX
              snapTooltipToDatumY
              showVerticalCrosshair
              showSeriesGlyphs
              showDatumGlyph
              applyPositionStyle
              renderTooltip={({ tooltipData, colorScale }) => {
                const content = Object.values(tooltipData.nearestDatum.datum.feedbacks).map((feedback, index) => {
                  return (
                    <>
                      <li><strong>
                        {feedback.score}:
                        </strong>
                      {parse(feedback.feedback)} </li>
                    </>
                  )
                });
                return (
                  <div>
                    <p><strong>Date:</strong>{DateTime.fromISO(tooltipData.nearestDatum.datum.submitted).setZone(Settings.timezone).toLocaleString(DateTime.DATETIME_SHORT)}</p>
                    <ul>
                      {content}
                    </ul>
                  </div>
                );
              }}
            />


            <AnimatedAreaStack >
              {
                assignment.rubric.criteria.map((criterium: ICriteria, index) => {
                  const criteriumId = criterium.id;
                  return (
                    <AnimatedAreaSeries
                      xAccessor={d => {
                        //console.log('submitted', d.submitted);
                        //return d.submitted;
                        return DateTime.fromISO(d.submitted).setZone(Settings.timezone).toLocaleString(DateTime.DATETIME_SHORT);
                      }}
                      yAccessor={(d: IRubricRowFeedback) => {
                        //console.log('score', d.feedbacks[criteriumId].score);
                        return d.feedbacks[criteriumId].score;
                      }}
                      key={criteriumId.toString()}
                      dataKey={(d: IRubricRowFeedback) => {
                        console.log('d', d);
                        return d.id;
                      }}
                      data={progressData}
                      colorAccessor={d => {
                        console.log('color', d, colorScale(criterium.id));
                        return colorScale(criterium.id)
                      }
                      }
                    />

                  )
                })
              }
            </AnimatedAreaStack>
          </XYChart>
        </TabPanel>
      </TabView>
    );
  }

  return output;
}

export { IAssignment, ISubmissionCondensed, CLEAN_ASSIGNMENT };
