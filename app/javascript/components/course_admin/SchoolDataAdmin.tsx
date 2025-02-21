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
import { useParams } from "react-router";

//import i18n from './i18n';
import { Panel } from "primereact/panel";
import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { Dropdown } from "primereact/dropdown";

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
    <Panel header={t("edit.title")}>
      <div className="p-float-label">
        <InputText
          id="school-name"
          itemID="school-name"
          value={schoolName}
          onChange={event => setSchoolName(event.target.value)}
        />
        <label htmlFor="school-name">{t("index.name_lbl")}</label>
      </div>
      &nbsp;
      <span className="p-float-label">
        <Dropdown
          id="school_timezone"
          inputId="school_timezone"
          value={schoolTimezone}
          options={timezones}
          optionValue="name"
          onChange={event => {
            setSchoolTimezone(String(event.value));
          }}
          optionLabel="name"
          placeholder={t("time_zone")}
        />
        <label htmlFor="school_timezone">{t("time_zone")}</label>
      </span>
      <br />
      <div className="p-float-label">
        <InputTextarea
          id="school-description"
          placeholder="Enter a description of the school"
          rows={4}
          cols={30}
          autoResize={true}
          value={schoolDescription}
          onChange={event => setSchoolDescription(event.target.value)}
        />
        <label htmlFor="school-description">{t("index.description_lbl")}</label>
      </div>
      <br />
      {saveButton}
    </Panel>
  ) : null;

  return <Panel>{detailsComponent}</Panel>;
}
