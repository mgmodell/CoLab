import React, { useState, useEffect } from "react";
import { DateTime, Settings } from "luxon";

//Redux store stuff
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { IAssignment } from "./AssignmentViewer";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

import { useTranslation } from "react-i18next";

import { Button } from "primereact/button";
import { Editor } from "primereact/editor";
import { InputText } from "primereact/inputtext";

import SubmissionList from "./SubmissionList";
import EditorToolbar from "../toolbars/EditorToolbar";
import { Col, Container, Row } from "react-grid-system";

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
  const [t, i18n] = useTranslation(`${category}s`);
  const [dirty, setDirty] = useState(false);

  const [submissionId, setSubmissionId] = useState<string>();
  const [updatedDate, setUpdatedDate] = useState<DateTime | null>(null);
  const [submittedDate, setSubmittedDate] = useState<DateTime | null>(null);
  const [withdrawnDate, setWithdrawnDate] = useState<DateTime | null>(null);
  const [recordedScore, setRecordedScore] = useState(0);
  const [submissionTextEditor, setSubmissionTextEditor] = useState("");
  const [submissionLink, setSubmissionLink] = useState("");
  const notSubmitted = submittedDate === null;

  useEffect(() => {
    if (endpointStatus) {
      loadSubmission();
    }
  }, [endpointStatus, submissionId]);

  const loadSubmission = () => {
    const url = `${endpoints.submissionUrl}${submissionId}.json`;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;

        let receivedDate = DateTime.fromISO(data.submission.updated_at).setZone(
          Settings.timezone
        );
        setUpdatedDate(receivedDate);
        if (null !== data.submission.submitted) {
          receivedDate = DateTime.fromISO(data.submission.submitted).setZone(
            Settings.timezone
          );
          setSubmittedDate(receivedDate);
        } else {
          setSubmittedDate(null);
        }

        if (null !== data.submission.withdrawn) {
          receivedDate = DateTime.fromISO(data.submission.withdrawn).setZone(
            Settings.timezone
          );
          setWithdrawnDate(receivedDate);
        } else {
          setWithdrawnDate(null);
        }
        setRecordedScore(
          data.submission.recorded_score || data.submission.calculated_score
        );
        setSubmissionTextEditor(data.submission.sub_text || "");
      })
      .then(response => {
        setDirty(false);
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      setDirty(true);
    }
  }, [submissionTextEditor, submissionLink]);

  const sub_text = props.assignment.textSub ? (
    <Row>
      <Col xs={12}>
        <Editor
          id="description"
          placeholder={t("submissions.sub_text_placeholder")}
          aria-label={t("submissions.sub_text_placeholder")}
          readOnly={!notSubmitted}
          value={submissionTextEditor}
          headerTemplate={
            <EditorToolbar />
          }
          onTextChange={e => {
            setSubmissionTextEditor(e.htmlValue);
          }}
        />
      </Col>
    </Row>
  ) : null;

  const subLink = props.assignment.linkSub ? (
    <Row>
      <Col xs={3}>
        <h6>{t("submissions.sub_link_lbl")}</h6>
      </Col>
      <Col xs={3}>
        <span className="p-float-label">
          <InputText
            value={submissionLink}
            id="sub_link"
            disabled={!notSubmitted}
            placeholder={t("submissions.sub_link_placehldr")}
            onChange={event => {
              setSubmissionLink(event.target.value);
            }}
          />
          <label htmlFor="sub_link">{t("submissions.sub_link_lbl")}</label>
        </span>
      </Col>
    </Row>
  ) : null;

  const saveSubmission = (submitIt: boolean) => {
    dispatch(startTask("saving"));
    const url = `${endpoints.submissionUrl}${
      // If this is brand new, we have no ID and need a new one
      // If this has already been submitted, then we must create a new submission
      submissionId === null || submittedDate !== null ? "new" : submissionId
      }.json`;
    const method = null === submissionId ? "PUT" : "PATCH";

    axios({
      url: url,
      method: method,
      data: {
        submission: {
          sub_text: submissionTextEditor,
          sub_link: submissionLink,
          assignment_id: props.assignment.id
        },
        submit: submitIt
      }
    })
      .then(response => {
        const data = response.data;
        if (data.messages !== null && Object.keys(data.messages).length < 2) {
          setSubmissionId(data.submission.id);
          let receivedDate = DateTime.fromISO(
            data.submission.updated_at
          ).setZone(Settings.timezone);
          setUpdatedDate(receivedDate);
          if (data.submission.submitted !== null) {
            receivedDate = DateTime.fromISO(data.submission.submitted).setZone(
              Settings.timezone
            );
            setSubmittedDate(receivedDate);
          }
          if (data.submission.withdrawn !== null) {
            receivedDate = DateTime.fromISO(data.submission.withdrawn).setZone(
              Settings.timezone
            );
            setWithdrawnDate(receivedDate);
          }
          setRecordedScore(data.submission.recorded_score);
          setSubmissionTextEditor(data.submission.sub_text);
        }
      })
      .then(props.reloadCallback)
      .finally(() => {
        dispatch(endTask("saving"));
      });
  };

  const withdrawSubmission = () => {
    dispatch(startTask("withdrawing"));

    const url = `${endpoints.submissionWithdrawalUrl}${submissionId}.json`;
    axios
      .get(url)
      .then(response => {
        const data = response.data;
        if (data.messages !== null && Object.keys(data.messages).length < 2) {
          setSubmissionId(data.submission.id);
          let receivedDate = DateTime.fromISO(
            data.submission.updated_at
          ).setZone(Settings.timezone);
          setUpdatedDate(receivedDate);
          if (data.submission.submitted !== null) {
            receivedDate = DateTime.fromISO(data.submission.submitted).setZone(
              Settings.timezone
            );
            setSubmittedDate(receivedDate);
          }
          if (data.submission.withdrawn !== null) {
            receivedDate = DateTime.fromISO(data.submission.withdrawn).setZone(
              Settings.timezone
            );
            setWithdrawnDate(receivedDate);
          }
          setRecordedScore(data.submission.recorded_score);
          setSubmissionTextEditor(data.submission.sub_text || "");
        }
      })
      .then(props.reloadCallback)
      .finally(() => {
        dispatch(endTask("withdrawing"));
      });
  };

  const draftSaveBtn = (
    <Button
      disabled={!dirty || !notSubmitted}
      onClick={() => saveSubmission(false)}
    >
      {t("submissions.draft_revision_btn")}
    </Button>
  );

  const draftSubmitBtn = (
    <Button disabled={!notSubmitted} onClick={() => saveSubmission(true)}>
      {t("submissions.submit_revision_btn")}
    </Button>
  );

  const revCopyBtn = !notSubmitted ? (
    <Button
      disabled={!dirty || notSubmitted}
      onClick={() => saveSubmission(false)}
    >
      {t("submissions.copy_submission_btn")}
    </Button>
  ) : null;

  const withdrawBtn = !notSubmitted ? (
    <Button
      disabled={
        notSubmitted || null !== withdrawnDate || null !== recordedScore
      }
      onClick={() => withdrawSubmission()}
    >
      {t("submissions.withdraw_btn")}
    </Button>
  ) : null;

  return (
    <Container>
      <Row>
        <Col xs={12}>
          <h6>
            {undefined === submissionId || 0 === parseInt( submissionId )
              ? t("submissions.new_header")
              : t("submissions.edit_header")}
          </h6>
        </Col>
      </Row>
      {sub_text}
      {subLink}
      {draftSaveBtn}
      {draftSubmitBtn}
      {revCopyBtn}
      {withdrawBtn}
      <Row>
        <Col xs={12}>
          <h6>{t("submissions.past_header")}</h6>
        </Col>
      </Row>
      <Row>
        <Col xs={12}>
          <SubmissionList
            submissions={props.assignment.submissions}
            selectSubmissionFunc={setSubmissionId}
          />
        </Col>
      </Row>
    </Container>
  );
}
