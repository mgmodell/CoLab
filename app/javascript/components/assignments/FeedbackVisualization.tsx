import React, { useState, useEffect, Fragment } from 'react';
import {
    AnimatedAreaSeries,
    AnimatedAreaStack,
    AnimatedAxis,
    AnimatedGrid,
    AnimatedLineSeries,
    Tooltip,
    XYChart
} from "@visx/xychart";
import { scaleOrdinal } from '@visx/scale';
// import { schemeSet1 as colorScheme } from 'd3-scale-chromatic';
import { interpolateTurbo as colorScheme } from 'd3-scale-chromatic';

import parse from "html-react-parser";
import { ICriteria } from './RubricViewer';
import { DateTime, Settings } from "luxon";
import { IAssignment, IRubricRowFeedback, ISubmissionCondensed } from './AssignmentViewer';
import { Dropdown } from 'primereact/dropdown';
import { useTranslation } from 'react-i18next';

type Props = {
    assignment: IAssignment
}

const enum CHART_TYPES {
    STACKED_AREA = 'stacked_area',
    LAYERED_AREA = 'layered_area',
    LINES = 'lines',
}

export default function FeedbackVisualization(props: Props) {
    const endpointSet = "assignment";
    const [t, i18n] = useTranslation(`${endpointSet}s`);
    const [progressData, setProgressData] = useState([]);
    const [chartType, setChartType] = useState(CHART_TYPES.STACKED_AREA);

    const maxId = props.assignment.rubric.criteria.reduce((
        (maximum, next) => {
            return Math.max(maximum, next.id);
        }
    ), 0);
    const minId = props.assignment.rubric.criteria.reduce((
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
        range: colorScheme,
    });

    useEffect(() => {
        const localProgressData = props.assignment.submissions.map((submission: ISubmissionCondensed) => {
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
    }, [props.assignment.submissions]);

    return (
        <>
            <Dropdown value={chartType} options={
                [

                    {
                        label: t(`visualization.${CHART_TYPES.STACKED_AREA}`),
                        value: CHART_TYPES.STACKED_AREA,
                    },
                    {
                        label: t(`visualization.${CHART_TYPES.LAYERED_AREA}`),
                        value: CHART_TYPES.LAYERED_AREA,
                    },
                    {
                        label: t(`visualization.${CHART_TYPES.LINES}`),
                        value: CHART_TYPES.LINES,
                    },
                ]
            }
                id='chartType'
                optionLabel='label'
                onChange={(e) => { setChartType(e.value) }}
            />
            <br />

            <XYChart
                xScale={{ type: "band" }}
                yScale={{ type: "linear" }}
                width={500}
                height={300}
            >
                <AnimatedAxis
                    axisClassName='x-axis'
                    orientation='bottom'
                    tickClassName='x-tick'
                />
                <AnimatedAxis
                    axisClassName='y-axis'
                    orientation='left'
                    label='Score'
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
                                <Fragment key={feedback.id}>
                                    <li><strong>
                                        {feedback.score}:
                                    </strong>
                                        {parse(feedback.feedback)} </li>
                                </Fragment>
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

                {
                    chartType === CHART_TYPES.LINES ?

                        props.assignment.rubric.criteria.map((criterium: ICriteria, index) => {
                            const criteriumId = criterium.id;
                            return (
                                <AnimatedLineSeries
                                    xAccessor={d => {
                                        return DateTime.fromISO(d.submitted).setZone(Settings.timezone).toLocaleString(DateTime.DATETIME_SHORT);
                                    }}
                                    yAccessor={(d: IRubricRowFeedback) => {
                                        return d.feedbacks[criteriumId].score;
                                    }}
                                    key={criteriumId.toString()}
                                    name={`criterium-${criteriumId}`}
                                    opacity={0.4}
                                    dataKey={criteriumId.toString()}
                                    data={progressData}

                                    color={colorScale(criterium.id)}
                                />

                            )
                        })
                        : null}
                {
                    chartType === CHART_TYPES.LAYERED_AREA ?
                        <AnimatedAreaStack>
                            {

                                props.assignment.rubric.criteria.map((criterium: ICriteria, index) => {
                                    const criteriumId = criterium.id;
                                    return (
                                        <AnimatedAreaSeries
                                            xAccessor={d => {
                                                return DateTime.fromISO(d.submitted).setZone(Settings.timezone).toLocaleString(DateTime.DATETIME_SHORT);
                                            }}
                                            yAccessor={(d: IRubricRowFeedback) => {
                                                return d.feedbacks[criteriumId].score;
                                            }}
                                            key={criteriumId.toString()}
                                            name={`criterium-${criteriumId}`}
                                            opacity={0.4}
                                            dataKey={criteriumId.toString()}
                                            data={progressData}
                                            color={colorScale(criterium.id)}
                                        />

                                    )
                                })
                            }
                        </AnimatedAreaStack>
                        : null}
                {
                    chartType === CHART_TYPES.STACKED_AREA ? (
                        <AnimatedAreaStack >
                            {
                                props.assignment.rubric.criteria.map((criterium: ICriteria, index) => {
                                    const criteriumId = criterium.id;
                                    return (
                                        <AnimatedAreaSeries
                                            xAccessor={d => {
                                                return DateTime.fromISO(d.submitted).setZone(Settings.timezone).toLocaleString(DateTime.DATETIME_SHORT);
                                            }}
                                            yAccessor={(d: IRubricRowFeedback) => {
                                                return d.feedbacks[criteriumId].score;
                                            }}
                                            key={criteriumId.toString()}
                                            name={`criterium-${criteriumId}`}
                                            dataKey={criteriumId.toString()}

                                            data={progressData}
                                            color={colorScale(criterium.id)}
                                        />

                                    )
                                })
                            }
                        </AnimatedAreaStack>
                    ) : null}
            </XYChart>
        </>
    )
}