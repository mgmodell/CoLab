import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import {DateTime, Settings} from 'luxon';

//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setClean,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";
import { IAssignment } from "./AssignmentViewer";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import parse from 'html-react-parser';

import { useTranslation } from "react-i18next";
import { Grid, Typography } from "@mui/material";

import { EditorState, convertToRaw, ContentState } from "draft-js";
const Editor = React.lazy(() => import("../reactDraftWysiwygEditor"));
import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";
import SubmissionList from "./SubmissionList";


type Props = {
  assignment: IAssignment;
};

export default function AssignmentSubmission(props: Props) {
  const category = "assignment";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const dispatch = useDispatch();
  const [t, i18n] = useTranslation( `${category}s` );

  const [submissionId, setSubmissionId] = useState(  );
  const [updatedDate, setUpdatedDate] = useState<DateTime|null>(
    null
  );
  const [submittedDate, setSubmittedDate] = useState<DateTime|null>(
    null
  );
  const [withdrawnDate, setWithdrawnDate] = useState<DateTime|null>(
    null
  );
  const [recordedScore, setRecordedScore] = useState( 0 );
  const [
    submissionTextEditor,
    setSubmissionTextEditor
  ] = useState(
    EditorState.createWithContent(
      ContentState.createFromBlockArray(htmlToDraft("").contentBlocks)
    )
  );
  
  console.log( props.assignment );

  /*
  useEffect( () =>{
    if( endpointStatus){
    }
  },[endpointStatus])
  */

  const loadSubmission = () =>{
    const url = `${endpoints.submissionUrl}/${submissionId}.json`;
    axios.get( url, {} )
      .then( response =>{
        const data = response.data;
        console.log( response );

        let receivedDate = DateTime.fromISO( data.submission.updated_at ).setZone( Settings.timezone );
        setUpdatedDate(receivedDate );
        receivedDate = DateTime.fromISO( data.submission.submitted ).setZone( Settings.timezone );
        setSubmittedDate( receivedDate );
        receivedDate = DateTime.fromISO( data.submission.withdrawn ).setZone( Settings.timezone );
        setWithdrawnDate( receivedDate );
        setRecordedScore( data.submission.recorded_score );
        setSubmissionTextEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft( data.submission.sub_text || '' ).contentBlocks
            )
          )
        );

      });

  }


  const sub_text = props.assignment.textSub ? (
    <Grid item xs={12}>
                  <Editor
                    wrapperId="Description"
                    label={t("submissions.sub_text_lbl")}
                    placeholder={t("submissions.sub_text_placeholder")}
                    onEditorStateChange={setSubmissionTextEditor}
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
                    editorState={submissionTextEditor}
                  />

    </Grid>
  ) : null;

  const sub_link = props.assignment.linkSub ? (
    <React.Fragment>
      <Grid item xs={3}>
        <Typography variant="h6">{t('submissions.link_lbl')}</Typography>
      </Grid>
      <Grid item xs={3}>

      </Grid>
    </React.Fragment>
  ) : null;

  return (
    <Grid container >
      <Grid item xs={12}>
        <Typography variant="h6" >
          {t('submissions.new_header')}
        </Typography>
      </Grid>
      {sub_text}
      {sub_link}
      <Grid item xs={12}>
        <Typography variant="h6" >
          {t('submissions.past_header')}
        </Typography>
      </Grid>
      <Grid item xs={12}>
        <SubmissionList submissions={props.assignment.submissions } />
      </Grid>

    </Grid>
  );
}
