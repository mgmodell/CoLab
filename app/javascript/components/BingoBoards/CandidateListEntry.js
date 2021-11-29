import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import IconButton from "@material-ui/core/IconButton";
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";
import Collapse from "@material-ui/core/Collapse";
import Typography from "@material-ui/core/Typography";
import Alert from "@material-ui/lab/Alert";
import CloseIcon from "@material-ui/icons/Close";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import i18n from "../infrastructure/i18n";
import { useTranslation } from "react-i18next";
import {useDispatch} from 'react-redux';
import {startTask, endTask} from '../infrastructure/StatusActions';
import { TextareaAutosize, Grid, Link } from "@material-ui/core";
import { updateExternalModuleReference } from "typescript";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

export default function CandidateListEntry(props) {
  const endpointSet = "candidate_list";
  const endpoints = useTypedSelector(state=>state['context'].endpoints[endpointSet])
  const endpointStatus = useTypedSelector(state=>state['context'].endpointsLoaded)
  const { t, i18n } = useTranslation("candidate_lists");
  const user = useTypedSelector(state=>state['login'].profile)

  const [dirty, setDirty] = useState(false);
  const dispatch = useDispatch( );
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
    dispatch( startTask() );
    setDirty(true);
    var url =
      endpoints.baseUrl + props.bingoGameId + ".json";
    axios.get( url, { } )
      .then(data => {
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

        dispatch( endTask() );
        setDirty(false);
      })
      .catch( error => {
        console.log( 'error', error );
      });
  };
  const prepCandidates = (candidates, expectedCount) => {
    const tmpCandidates = [...candidates];
    const candidate_count = candidates.length;
    tmpCandidates.sort((a, b) => {
      if (0 == b.term.length) {
        //console.log( `empty b: "${a.term}" and "${b.term}"`)
        return -1;
      } else if (0 == a.term.length) {
        //console.log( `empty a: "${a.term}" and "${b.term}"`)
        return 1;
      } else {
        //console.log( `not empty: "${a.term}" and "${b.term}"`)
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
    dispatch( startTask("saving") );

    const url =
      endpoints.baseUrl + props.bingoGameId + ".json";

    axios.put( url, {
      body: JSON.stringify({
        candidates: candidates.filter(item => {
          return !(
            null === item.id &&
            "" === item.term &&
            "" === item.definition
          );
        })
      })

    })
      .then(data => {
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
          dispatch( endTask("saving") );
        } else {
          setShowErrors(true);
          setMessages(data.messages);
          dispatch( endTask("saving") );
        }
      })
      .catch(error=>{
          console.log("error", error);
          dispatch( endTask("saving") );

      });
  };

  useEffect(() => {
    if (endpointStatus){
      getCandidateList();
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  useEffect(() => setDirty(true), [candidates]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveCandidateList}>
      Save Candidates
    </Button>
  ) : null;

  const colabResponse = decision => {
    dispatch( startTask("updating") );
    const url = `${requestCollaborationUrl}${decision}.json`;
    axios.get( url, { } )
      .then(data => {
        setCandidateListId(data.id);
        setIsGroup(data.is_group);
        setExpectedCount(data.expected_count);

        setCandidates(prepCandidates(data.candidates, data.expected_count));
        setHelpRequested(data.help_requested);
        setOthersRequestedHelp(data.others_requested_help);
        setDirty(false);
        dispatch( endTask("updating") );
      })
      .catch( error =>{
          console.log("error", error );
          dispatch( endTask("updating") );
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
          <Link onClick={() => colabResponse(true)}>{t("edit.accept")}</Link>
          &nbsp; or&nbsp;
          <Link onClick={() => colabResponse(false)}>{t("edit.decline")}</Link>
        </React.Fragment>
      );
    } else {
      groupComponent = (
        <React.Fragment>
          <Link onClick={() => colabResponse(true)}>
            {t("edit.req_help", { grp_name: groupName })}
          </Link>
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
          <Typography>Topic</Typography>
        </Grid>
        <Grid item xs={12} sm={9}>
          <Typography>{topic}</Typography>
        </Grid>
        <Grid item xs={12} sm={3}>
          <Typography>Description</Typography>
        </Grid>
        <Grid item xs={12} sm={9}>
          <Typography>{description}</Typography>
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

CandidateListEntry.propTypes = {
  bingoGameId: PropTypes.number.isRequired
};
