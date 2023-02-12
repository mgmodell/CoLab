import React, { useState, useEffect } from "react";
//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  addMessage,
  Priorities,
  setDirty,
  setClean
} from "../infrastructure/StatusSlice";
import { useParams } from "react-router-dom";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import InputLabel from "@mui/material/InputLabel";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import Paper from "@mui/material/Paper";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";

import { Settings } from "luxon";

//import i18n from './i18n';
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

export default function RubricDataAdmin(props) {
  const category = "rubric";
  const endpoints = useTypedSelector(state => {
    return state.context.endpoints[category];
  });
  const { t } = useTranslation(`${category}s`);
  const endpointStatus = useTypedSelector(state => {
    return state.context.status.endpointsLoaded;
  });
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );
  const userLoaded = useTypedSelector(state => {
    return null != state.profile.lastRetrieved;
  });

  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });

  const dispatch = useDispatch();

  let { rubricIdParam } = useParams();
  const [rubricId, setRubricId] = useState(rubricIdParam);
  const [rubricName, setRubricName] = useState("");
  const [rubricDescription, setRubricDescription] = useState("");
  const [rubricPublished, setRubricPublished] = useState(false);
  const [rubricVersion, setRubricVersion] = useState(1);
  const [rubricCreator, setRubricCreator] = useState('');
  const [rubricSchoolId, setRubricSchoolId] = useState( 0 );
  const [messages, setMessages] = useState({});

  const timezones = useTypedSelector(state => {
    return state.context.lookups["timezones"];
  });

  const getRubric = () => {
    dispatch(startTask());
    var url = endpoints.baseUrl + "/";
    if (null == rubricId) {
      url = url + "new.json";
    } else {
      url = url + rubricId + ".json";
    }
    console.log( `URL: ${url}`);
    axios
      .get(url, {})
      .then(response => {
        const rubric = response.data;

        setRubricName(rubric.name || "");
        setRubricDescription(rubric.description || "");
        setRubricPublished( rubric.published || false );
        setRubricVersion( rubric.version || 1 );
        setRubricCreator( rubric.creator );
        setRubricSchoolId( rubric.school_id );
        dispatch(setClean(category));
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
        dispatch(setClean(category));
      });
  };
  const saveRubric = () => {
    const method = null == rubricId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints["baseUrl"] +
      "/" +
      (null == rubricId ? props.rubricId : rubricId) +
      ".json";

    axios({
      method: method,
      url: url,
      data: {
        rubric: {
          name: rubricName,
          description: rubricDescription,
        }
      }
    })
      .then(resp => {
        const data = resp["data"];
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const rubric = data.rubric;
          setRubricId(rubric.id);
          setRubricName(rubric.name);
          setRubricDescription(rubric.description);
          setRubricVersion( rubric.version );
          setRubricPublished( rubric.published );
          setRubricCreator( rubric.creator );

          dispatch(setClean(category));
          dispatch(addMessage(data.messages.main, new Date(), Priorities.INFO));
          //setMessages(data.messages);
          dispatch(endTask("saving"));
        } else {
          dispatch(
            addMessage(data.messages.main, new Date(), Priorities.ERROR)
          );
          setMessages(data.messages);
          dispatch(endTask("saving"));
        }
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getRubric();
    }
  }, [endpointStatus]);


  useEffect(() => {
    dispatch(setDirty(category));
  }, [rubricName, rubricDescription]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveRubric} disabled={!dirty}>
      {rubricId > 0 ? "Save" : "Create"} Rubric
    </Button>
  ) : null;

  const detailsComponent = endpointStatus ? (
    <Paper>
      <TextField
        label={t('name')}
        id="rubric-name"
        value={rubricName}
        fullWidth={false}
        onChange={event => setRubricName(event.target.value)}
        error={null != messages["name"]}
        helperText={messages["name"]}
      />
      &nbsp;
      <br />
      <TextField
        id="rubric-description"
        placeholder="Enter a description of the rubric"
        multiline={true}
        minRows={2}
        maxRows={4}
        label={t('description')}
        value={rubricDescription}
        onChange={event => setRubricDescription(event.target.value)}
        InputLabelProps={{
          shrink: true
        }}
        margin="normal"
      />
      <br />
      {saveButton}
    </Paper>
  ) : null;

  return <Paper>{detailsComponent}</Paper>;
}
