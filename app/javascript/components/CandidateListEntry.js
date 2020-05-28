import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import IconButton from '@material-ui/core/IconButton';
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";
import Collapse from '@material-ui/core/Collapse';
import Alert from '@material-ui/lab/Alert';
import CloseIcon from '@material-ui/icons/Close';

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import { useEndpointStore } from "./EndPointStore";
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useUserStore } from "./UserStore";
import { TextareaAutosize, Grid } from "@material-ui/core";
import { updateExternalModuleReference } from "typescript";

export default function CandidateListEntry(props) {
  const endpointSet = "candidate_list";
  const [endpoints, endpointsActions] = useEndpointStore();
  //const { t, i18n } = useTranslation('schools' );
  const [user, userActions] = useUserStore();

  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState( false );

  const [candidateListId, setCandidateListId] = useState( 0 );
  const [topic, setTopic] = useState( '' );
  const [description, setDescription] = useState( '' );
  const [ groupOption, setGroupOption] = useState( false );
  const [endDate, setEndDate] = useState( new Date( ) );
  const [groupName, setGroupName] = useState( '' );
  const [isGroup, setIsGroup] = useState( false );
  const [expectedCount, setExpectedCount] = useState( 0 );
  const [candidates, setCandidates] = useState( []);
  const [othersRequestedHelp, setOthersRequestedHelp] = useState( 0 );
  const [requestCollaborationUrl, setRequestCollaborationUrl] = useState( '' );


  const getCandidateList = () => {
    setDirty(true);
    var url = endpoints.endpoints[endpointSet].baseUrl + "/" + props.bingoGameId + '.json';
    fetch(url, {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return response.json();
        }
      })
      .then(data => {
        setCandidateListId( data.id );
        setTopic( data.topic );
        setDescription( data.description );
        setGroupOption( data.group_option);
        setEndDate( new Date( data.end_date ) );
        setGroupName( data.group_name );
        setIsGroup( data.is_group );
        setExpectedCount( data.expected_count );

        const candidate_count = data.candidates.length;
        for( var count = candidates_count; count < data.expected_count; count++){
          data.candidates.push(
            {
              id: null,
              term: '',
              definition: '',
              filtered_consistent: '',
              candidate_feedback_id: null
            }
          )
        }
        setCandidates( data.candidates );
        setOthersRequestedHelp( data.others_requested_help );
        setRequestCollaborationUrl( data.request_collaboration_url );

        setWorking(false);
        setDirty(false);
      });
  };
  const saveCandidateList = () => {
    setWorking(true);

    const url =
      endpoints.endpoints[endpointSet].baseUrl +
      props.bingo_game_id + '.json';

    fetch(url, {
      method: 'PUT',
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        candidates: candidates
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          setWorking(false);
        }
      })
      .then(data => {
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          setCandidateListId( data.id );
          setIsGroup( data.is_group );
          setExpectedCount( data.expected_count );
          const candidate_count = data.candidates.length;
          for( var count = candidates_count; count < data.expected_count; count++){
            data.candidates.push(
              {
                id: null,
                term: '',
                definition: '',
                filtered_consistent: '',
                candidate_feedback_id: null
              }
            )
          }
          setCandidates( data.candidates );
          setOthersRequestedHelp( data.others_requested_help );

          setShowErrors( true );
          setDirty(false);
          setMessages(data.messages);
          setWorking(false);
        } else {
          setShowErrors( true );
          setMessages(data.messages);
          setWorking(false);
        }
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getCandidateList();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  useEffect(() => setDirty(true), [
    candidates
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveCandidateList}>
      Save Candidates
    </Button>
  ) : null;

  const groupComponent = groupOption ? (
    <React.Fragment>
    {isGroup ? (
      <p>List for {user.first_name}</p>
    ) : (
      <p>Beat it, kid!</p>
    )}
    </React.Fragment>

  ) : ( null )

  const updateTerm = (event, index)=>{
    const tempList = [...candidates];
    tempList[index].term = event.target.value;
    setCandidates( tempList );

  }
  const updateDefinition = (event, index)=>{
    const tempList = [...candidates];
    tempList[index].definition = event.target.value;
    setCandidates( tempList );

  }
  const detailsComponent = (
    <Paper>
      {working ? <LinearProgress /> : null}
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6}>
          <TextField
            label='Topic'
            fullWidth
            variant='outlined'
            value={topic} />
        </Grid>
        <Grid item xs={12}>
          <TextField
            label='Description'
            fullWidth
            variant='outlined'
            value={description} />
        </Grid>
        <Grid item xs={12}>
          <TextField
            label='Description'
            fullWidth
            variant='outlined'
            value={description} />
        </Grid>
        <Grid item xs={12}>
          {groupComponent}
        </Grid>
        {candidates.map((candidate, index) =>{
          <React.Fragment key={index}>
            <Grid item xs={12}>
              <TextField
                label='Term'
                fullWidth
                variant='outlined'
                onChange={(event)=>updateTerm(event, index)}
                value={candidate.term} />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label='Definition'
                fullWidth
                variant='outlined'
                onChange={(event)=>updateTerm(event, index)}
                value={candidate.definition} />
            </Grid>
          </React.Fragment>
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
              id='error-close'
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
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  bingoGameId: PropTypes.number
};
