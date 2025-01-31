import React, { useState, useEffect, Suspense } from "react";
import axios from "axios";
import { useParams } from "react-router";
import { useNavigate } from "react-router";

import { Info } from "luxon";

import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";

import { useTranslation } from "react-i18next";

import { Button } from "primereact/button";
import { Calendar } from "primereact/calendar";
import { Dropdown } from "primereact/dropdown";
import { InputSwitch } from "primereact/inputswitch";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { Panel } from "primereact/panel";
import { Skeleton } from "primereact/skeleton";
import { TabPanel, TabView } from "primereact/tabview";
import parse from 'html-react-parser';

const ProjectGroups = React.lazy(() => import("./ProjectGroups"));
const ChartContainer = React.lazy(() => import("../Reports/ChartContainer"));

export default function ProjectDataAdmin(props) {
  const category = "project";
  const { t, i18n } = useTranslation(`${category}s`);
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const navigate = useNavigate();
  const { courseIdParam, projectIdParam } = useParams();

  const [curTab, setCurTab] = useState(0);
  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });
  const [messages, setMessages] = useState({});
  const dispatch = useDispatch();

  const [factorPacks, setFactorPacks] = useState([
    { id: 0, name: "none selected" }
  ]);
  const [styles, setStyles] = useState([{ id: 0, name_en: "none selected" }]);
  const [projectId, setProjectId] = useState(
    "new" === projectIdParam ? null : Number(projectIdParam)
  );
  const [projectName, setProjectName] = useState("");
  const [projectDescription, setProjectDescription] = useState("");
  const now = new Date();
  const [projectStartDate, setProjectStartDate] = useState(now);
  //Using this Luxon function for later i18n
  const [daysOfWeek, setDaysOfWeek] = useState(
    Info.weekdays().map((day, index) => {
      //Not sure why there's an off-by-one error here, but this fixes it 9/26
      return { id: index + 1, day: day };
    })
  );
  const [projectEndDate, setProjectEndDate] = useState(() => {
    now.setMonth(now.getMonth() + 3);
    return now;
  });
  const [projectStartDOW, setProjectStartDOW] = useState(5);
  const [projectEndDOW, setProjectEndDOW] = useState(1);
  const [projectActive, setProjectActive] = useState(false);
  const [projectFactorPackId, setProjectFactorPackId] = useState(0);
  const [projectStyleId, setProjectStyleId] = useState(0);
  const [courseName, setCourseName] = useState("");
  const [courseTimezone, setCourseTimezone] = useState("UTC");

  const getProject = () => {
    dispatch(startTask());
    dispatch(setDirty(category));
    var url = endpoints.baseUrl + "/";
    if (null == projectId) {
      url = url + "new/" + courseIdParam + ".json";
    } else {
      url = url + projectId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const project = response.data.project;
        setFactorPacks(factorPacks.concat(data.factorPacks));
        setStyles(styles.concat(data.styles));

        const course = data.course;
        setCourseName(course.name);
        setCourseTimezone(course.timezone);
        //Settings.defaultZone = course.timezone;

        setProjectName(project.name || "");
        setProjectDescription(project.description || "");
        setProjectActive(project.active);

        var receivedDate = new Date(Date.parse(project.start_date));
        setProjectStartDate(receivedDate);

        receivedDate = new Date(Date.parse(project.end_date));
        setProjectEndDate(receivedDate);
        setProjectFactorPackId(project.factor_pack_id);
        setProjectStyleId(project.style_id);
        setProjectStartDOW(project.start_dow);
        setProjectEndDOW(project.end_dow);
        dispatch(setClean(category));
      })
      .finally(() => {
        dispatch(endTask());
      });
  };
  const saveProject = () => {
    const method = null == projectId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null == projectId ? courseIdParam : projectId) +
      ".json";

    axios({
      method: method,
      url: url,
      data: {
        project: {
          name: projectName,
          course_id: courseIdParam,
          description: projectDescription,
          active: projectActive,
          start_date: projectStartDate,
          end_date: projectEndDate,
          start_dow: projectStartDOW,
          end_dow: projectEndDOW,
          factor_pack_id: projectFactorPackId,
          style_id: projectStyleId
        }
      }
    })
      .then(response => {
        const data = response.data;
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const project = data.project;
          setProjectId(project.id);
          setProjectName(project.name);
          setProjectDescription(project.description);
          setProjectActive(project.active);
          var receivedDate = new Date(Date.parse(project.start_date));
          setProjectStartDate(receivedDate);

          receivedDate = new Date(Date.parse(project.end_date));
          setProjectEndDate(receivedDate);

          setProjectFactorPackId(project.factor_pack_id);
          setProjectStyleId(project.style_id);
          setProjectStartDOW(project.start_dow);
          setProjectEndDOW(project.end_dow);

          const course = data.course;
          setCourseName(course.name);
          dispatch(endTask("saving"));
          dispatch(setClean(category));
          setMessages(data.messages);
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.INFO)
          );
          navigate(`../${courseIdParam}/project/${project.id}`, {
            replace: true
          });
        } else {
          setMessages(data.messages);
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.ERROR)
          );
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
    daysOfWeek.unshift(daysOfWeek.pop());
    setDaysOfWeek(daysOfWeek);
  }, []);

  useEffect(() => {
    if (endpointStatus) {
      getProject();
    }
  }, [endpointStatus]);

  useEffect(() => {
    dispatch(setDirty(category));
  }, [
    projectName,
    projectDescription,
    projectActive,
    projectStyleId,
    projectFactorPackId,
    projectStartDate,
    projectEndDate,
    projectStartDOW,
    projectEndDOW
  ]);

  const saveButton = dirty ? (
    <Button onClick={saveProject}>
      {null == projectId ? t('create_btn') : t('save_btn')}
    </Button>
  ) : null;

  //Later I want to call the activate/deactivate right here
  const toggleActive = () => {
    setProjectActive(!projectActive);
  };

  const detailsComponent = (
    <Panel>
      <span className="p-float-label">
        <InputText
          id="name"
          itemID="name"
          value={projectName}
          onChange={event => setProjectName(event.target.value)}
        />
        <label htmlFor="name">{t("name_lbl")}</label>
      </span>
      <span className="p-float-label">
        <InputTextarea
          id="description"
          itemID="description"
          value={projectDescription}
          onChange={event => setProjectDescription(event.target.value)}
        />
        <label htmlFor="description">{t("description_lbl")}</label>
      </span>
      <InputSwitch
        checked={projectActive}
        onChange={() => toggleActive()}
        id="active"
        itemID="active"
        name="active"
      />
      <label htmlFor="active">{t("active_switch")}</label>

      <span>{t('timezone_warning', { timezone: courseTimezone } )}</span>
      <span className="p-float-label">
        <Calendar
          id="project_dates"
          value={[projectStartDate, projectEndDate]}
          selectionMode="range"
          onChange={event => {
            const changeTo = event.value;
            if (null !== changeTo && changeTo.length > 1) {
              setProjectStartDate(changeTo[0]);
              setProjectEndDate(changeTo[1]);
            }
          }}
          showIcon={true}
          showOnFocus={false}
          inputId="project_start_dates"
          name="project_start_dates"
        />
        <label htmlFor="project_start_date">{t("project_dates")}</label>
      </span>
      <br />
      <span className="p-float-label w-full">
        <Dropdown
          id="start_dow"
          itemID="start_dow"
          inputId="start_dow"
          value={projectStartDOW}
          options={daysOfWeek}
          onChange={event => setProjectStartDOW(event.value)}
          optionLabel="day"
          optionValue="id"
        />
        <label htmlFor="start_dow">{t("opens")}</label>
      </span>
      <span className="p-float-label w-full">
        <Dropdown
          id="end_dow"
          inputId="end_dow"
          itemID="end_dow"
          value={projectEndDOW}
          options={daysOfWeek}
          onChange={event => setProjectEndDOW(event.value)}
          optionLabel="day"
          optionValue="id"
        />
        <label htmlFor="end_dow">{t("closes")}</label>
      </span>

      <span className="p-float-label">
        <Dropdown
          id="style"
          inputId="style"
          itemID="style"
          value={projectStyleId}
          options={styles}
          disabled
          onChange={event => setProjectStyleId(event.value)}
          optionLabel="name"
          optionValue="id"
        />
        <label htmlFor="style">{t("style")}</label>
      </span>
      <span className="p-float-label">
        <Dropdown
          id="factor_pack"
          inputId="factor_pack"
          itemID="factor_pack"
          value={projectFactorPackId}
          options={factorPacks}
          onChange={event => setProjectFactorPackId(event.value)}
          optionLabel="name"
          optionValue="id"
        />
        <label htmlFor="factor_pack">{t("factor_pack")}</label>
      </span>
      <br />
      {saveButton}
    </Panel>
  );
  const chartContainer =
    0 < projectId && "" !== projectName ? (
      <React.Fragment>
        <Suspense fallback={<Skeleton className="mb-2" />}>
          <ChartContainer
            unitOfAnalysis="group"
            anonymize={false}
            forResearch={false}
            projects={[{ id: projectId, name: projectName }]}
          />
        </Suspense>
      </React.Fragment>
    ) : null;

  return (
    <TabView activeIndex={curTab} onTabChange={event => setCurTab(event.index)}>
      <TabPanel header="Details">{detailsComponent}</TabPanel>
      <TabPanel header="Groups">
        <ProjectGroups
          projectId={projectId}
          groupsUrl={endpoints.groupsUrl}
          diversityCheckUrl={endpoints.diversityCheckUrl}
          diversityRescoreGroup={endpoints.diversityRescoreGroup}
          diversityRescoreGroups={endpoints.diversityRescoreGroups}
        />
      </TabPanel>
      <TabPanel header="Reporting">{chartContainer}</TabPanel>
    </TabView>
  );
}

ProjectDataAdmin.propTypes = {};
