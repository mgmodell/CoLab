import React, { useState, useEffect } from "react";
//Redux store stuff
import { useDispatch } from "react-redux";
import axios from "axios";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";

import {
  startTask,
  endTask,
  addMessage,
  Priorities,
  setDirty,
  setClean
} from "../infrastructure/StatusSlice";
import { refreshSchools } from "../infrastructure/ContextSlice";
import { useParams } from "react-router-dom";

import InputLabel from "@mui/material/InputLabel";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";

//import i18n from './i18n';
import { Panel } from "primereact/panel";
import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";

export default function SchoolDataAdmin(props) {
  const category = "school";
  const endpoints = useTypedSelector(state => {
    return state.context.endpoints[category];
  });
  const { t } = useTranslation(`${category}s`);
  const endpointStatus = useTypedSelector(state => {
    return state.context.status.endpointsLoaded;
  });
  //const { t, i18n } = useTranslation('schools' );
  const userLoaded = useTypedSelector(state => {
    return null != state.profile.lastRetrieved;
  });

  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });

  const dispatch = useDispatch();

  let { schoolIdParam } = useParams();
  const [schoolId, setSchoolId] = useState(schoolIdParam);
  const [schoolName, setSchoolName] = useState("");
  const [schoolDescription, setSchoolDescription] = useState("");
  const [schoolTimezone, setSchoolTimezone] = useState("UTC");
  const [messages, setMessages] = useState({});

  const timezones = useTypedSelector(state => {
    return state.context.lookups["timezones"];
  });

  const getSchool = () => {
    dispatch(startTask());
    var url = endpoints.baseUrl + "/";
    if (null == schoolId) {
      url = url + "new.json";
    } else {
      url = url + schoolId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const school = response.data.school;

        setSchoolName(school.name || "");
        setSchoolDescription(school.description || "");
        setSchoolTimezone(school.timezone || "UTC");
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
  const saveSchool = () => {
    const method = null == schoolId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints["baseUrl"] +
      "/" +
      (null == schoolId ? props.schoolId : schoolId) +
      ".json";

    axios({
      method: method,
      url: url,
      data: {
        school: {
          name: schoolName,
          description: schoolDescription,
          timezone: schoolTimezone
        }
      }
    })
      .then(resp => {
        const data = resp["data"];
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const school = data.school;
          setSchoolId(school.id);
          setSchoolName(school.name);
          setSchoolDescription(school.description);
          setSchoolTimezone(school.timezone);

          dispatch(setClean(category));
          dispatch(addMessage(data.messages.main, new Date(), Priorities.INFO));
          //setMessages(data.messages);
          dispatch(refreshSchools());
          dispatch(endTask("saving"));
        } else {
          dispatch(
            addMessage(data.messages.main, new Date(), Priorities.ERROR)
          );
          setMessages(data.messages);
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
      getSchool();
    }
  }, [endpointStatus]);

  useEffect(() => {
    dispatch(setDirty(category));
  }, [schoolTimezone, schoolName, schoolDescription]);

  const saveButton = dirty ? (
    <Button onClick={saveSchool} disabled={!dirty}>
      {schoolId > 0 ? "Save" : "Create"} School
    </Button>
  ) : null;

  const detailsComponent = endpointStatus ? (
    <Panel>
      <div className="p-floating-label">
      <InputText
        id="school-name"
        itemID="school-name"
        value={schoolName}
        onChange={event => setSchoolName(event.target.value)}
        />
        <label htmlFor="school-name">School Name</label>
        </div>
      &nbsp;
      <FormControl>
        <InputLabel htmlFor="school_timezone" id="school_timezone_lbl">
          {t("time_zone")}
        </InputLabel>
        <Select
          id="school_timezone"
          value={schoolTimezone}
          onChange={event => setSchoolTimezone(String(event.target.value))}
        >
          {timezones.map(timezone => {
            return (
              <MenuItem key={timezone.name} value={timezone.name}>
                {timezone.name}
              </MenuItem>
            );
          })}
        </Select>
        <FormHelperText error={true}>{messages["timezone"]}</FormHelperText>
      </FormControl>
      <br />
      <div className="p-floating-label">
        <InputTextarea
          id="school-description"
          placeholder="Enter a description of the school"
          rows={4}
          cols={30}
          autoResize={true}
          value={schoolDescription}
          onChange={event => setSchoolDescription(event.target.value)}

        />
        <label htmlFor="school-description">Description</label>
      </div>
      <br />
      {saveButton}
    </Panel>
  ) : null;

  return (
    <Panel>
      {detailsComponent}

    </Panel>
  );
}
