import React, { Suspense, useState, useEffect, Dispatch } from "react";
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
import { ISubmissionData, SubmissionActions } from "./CritiqueShell";

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
  calculated_score: number | null;
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

  const [ ed, setEd ] = useState(
    EditorState.createWithContent(
      ContentState.createFromBlockArray(htmlToDraft('').contentBlocks)
    )
  );

  const [t, i18n] = useTranslation( `${category}s` );



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
            <Grid xs={65}>
                  <Editor
                    wrapperId={t('feedback')}
                    label={t("feedback")}
                    placeholder={t("feedback")}
                    editorState={props.submission.submission_feedback.feedback}
                    onEditorStateChange={(editorState, title)=>{
                      props.submissionReducer({
                        type: SubmissionActions.set_feedback_overall,
                        submission_feedback: editorState,
                      })
                    }}
                    toolbarOnFocus
                    toolbar={{
                      options: [
                        "inline",
                        "list",
                        "link",
                        "blockType",
                        "fontSize",
                        "fontFamily"
                      ],
                      inline: {
                        options: [
                          "bold",
                          "italic",
                          "underline",
                          "strikethrough",
                          "monospace"
                        ],
                        bold: { className: "bordered-option-classname" },
                        italic: { className: "bordered-option-classname" },
                        underline: { className: "bordered-option-classname" },
                        strikethrough: {
                          className: "bordered-option-classname"
                        },
                        code: { className: "bordered-option-classname" }
                      },
                      blockType: {
                        className: "bordered-option-classname"
                      },
                      fontSize: {
                        className: "bordered-option-classname"
                      },
                      fontFamily: {
                        className: "bordered-option-classname"
                      }
                    }}
                  />
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
                renderedLevels.push( 
                    <Grid key={`${criterium.id}-${index}`} xs={span}>
                      {parse( levelText) }
                    </Grid>
                );
              })
              
              return(
                <React.Fragment key={criterium.id}>
                  <Grid xs={80}><hr></hr></Grid>
                  <Grid xs={10}>
                    { criterium.description}
                  </Grid>
                  <Grid xs={span}>
                    {t('rubric.minimum')}
                  </Grid>
                  { renderedLevels }
                  <Grid xs={10}>
                  <Editor
                    wrapperId="Description"
                    label={t("rubric.criteria_feedback")}
                    placeholder={t("rubric.criteria_feedback")}
                    toolbarOnFocus
                    toolbar={{
                      options: [
                        "inline",
                        "list",
                        "link",
                        "blockType",
                        "fontSize",
                        "fontFamily"
                      ],
                      inline: {
                        options: [
                          "bold",
                          "italic",
                          "underline",
                          "strikethrough",
                          "monospace"
                        ],
                        bold: { className: "bordered-option-classname" },
                        italic: { className: "bordered-option-classname" },
                        underline: { className: "bordered-option-classname" },
                        strikethrough: {
                          className: "bordered-option-classname"
                        },
                        code: { className: "bordered-option-classname" }
                      },
                      blockType: {
                        className: "bordered-option-classname"
                      },
                      fontSize: {
                        className: "bordered-option-classname"
                      },
                      fontFamily: {
                        className: "bordered-option-classname"
                      }
                    }}
                    editorState={props.submission.submission_feedback.rubric_row_feedbacks.find(feedback=> feedback.criterium_id == criterium.id ).feedback}
                    onEditorStateChange={(editorState, title)=>{
                      props.submissionReducer({
                        type: SubmissionActions.set_criteria_feedback,
                        criterium_feedback: editorState,
                        criterium_id: criterium.id,
                      })
                    }}
                  />
                  </Grid>
                </React.Fragment>
              )
            })}

      <Grid xs={80}><hr></hr></Grid>
    </Grid>
  ) : null;

  return evaluation;
}

export { ISubmissionFeedback, IRubricRowFeedback };