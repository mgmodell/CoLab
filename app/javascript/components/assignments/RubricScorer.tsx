import React, { Suspense, useState, useEffect, Dispatch } from "react";
import { useParams } from "react-router-dom";

//Redux store stuff

import { useTypedSelector } from "../infrastructure/AppReducers";
import parse from 'html-react-parser';
import { useDispatch } from "react-redux";
import {
  startTask,endTask,
  addMessage, Priorities
} from "../infrastructure/StatusSlice";

import { Editor } from "primereact/editor";

import { useTranslation } from "react-i18next";
import { Button, Checkbox, FormControlLabel, Slider, TextField, Typography } from "@mui/material";
import { IRubricData, ICriteria } from "./RubricViewer";
import Grid from "@mui/system/Unstable_Grid/Grid";
import { ISubmissionData, SubmissionActions } from "./CritiqueShell";
import { number } from "prop-types";
import axios from "axios";

type Props = {
  submission: ISubmissionData;
  submissionReducer: Dispatch<{}>;

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
  feedback: string;
  rubric_row_feedbacks: Array<IRubricRowFeedback>;
}

export default function RubricScorer(props: Props) {
  const category = "critique";
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const endpoints = useTypedSelector( 
    state => state.context.endpoints[category]
  );
  const dispatch = useDispatch( );

  const [overrideScore, setOverrideScore] = useState( false );
  const [overriddenScore, setOverriddenScore] = useState <number | null >( null );
  const handleOverRideScoreChange = (event: React.ChangeEvent<HTMLInputElement>) =>{
    const newOverrideSetting = !overrideScore;
    if( newOverrideSetting ){
      setOverriddenScore( calcScore( ) );
    } else {
      setOverriddenScore( null );
    }

    setOverrideScore( newOverrideSetting );
  }

  const [t, i18n] = useTranslation( `${category}s` );

  const calcScore = () =>{
    const weightScore = props.submission.submission_feedback.rubric_row_feedbacks.reduce(
      (acc, rubricRowFeedack) =>{
        const weight = props.submission.rubric.criteria.find( (criterium) => criterium.id === rubricRowFeedack.criterium_id).weight;
        const score = weight * rubricRowFeedack.score;

        acc[0] += weight;
        acc[1] += score;

        return acc;
      }, [0,0]
    )
    return Math.round( weightScore[1] / weightScore[0]);
  }

  const saveSubmissionFeedback = ()=>{
    dispatch(startTask());
    const url = `${endpoints.updateUrl}${
      null === props.submission.submission_feedback.id ? 'new' : 
      props.submission.submission_feedback.id}.json`;
    const method = null === props.submission.submission_feedback.id ? 'PUT' : 'PATCH';

    const toSend : ISubmissionFeedback = Object.assign( {}, props.submission.submission_feedback);
    toSend['rubric_row_feedbacks_attributes'] = toSend.rubric_row_feedbacks;
    delete toSend.rubric_row_feedbacks;
    
    axios({
      url: url,
      method: method,
      data: {
        submission_feedback: toSend,
        override_score: overrideScore ? overriddenScore : null
      }
    })
      .then(response =>{
        const data = response.data;
        const messages = data["messages"];

        if (messages != null && Object.keys(messages).length < 2) {
          const r_sub_fdbk : ISubmissionFeedback = data.submission_feedback;
          
          props.submissionReducer({
            type: SubmissionActions.set_submission_feedback_full,
            submission_feedback: r_sub_fdbk,
          })
          dispatch(addMessage(messages.main, new Date(), Priorities.INFO));
        } else {
          Object.values( messages ).forEach( (message)=>{
            dispatch(addMessage(message, new Date(), Priorities.ERROR));

          })
        }

      })
      .finally(()=>{
        dispatch(endTask());
      })


  }

  const saveBtn = (
    <Button
      id='save_feedback'
      onClick={() => {
        saveSubmissionFeedback();
      }
    }
    >
      {t("save_btn")}
    </Button>
  );


  const evaluation = props.submission?.rubric !== undefined ? (
    <Grid container columns={80}>
            <Grid xs={15}>
              <Typography variant="h6">{t('rubric.name' )}:</Typography>
            </Grid>
            <Grid xs={25}>
              <Typography>
                {props.submission.rubric.name}
              </Typography>
            </Grid>
            <Grid xs={15}>
              <Typography variant="h6">{t('rubric.version' )}:</Typography>
            </Grid>
            <Grid xs={25}>
              <Typography>
                {props.submission.rubric.version}
              </Typography>
            </Grid>
            <Grid xs={15}>
              <Typography variant="h6">{t('feedback' )}:</Typography>
            </Grid>
            <Grid xs={55}>
              <Editor
                id='overall-feedback'
                placeholder={t('feedback')}
                aria-label={t('feedback')}
                value={props.submission.submission_feedback.feedback}
                onTextChange={(e)=>{
                      props.submissionReducer({
                        type: SubmissionActions.set_feedback_overall,
                        submission_feedback: e.htmlValue,
                      })

                }}
              />
            </Grid>
            <Grid xs={55}>
              <Typography variant="h6">
              {t('calculated_score_lbl')}:
                </Typography>
              <Typography >
              {calcScore()}
                </Typography>
              <FormControlLabel
                control={<Checkbox />}
                onChange={handleOverRideScoreChange}
                value={overrideScore}
                label={t('override_option_lbl')} />

              {overrideScore ? (
                <TextField id='override-score' label={t('override_score_lbl')}
                  type='number'
                  value={overriddenScore} onChange={
                    (event: React.ChangeEvent<HTMLInputElement>) => {
                      setOverriddenScore(event.target.value);
                    }
                  } />
              ): null }
            </Grid>
            {props.submission.rubric.criteria.sort( (a:ICriteria, b:ICriteria) => a.sequence - b.sequence ).map( (criterium) =>{
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
                const score = Math.round( 100 / levels.length * index );
                renderedLevels.push( 
                    <Grid
                      key={`${criterium.id}-${index}`}
                      id={`level-${criterium.id}-${index}`}
                      xs={span}
                      color={()=>{
                        const rubricRowFeedback = props.submission.submission_feedback.rubric_row_feedbacks.find(
                          (rubricRowFeedback)=>{
                            return criterium.id === rubricRowFeedback.criterium_id;
                          }
                        )
                        if( rubricRowFeedback.score >= score ){
                          return 'green';
                        }
                      }}
                      onClick={()=>{

                        props.submissionReducer({
                          type: SubmissionActions.set_criteria_score,
                          score: score,
                          criterium_id: criterium.id,
                        })
                      }}
                      >
                      {parse( levelText) }
                    </Grid>
                );
              })
              
              return(
                <React.Fragment key={criterium.id}>
                  <Grid xs={80}><hr></hr></Grid>
                  <Grid xs={10 + span}>
                    &nbsp;
                  </Grid>
                  <Grid
                    id={`slider-${criterium.id}`}
                    xs={60 - span}>
                    <Slider
                      defaultValue={0}
                      max={100}
                      min={0}
                      value={props.submission.submission_feedback.rubric_row_feedbacks.find(feedback=> feedback.criterium_id == criterium.id ).score}
                      onChange={( event )=>{
                        props.submissionReducer({
                          type: SubmissionActions.set_criteria_score,
                          score: event.target.value,
                          criterium_id: criterium.id,
                        })
                      }
                      }
                    />

                  </Grid>
                  <Grid xs={10}>
                    <TextField
                      id={`score-${criterium.id}`}
                      value={props.submission.submission_feedback.rubric_row_feedbacks.find(feedback=> feedback.criterium_id == criterium.id ).score}
                      type='number'
                      size={'small'}
                      variant={'standard'}
                      onChange={(event: React.ChangeEvent<HTMLInputElement>)=>{
                        props.submissionReducer({
                          type: SubmissionActions.set_criteria_score,
                          score: event.target.value,
                          criterium_id: criterium.id,
                        })
                      }}
                    />
                  </Grid>
                  <Grid
                      id={`description-${criterium.id}`}
                      xs={10}>
                    <b>
                      { criterium.description}
                    </b>
                  </Grid>
                  <Grid xs={span}
                      id={`minimum-${criterium.id}`}
                      onClick={()=>{

                        props.submissionReducer({
                          type: SubmissionActions.set_criteria_score,
                          score: 0,
                          criterium_id: criterium.id,
                        })
                      }
                    }
                        >
                    {t('rubric.minimum')}
                  </Grid>
                  { renderedLevels }
                  <Grid 
                      xs={10}>
                <Editor
                  id={`feedback-${criterium.id}`}
                  placeholder={t("rubric.criteria_feedback")}
                  aria-label={t("rubric.criteria_feedback")}
                  value={props.submission.submission_feedback.rubric_row_feedbacks.find(feedback=> feedback.criterium_id == criterium.id ).feedback}
                  onTextChange={(e)=>{
                      props.submissionReducer({
                        type: SubmissionActions.set_criteria_feedback,
                        criterium_feedback: e.htmlValue,
                        criterium_id: criterium.id,
                      })
                      
                  }}
                />
                  </Grid>
                </React.Fragment>
              )
            })}

      <Grid xs={80}><hr></hr></Grid>
      <Grid xs={80}>
        {saveBtn}
      </Grid>
    </Grid>
  ) : null;

  return evaluation;
}

export { ISubmissionFeedback, IRubricRowFeedback };