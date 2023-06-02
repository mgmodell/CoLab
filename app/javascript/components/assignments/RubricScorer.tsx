import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";

//Redux store stuff

import { useTypedSelector } from "../infrastructure/AppReducers";
import parse from 'html-react-parser';

import { EditorState, convertToRaw, ContentState } from "draft-js";
const Editor = React.lazy(() => import("../reactDraftWysiwygEditor"));

import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";

import { useTranslation } from "react-i18next";
import { Typography } from "@mui/material";
import { IRubricData, ICriteria } from "./RubricViewer";
import Grid from "@mui/system/Unstable_Grid/Grid";

type Props = {
  rubric: IRubricData;
  submissionFeedback: ISubmissionFeedback
};

interface IRubricRowFeedback {
  id: number | null;
  submission_feedback_id: number | null;
  criterium_id: number;
  score: number;
  feedback: string;
}
interface ISubmissionFeedback {
  id: number | null;
  submission_id: number;
  calculated_score: number | null;
  feedback: string;
  rubric_row_feedbacks: Array<IRubricRowFeedback>;
}

export default function RubricScorer(props: Props) {
  const endpointSet = "assignment";
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const { assignmentId } = useParams();

  const [t, i18n] = useTranslation( `${endpointSet}s` );

  const evaluation = props.rubric !== undefined ? (
    <Grid container columns={70}>
            <Grid xs={10}>
              <Typography variant="h6">{t('status.rubric_name' )}:</Typography>
            </Grid>
            <Grid xs={20}>
              <Typography>
                {props.rubric.name}
              </Typography>
            </Grid>
            <Grid xs={10}>
              <Typography variant="h6">{t('status.rubric_version' )}:</Typography>
            </Grid>
            <Grid xs={20}>
              <Typography>
                {props.rubric.version}
              </Typography>
            </Grid>
            {props.rubric.criteria.sort( (a:ICriteria, b:ICriteria) => a.sequence - b.sequence ).map( (criterium) =>{
              const levels = [ 
                criterium.l1_description,
                criterium.l2_description,
                criterium.l3_description,
                criterium.l4_description,
                criterium.l5_description
              ];
              for( let index = levels.length - 1; index > 0; index-- ){
                if( levels[ index ] !== null && levels[index].length > 0 ){
                  index = -1;
                } else {
                  levels.pop( );
                }
              }
              const span = 60 / ( levels.length + 1 );
              const renderedLevels = [];
              let index = 0;
              levels.forEach( (levelText) => {
                index++;
                renderedLevels.push( 
                    <Grid key={`${criterium.id}-${index}`} xs={span}>
                      {parse( levelText) }
                    </Grid>
                );
              })
              
              return(
                <React.Fragment key={criterium.id}>
                  <Grid xs={70}><hr></hr></Grid>
                  <Grid xs={10}>
                    { criterium.description}
                  </Grid>
                  <Grid xs={span}>
                    {t('status.rubric_minimum')}
                  </Grid>
                  { renderedLevels }
                </React.Fragment>
              )
            })}

      <Grid xs={70}><hr></hr></Grid>
    </Grid>
  ) : null;

  return evaluation;
}

export { ISubmissionFeedback, IRubricRowFeedback };