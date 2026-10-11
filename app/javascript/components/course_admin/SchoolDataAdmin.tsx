import React, { useState, useEffect, useRef } from "react";
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
  useDirtyStatus,
  DIRTY_STATUS
} from "../infrastructure/StatusSlice";
import { refreshSchools } from "../infrastructure/ContextSlice";
import { useParams } from "react-router";

//import i18n from './i18n';
import { Panel } from "primereact/panel";
import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { Dropdown } from "primereact/dropdown";
import { FloatLabel } from "primereact/floatlabel";

interface Props {
  schoolId?: number;
}

export default function SchoolDataAdmin(props : Props) {
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

  const dispatch = useDispatch();

  let { schoolIdParam } = useParams();
  const [schoolId, setSchoolId] = useState( parseInt( schoolIdParam ) || null );
  const [schoolName, setSchoolName] = useState("");
  const [schoolDescription, setSchoolDescription] = useState("");
  const [schoolTimezone, setSchoolTimezone] = useState("UTC");

  const [dirty, setDirty] = useDirtyStatus(null == schoolId ? DIRTY_STATUS.DIRTY : DIRTY_STATUS.CLEAN);
  const suppressDirtyRef = useRef( false );
  const cleanSchoolRef = useRef<any>(null);

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
    suppressDirtyRef.current = true;
    axios
      .get(url, {})
      .then(response => {
        const school = response.data.school;

        const cleanSchool = {
          name: school.name || "",
          description: school.description || "",
          timezone: school.timezone || "UTC"
        };
        cleanSchoolRef.current = cleanSchool;
        setSchoolName(cleanSchool.name);
        setSchoolDescription(cleanSchool.description);
        setSchoolTimezone(cleanSchool.timezone);
        setDirty(DIRTY_STATUS.CLEAN);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
        suppressDirtyRef.current = false;
      });
  };
  const saveSchool = () => {
    const method = null == schoolId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints["baseUrl"] +
      "/" +
      //Not sure I really want this here.
      (null == schoolId ? props.schoolId : schoolId) +
      ".json";

    suppressDirtyRef.current = true;
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
          const cleanSchool = {
            name: school.name || "",
            description: school.description || "",
            timezone: school.timezone || "UTC"
          };
          cleanSchoolRef.current = cleanSchool;
          setSchoolName(cleanSchool.name);
          setSchoolDescription(cleanSchool.description);
          setSchoolTimezone(cleanSchool.timezone);

          dispatch(addMessage(data.messages.main, new Date(), Priorities.INFO));
          //setMessages(data.messages);
          dispatch(refreshSchools());
          setDirty(DIRTY_STATUS.CLEAN);
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
        suppressDirtyRef.current = false;
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      suppressDirtyRef.current = true;
      getSchool();
      setDirty(DIRTY_STATUS.CLEAN);
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (suppressDirtyRef.current) {
      return;
    }
    const currentSchool = {
      name: schoolName,
      description: schoolDescription,
      timezone: schoolTimezone
    };
    setDirty(JSON.stringify(currentSchool) === JSON.stringify(cleanSchoolRef.current)
      ? DIRTY_STATUS.CLEAN
      : DIRTY_STATUS.DIRTY);
  }, [schoolTimezone, schoolName, schoolDescription]);

  const resetSchool = () => {
    if (cleanSchoolRef.current) {
      setSchoolName(cleanSchoolRef.current.name);
      setSchoolDescription(cleanSchoolRef.current.description);
      setSchoolTimezone(cleanSchoolRef.current.timezone);
      setDirty(DIRTY_STATUS.CLEAN);
    }
  };

  const resetButton = (
    <Button onClick={resetSchool} disabled={!dirty}>
      Reset
    </Button>
  );

  const saveButton = dirty ? (
    <Button onClick={saveSchool} disabled={!dirty}>
      {schoolId && schoolId > 0 ? "Save" : "Create"} School
    </Button>
  ) : null;

  const detailsComponent = endpointStatus ? (
    <Panel header={t("edit.title")}>
      <FloatLabel>
        <InputText
          id="school-name"
          itemID="school-name"
          value={schoolName}
          onChange={event => setSchoolName(event.target.value)}
        />
        <label htmlFor="school-name">{t("index.name_lbl")}</label>
      </FloatLabel>
      &nbsp;
      <FloatLabel>
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
      </FloatLabel>
      <br />
      <FloatLabel>
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
      </FloatLabel>
      <br />
      {resetButton}
      {saveButton}
    </Panel>
  ) : null;

  return <Panel>{detailsComponent}</Panel>;
}
