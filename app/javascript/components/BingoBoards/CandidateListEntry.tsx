import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import IconButton from "@mui/material/IconButton";
import Paper from "@mui/material/Paper";
import Collapse from "@mui/material/Collapse";
import Typography from "@mui/material/Typography";
import Alert from "@mui/material/Alert";
import CloseIcon from "@mui/icons-material/Close";
import TextareaAutosize from "@mui/material/TextareaAutosize";
import Grid from "@mui/material/Grid";

import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import parse from "html-react-parser";

type Props = {
  rootPath?: string;
};

export default function CandidateListEntry(props: Props) {
  const endpointSet = "candidate_list";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const { t, i18n } = useTranslation("candidate_lists");

  const { bingoGameId } = useParams();

  const [dirty, setDirty] = useState(false);
  const dispatch = useDispatch();
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [candidateListId, setCandidateListId] = useState(0);
  const [topic, setTopic] = useState("");
  const [description, setDescription] = useState("");
  const [groupOption, setGroupOption] = useState(false);
  const [endDate, setEndDate] = useState(new Date());
  const [groupName, setGroupName] = useState("");
  const [isGroup, setIsGroup] = useState(false);
  const [expectedCount, setExpectedCount] = useState(0);
  const [candidates, setCandidates] = useState([]);
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
        candidate_feedback_id: null
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

          setShowErrors(true);
          setDirty(false);
          setMessages(data.messages);
          dispatch(endTask("saving"));
        } else {
          setShowErrors(true);
          setMessages(data.messages);
          dispatch(endTask("saving"));
        }
      })
      .catch(error => {
        console.log("error", error);
        dispatch(endTask("saving"));
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getCandidateList();
    }
  }, [endpointStatus]);

  useEffect(() => setDirty(true), [candidates]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveCandidateList}>
      Save Candidates
    </Button>
  ) : null;

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
  const detailsComponent = (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12} sm={3}>
          <Typography>{t("topic")}</Typography>
        </Grid>
        <Grid item xs={12} sm={9}>
          <Typography>{topic}</Typography>
        </Grid>
        <Grid item xs={12} sm={3}>
          <Typography>{t("description")}</Typography>
        </Grid>
        <Grid item xs={12} sm={9}>
          <Typography>{parse(description)}</Typography>
        </Grid>
        <Grid item xs={12} sm={3}>
          <Typography>For</Typography>
        </Grid>
        <Grid item xs={12} sm={9}>
          <Typography>{user.name}</Typography>
        </Grid>
        <hr />
        <Grid item xs={12}>
          {groupComponent}
        </Grid>
        {candidates.map((candidate, index) => {
          return (
            <React.Fragment key={index}>
              <Grid item xs={12} sm={3}>
                <TextField
                  label="Term"
                  fullWidth
                  id={`term_${index}`}
                  onChange={event => updateTerm(event, index)}
                  value={candidate.term}
                />
              </Grid>
              <Grid item xs={12} sm={9}>
                <TextareaAutosize
                  label="Definition"
                  width="90%"
                  id={`definition_${index}`}
                  onChange={event => updateDefinition(event, index)}
                  value={candidate.definition}
                />
              </Grid>
            </React.Fragment>
          );
        })}
      </Grid>
      {saveButton}
    </Paper>
  );

  return (
    <Paper>
      <Collapse in={showErrors}>
        <Alert
          action={
            <IconButton
              id="error-close"
              aria-label="close"
              color="inherit"
              size="small"
              onClick={() => {
                setShowErrors(false);
              }}
            >
              <CloseIcon fontSize="inherit" />
            </IconButton>
          }
        >
          {messages["main"]}
        </Alert>
      </Collapse>
      {detailsComponent}
    </Paper>
  );
}
