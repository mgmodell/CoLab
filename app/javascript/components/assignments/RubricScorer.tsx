import React, { useState, Dispatch } from "react";
import axios from "axios";

//Redux store stuff
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useDispatch } from "react-redux";
import {
  startTask,endTask,
  addMessage, Priorities
} from "../infrastructure/StatusSlice";

import { Editor } from "primereact/editor";
import parse from 'html-react-parser';

import { useTranslation } from "react-i18next";
import { ICriteria } from "./RubricViewer";
import { ISubmissionData, SubmissionActions } from "./CritiqueShell";

import { Col, Container, Row } from "react-grid-system";
import { Slider } from "primereact/slider";
import { Button } from "primereact/button";
import { Checkbox } from "primereact/checkbox";
import { InputNumber, InputNumberChangeEvent } from "primereact/inputnumber";
import EditorToolbar from "../toolbars/EditorToolbar";

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
  const handleOverRideScoreChange = () =>{
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
        dispatch(endTask({}));
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
    <Container fluid>
      <Row>
        <Col xs={4}>
          <b>{t('rubric.name' )}:</b>
        </Col>
        <Col xs={8}>
          <p>
            {props.submission.rubric.name}
          </p>
        </Col>
        </Row>

      <Row>
        <Col xs={4}>
          <b>{t('rubric.version' )}:</b>
        </Col>
        <Col xs={8}>
          <p>
            {props.submission.rubric.version}
          </p>
        </Col>
      </Row>
      <Row>
        <Col xs={4}>
          <b>{t('feedback' )}:</b>
        </Col>
        <Col xs={8}>
          <Editor
            id='overall-feedback'
            placeholder={t('feedback')}
            headerTemplate={ <EditorToolbar /> }
            aria-label={t('feedback')}
            value={props.submission.submission_feedback.feedback}
            onTextChange={(e)=>{
                  props.submissionReducer({
                    type: SubmissionActions.set_feedback_overall,
                    submission_feedback: e.htmlValue,
                  })

            }}
          />
        </Col>
      </Row>
      <Row>
        <Col xs={4}>
          <b>{t('calculated_score_lbl')}:</b>
        </Col>
        <Col xs={4}>
          <p>
          {calcScore()} &nbsp;
          </p>
          </Col>
          <Col xs={4}>
          <p>
          <Checkbox
            onChange={handleOverRideScoreChange}
            checked={overrideScore}
            inputId="score_override_chk"
            />
            <label htmlFor='score_override_chk'>{t('override_option_lbl')}</label>
            {overrideScore ? (
              <InputNumber
                inputId='override-score'
                value={overriddenScore}
                onChange={
                  (event : InputNumberChangeEvent) => {
                    setOverriddenScore(event.value);
                  }
                } />
            ) : null}
          </p>
        </Col>
      </Row>
            <table>
              <tbody>


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
                const rubricRowFeedback = props.submission.submission_feedback.rubric_row_feedbacks.find(
                  (rubricRowFeedback)=>{
                    return criterium.id === rubricRowFeedback.criterium_id;
                  }
                );
                let color = '';
                if( rubricRowFeedback.score >= score ){
                  color = 'green';
                }
                renderedLevels.push( 
                    <td
                      key={`${criterium.id}-${index}`}
                      id={`level-${criterium.id}-${index}`}
                      colSpan={span}
                      color={ color }
                      onClick={()=>{

                        props.submissionReducer({
                          type: SubmissionActions.set_criteria_score,
                          score: score,
                          criterium_id: criterium.id,
                        })
                      }}
                      >
                      {parse( levelText) }
                    </td>
                );
              })
              
              return(
                <React.Fragment key={criterium.id}>
                  <tr>
                    <td colSpan={80}><hr /></td>
                    </tr>
                  <tr>

                  <td colSpan={10 + span}>
                    &nbsp;
                  </td>
                  <td
                    id={`slider-${criterium.id}`}
                    colSpan={60 - span}>
                    <Slider
                      defaultValue={0}
                      max={100}
                      min={0}
                      value={props.submission.submission_feedback.rubric_row_feedbacks.find(feedback=> feedback.criterium_id == criterium.id ).score}
                      onChange={( event )=>{
                        props.submissionReducer({
                          type: SubmissionActions.set_criteria_score,
                          score: event.value,
                          criterium_id: criterium.id,
                        })
                      }
                      }
                    />

                  </td>
                  <td colSpan={10}>
                    <InputNumber
                      inputId={`score-${criterium.id}`}
                      value={props.submission.submission_feedback.rubric_row_feedbacks.find(feedback=> feedback.criterium_id == criterium.id ).score}
                      onChange={(event: InputNumberChangeEvent)=>{
                        props.submissionReducer({
                          type: SubmissionActions.set_criteria_score,
                          score: event.value,
                          criterium_id: criterium.id,
                        })
                      }}
                    />
                  </td>
                  </tr>
                  <tr>
                  <td
                      id={`description-${criterium.id}`}
                      colSpan={10}>
                    <b>
                      { criterium.description}
                    </b>
                  </td>
                  <td colSpan={span}
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
                  </td>
                  { renderedLevels }
                  <td 
                      colSpan={10}>
                <Editor
                  id={`feedback-${criterium.id}`}
                  placeholder={t("rubric.criteria_feedback")}
                  aria-label={t("rubric.criteria_feedback")}
                  headerTemplate={ <EditorToolbar /> }
                  value={props.submission.submission_feedback.rubric_row_feedbacks.find(feedback=> feedback.criterium_id == criterium.id ).feedback}
                  onTextChange={(e)=>{
                      props.submissionReducer({
                        type: SubmissionActions.set_criteria_feedback,
                        criterium_feedback: e.htmlValue,
                        criterium_id: criterium.id,
                      })
                      
                  }}
                />
                  </td>
                  </tr>
                </React.Fragment>
              )
            })}
              </tbody>
            </table>

      <Row>
        <Col xs={12}>
          <hr />
        </Col>
      </Row>
      <Row >
        <Col xs={12}>
        {saveBtn}
        </Col>
      </Row>
    </Container>
  ) : null;

  return evaluation;
}

export { ISubmissionFeedback, IRubricRowFeedback };