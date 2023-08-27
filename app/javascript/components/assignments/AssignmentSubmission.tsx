import React, { useState, useEffect } from "react";
import {DateTime, Settings} from 'luxon';

//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask} from "../infrastructure/StatusSlice";
import { IAssignment } from "./AssignmentViewer";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

import { useTranslation } from "react-i18next";
import { Button, Grid, TextField, Typography } from "@mui/material";

import { EditorState, convertToRaw, ContentState } from "draft-js";
const Editor = React.lazy(() => import("../reactDraftWysiwygEditor"));
import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";
import SubmissionList from "./SubmissionList";


type Props = {
  assignment: IAssignment;
  reloadCallback: () => void;
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
  const [dirty, setDirty] = useState( false );

  const [submissionId, setSubmissionId] = useState <string> (  );
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
  const [ submissionTextEditor, setSubmissionTextEditor ] = useState(
    EditorState.createWithContent(
      ContentState.createFromBlockArray(htmlToDraft("").contentBlocks)
    )
  );
  const [submissionLink, setSubmissionLink] = useState( '' );
  const notSubmitted = submittedDate === null;

  useEffect( () => {
    if( endpointStatus ){
      loadSubmission( );
    }
  }, [endpointStatus, submissionId])


  const loadSubmission = () =>{
    const url = `${endpoints.submissionUrl}${submissionId}.json`;
    axios.get( url, {} )
      .then( response =>{
        const data = response.data;

        let receivedDate = DateTime.fromISO( data.submission.updated_at ).setZone( Settings.timezone );
        setUpdatedDate(receivedDate );
        if( null !== data.submission.submitted  ){
          receivedDate = DateTime.fromISO( data.submission.submitted ).setZone( Settings.timezone );
          setSubmittedDate( receivedDate );
        } else {
          setSubmittedDate( null );
        }
        
        if( null !== data.submission.withdrawn ){
          receivedDate = DateTime.fromISO( data.submission.withdrawn ).setZone( Settings.timezone );
          setWithdrawnDate( receivedDate );
        } else {
          setWithdrawnDate( null );
        }
        setRecordedScore( data.submission.recorded_score );
        setSubmissionTextEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft( data.submission.sub_text || '' ).contentBlocks
            )
          )
        );

      }).then( response =>{
        setDirty( false );
      });

  }

  useEffect( () =>{
    if( endpointStatus){
      setDirty( true );
    }
  }, [submissionTextEditor, submissionLink])


  const sub_text = props.assignment.textSub ? (
    <Grid item xs={12}>
                  <Editor
                    wrapperId="Description"
                    label={t("submissions.sub_text_lbl")}
                    placeholder={t("submissions.sub_text_placeholder")}
                    onEditorStateChange={setSubmissionTextEditor}
                    toolbarOnFocus
                    readOnly={!notSubmitted}
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

  const subLink = props.assignment.linkSub ? (
    <React.Fragment>
      <Grid item xs={3}>
        <Typography variant="h6">{t('submissions.sub_link_lbl')}</Typography>
      </Grid>
      <Grid item xs={3}>
        <TextField value={submissionLink}
          id="sub_link"
          disabled={!notSubmitted}
          placeholder={t('submissions.sub_link_placehldr')}
          onChange={(event)=>{
            setSubmissionLink( event.target.value );
          }} />

      </Grid>
    </React.Fragment>
  ) : null;

  const saveSubmission = (submitIt:boolean) => {
    dispatch( startTask( 'saving' ) );
    const url = `${endpoints.submissionUrl}${
      // If this is brand new, we have no ID and need a new one
      // If this has already been submitted, then we must create a new submission
      submissionId === null || submittedDate !== null ? 'new' : submissionId
     }.json`;
    const method = null == submissionId ? 'PUT' : 'PATCH';

    axios({
      url: url,
      method: method,
      data: {
        submission: {
          sub_text: draftToHtml(
            convertToRaw( submissionTextEditor.getCurrentContent( ) )
          ),
          sub_link: submissionLink,
          assignment_id: props.assignment.id,
        },
        submit: submitIt,
      }
    }).then( response => {
      const data = response.data;
      if( data.messages !== null && Object.keys( data.messages ).length < 2 ){
        setSubmissionId( data.submission.id );
        let receivedDate = DateTime.fromISO( data.submission.updated_at ).setZone( Settings.timezone );
        setUpdatedDate(receivedDate );
        if( data.submission.submitted !== null ){
          receivedDate = DateTime.fromISO( data.submission.submitted ).setZone( Settings.timezone );
          setSubmittedDate( receivedDate );
        }
        if( data.submission.withdrawn !== null ){
          receivedDate = DateTime.fromISO( data.submission.withdrawn ).setZone( Settings.timezone );
          setWithdrawnDate( receivedDate );
        }
        setRecordedScore( data.submission.recorded_score );
        setSubmissionTextEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft( data.submission.sub_text || '' ).contentBlocks
            )
          )
        );

      }
    }).then( props.reloadCallback ).finally(()=>{
      dispatch( endTask( 'saving' ));
    }

    );

  };

  const withdrawSubmission = () => {
    dispatch( startTask( 'withdrawing' ) );

    const url = `${endpoints.submissionWithdrawalUrl}${ submissionId }.json`;
    axios.get(url).then( response => {
      const data = response.data;
      console.log( 'data', data );
      if( data.messages !== null && Object.keys( data.messages ).length < 2 ){
        setSubmissionId( data.submission.id );
        let receivedDate = DateTime.fromISO( data.submission.updated_at ).setZone( Settings.timezone );
        setUpdatedDate(receivedDate );
        if( data.submission.submitted !== null ){
          receivedDate = DateTime.fromISO( data.submission.submitted ).setZone( Settings.timezone );
          setSubmittedDate( receivedDate );
        }
        if( data.submission.withdrawn !== null ){
          receivedDate = DateTime.fromISO( data.submission.withdrawn ).setZone( Settings.timezone );
          setWithdrawnDate( receivedDate );
        }
        setRecordedScore( data.submission.recorded_score );
        setSubmissionTextEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft( data.submission.sub_text || '' ).contentBlocks
            )
          )
        );

      }

    }).then( props.reloadCallback ).finally(()=>{
      dispatch( endTask( 'withdrawing' ));
    });

  }

  const draftSaveBtn = (
    <Button disabled={!dirty || !notSubmitted} onClick={()=>saveSubmission( false )}>
      { t('submissions.draft_revision_btn')}
    </Button>
  );

  const draftSubmitBtn =  (
    <Button disabled={!dirty || !notSubmitted} onClick={()=>saveSubmission( true )}>
      { t('submissions.submit_revision_btn')}
    </Button>
  );

  const revCopyBtn = ! notSubmitted ? (
    <Button disabled={!dirty || notSubmitted} onClick={()=>saveSubmission( false )}>
      { t('submissions.copy_submission_btn')}
    </Button>
  ) : null;

  const withdrawBtn = ! notSubmitted ? (
    <Button disabled={ notSubmitted || (null !== withdrawnDate)} onClick={()=>withdrawSubmission( )}>
      { t('submissions.withdraw_btn')}
    </Button>
  ) : null;

  return (
    <Grid container >
      <Grid item xs={12}>
        <Typography variant="h6" >
          {undefined === submissionId || 0 === submissionId ?
             t('submissions.new_header') :
             t('submissions.edit_header')}
        </Typography>
      </Grid>
      {sub_text}
      {subLink}
      {draftSaveBtn}{draftSubmitBtn}{revCopyBtn}{withdrawBtn}

      <Grid item xs={12}>
        <Typography variant="h6" >
          {t('submissions.past_header')}
        </Typography>
      </Grid>
      <Grid item xs={12}>
        <SubmissionList
            submissions={props.assignment.submissions }
            selectSubmissionFunc={setSubmissionId}
        />
      </Grid>

    </Grid>
  );
}
