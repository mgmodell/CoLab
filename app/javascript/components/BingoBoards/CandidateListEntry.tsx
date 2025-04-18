import React, { useState, useEffect } from "react";
import { useParams } from "react-router";

import { Panel } from "primereact/panel";
import { Button } from "primereact/button";

import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import parse from "html-react-parser";
import { removeStopwords } from 'stopword'
import { InputTextarea } from "primereact/inputtextarea";
import { InputText } from "primereact/inputtext";
import { Col, Container, Row } from "react-grid-system";
import { FloatLabel } from "primereact/floatlabel";

type Props = {
  rootPath?: string;
};

export default function CandidateListEntry(props: Props) {
  const category = "candidate_list";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const { t, i18n } = useTranslation(`${category}s`);

  const { bingoGameId } = useParams();

  const [dirty, setDirty] = useState(false);
  const dispatch = useDispatch();

  const [candidateListId, setCandidateListId] = useState(0);
  const [topic, setTopic] = useState("");
  const [description, setDescription] = useState("");
  const [groupOption, setGroupOption] = useState(false);
  const [endDate, setEndDate] = useState(new Date());
  const [groupName, setGroupName] = useState("");
  const [isGroup, setIsGroup] = useState(false);
  const [expectedCount, setExpectedCount] = useState(0);
  const [candidates, setCandidates] = useState([]);
  const [candidateCountHash, setCandidateCountHash] = useState({});
  const [othersRequestedHelp, setOthersRequestedHelp] = useState(0);
  const [helpRequested, setHelpRequested] = useState(false);
  const [requestCollaborationUrl, setRequestCollaborationUrl] = useState("");

  const getCandidateList = () => {
    dispatch(startTask());
    setDirty(true);
    const url =
      props.rootPath === undefined
        ? `${endpoints.baseUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.baseUrl}${bingoGameId}.json`;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setCandidateListId(data.id);
        setTopic(data.topic);
        setDescription(data.description);
        setGroupOption(data.group_option);
        setEndDate(new Date(data.end_date));
        setGroupName(data.group_name);
        setIsGroup(data.is_group);
        setExpectedCount(data.expected_count);

        setCandidates(prepCandidates(data.candidates, data.expected_count));
        setOthersRequestedHelp(data.others_requested_help);
        setHelpRequested(data.help_requested);
        setRequestCollaborationUrl(data.request_collaboration_url);

        dispatch(endTask());
        setDirty(false);
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  useEffect(() => {
    const tmpCandidates = [...candidates];
    const countHash = {};
    for (var i = 0; i < tmpCandidates.length; i++) {
      const cleaned = removeStopwords( tmpCandidates[i].term.toLowerCase().split(" ") ).join(" ");
      if (countHash[cleaned] === undefined) {
        countHash[cleaned] = 1;
      } else {
        countHash[cleaned]++;
      }
    }
    setCandidateCountHash(countHash);
  }, [candidates]);

  const prepCandidates = (candidates, expectedCount) => {
    const tmpCandidates = [...candidates];
    const candidate_count = candidates.length;
    tmpCandidates.sort((a, b) => {
      if (0 == b.term.length) {
        return -1;
      } else if (0 == a.term.length) {
        return 1;
      } else {
        return a.term.localeCompare(b.term);
      }
    });


    for (var count = candidate_count; count < expectedCount; count++) {
      tmpCandidates.push({
        id: null,
        term: "",
        definition: "",
        filtered_consistent: "",
        candidate_feedback_id: null,
      });
    }
    return tmpCandidates;
  };

  const saveCandidateList = () => {
    dispatch(startTask("saving"));

    const url =
      props.rootPath === undefined
        ? `${endpoints.baseUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.baseUrl}${bingoGameId}.json`;

    axios
      .put(url, {
        candidates: candidates.filter(item => {
          return !(
            null === item.id &&
            "" === item.term &&
            "" === item.definition
          );
        })
      })
      .then(response => {
        const data = response.data;
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          setCandidateListId(data.id);
          setIsGroup(data.is_group);
          setExpectedCount(data.expected_count);

          setCandidates(prepCandidates(data.candidates, data.expected_count));
          setHelpRequested(data.help_requested);
          setOthersRequestedHelp(data.others_requested_help);

          setDirty(false);
          dispatch(endTask("saving"));
          dispatch(addMessage(data.messages.main, new Date(), Priorities.INFO));
        } else {
          data.messages.forEach(message => {
            dispatch(addMessage(message, new Date(), Priorities.ERROR));
          });
        }
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask("saving"));
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getCandidateList();
    }
  }, [endpointStatus]);

  useEffect(() => {
    setDirty(true);
  }, [candidates]);

  // TODO: Fix the check to see if the form is dirty
  const saveButton =
    <Button onClick={saveCandidateList}>
      {t('student_entry.save')}
    </Button>

  const colabResponse = decision => {
    dispatch(startTask("updating"));
    const url =
      props.rootPath === undefined
        ? `${requestCollaborationUrl}${decision}.json`
        : `/${props.rootPath}${requestCollaborationUrl}${decision}.json`;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setCandidateListId(data.id);
        setIsGroup(data.is_group);
        setExpectedCount(data.expected_count);

        setCandidates(prepCandidates(data.candidates, data.expected_count));
        setHelpRequested(data.help_requested);
        setOthersRequestedHelp(data.others_requested_help);
        setDirty(false);
        dispatch(endTask("updating"));
      })
      .catch(error => {
        console.log("error", error);
        dispatch(endTask("updating"));
      });
  };

  var groupComponent;

  if (groupOption) {
    if (isGroup) {
      groupComponent = (
        <em>
          {t("edit.behalf")}: ${groupName}`
        </em>
      );
    } else if (helpRequested) {
      groupComponent = <React.Fragment>{t("edit.waiting")}</React.Fragment>;
    } else if (othersRequestedHelp > 0) {
      groupComponent = (
        <React.Fragment>
          {t("edit.req_rec", { grp_name: groupName })}:&nbsp;
          <a onClick={() => colabResponse(true)}>{t("edit.accept")}</a>
          &nbsp; or&nbsp;
          <a onClick={() => colabResponse(false)}>{t("edit.decline")}</a>
        </React.Fragment>
      );
    } else {
      groupComponent = (
        <React.Fragment>
          <a onClick={() => colabResponse(true)}>
            {t("edit.req_help", { grp_name: groupName })}
          </a>
        </React.Fragment>
      );
    }
  }

  const updateTerm = (event, index) => {
    const tempList = [...candidates];
    tempList[index].term = event.target.value;
    setCandidates(tempList);
  };
  const updateDefinition = (event, index) => {
    const tempList = [...candidates];
    tempList[index].definition = event.target.value;
    setCandidates(tempList);
  };

  return (
    <Panel>
      <Container>
        <Row>
          <Col xs={12} sm={12}>
            <Panel header={`${t('edit.topic')}: ${topic}`} toggleable>
              <Container>
                <Row>
                  <Col xs={12} sm={3}>
                    <h4>{t("edit.description")}</h4>
                  </Col>
                  <Col xs={12} sm={9}>
                    {parse(description)}
                  </Col>
                  <Col xs={12} sm={3}>
                    <h4>{t('edit.for')}</h4>
                  </Col>
                  <Col xs={12} sm={9}>
                    <span>{user.name}</span>
                  </Col>
                  <Col xs={12}>{groupComponent}</Col>
              </Row>
            </Container>
          </Panel>
        </Col>
        <Col xs={12} sm={12}>
          <Panel
            header={t("edit.instructions_title")}
            toggleable>
            {t("edit.instructions")}
          </Panel>
        </Col>
        <Col xs={12}><hr /></Col>
        {candidates.map((candidate, index) => {
          const cleaned = removeStopwords( candidate.term.toLowerCase().split(" ") ).join(" ");
          const duplicated = cleaned.length > 0 && candidateCountHash[cleaned] > 1;
          return (
            <React.Fragment key={index}>
              <Col xs={12} sm={3}>
                <FloatLabel>
                  <InputText
                    id={`term_${index}`}
                    invalid={duplicated}
                    onChange={event => updateTerm(event, index)}
                    value={candidate.term}
                    aria-describedby={`term_${index}_msg`}
                  />
                  {duplicated && <small color="red" id={`term_${index}_msg`}>{t('edit.duplicate_msg')}</small>}
                  <label htmlFor={`term_${index}`}>{t('student_entry.term')}</label>
                </FloatLabel>
              </Col>
              <Col xs={12} sm={9}>
                <FloatLabel>
                  <InputTextarea
                    id={`definition_${index}`}
                    onChange={event => updateDefinition(event, index)}
                    value={candidate.definition}
                    autoResize
                  />
                  <label htmlFor={`definition_${index}`}>{t('student_entry.definition')}</label>
                </FloatLabel>
              </Col>
            </React.Fragment>
          );
        })}
      </Row>
    </Container>
      {
    saveButton
  }
    </Panel >
  );
}
