import React, { useState, useEffect } from "react";
import { useParams } from "react-router";
import { useNavigate } from "react-router";
import { useTranslation } from "react-i18next";
import { utcAdjustDate, utcAdjustEndDate } from "../infrastructure/Utilities";

const ReactionsList = React.lazy(() => import("./ReactionsList"));

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
import axios from "axios";

import { Button } from "primereact/button";
import { Panel } from "primereact/panel";
import { TabPanel, TabView } from "primereact/tabview";
import { InputText } from "primereact/inputtext";
import { InputSwitch } from "primereact/inputswitch";
import { Calendar } from "primereact/calendar";
import ResponsesWordCloud from "../Reports/ResponsesWordCloud";
import parse from 'html-react-parser';
import { FloatLabel } from "primereact/floatlabel";

interface IExperience {
  id: string;
  name: string;
  course_id: number;
  lead_time: number;
  active: boolean;
  start_date: string;
  end_date: string;
}

export default function ExperienceDataAdmin(props) {
  const category = "experience_admin";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const navigate = useNavigate();
  const { t, i18n } = useTranslation(`${category}s`);

  const user = useTypedSelector(state => state.profile.user);
  const userLoaded = useTypedSelector(state => {
    return null != state.profile.lastRetrieved;
  });
  const { experienceIdParam, courseIdParam } = useParams();

  const [curTab, setCurTab] = useState(0);
  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });
  const dispatch = useDispatch();
  const [messages, setMessages] = useState({});
  const [experienceId, setExperienceId] = useState(
    "new" === experienceIdParam ? null : experienceIdParam
  );
  const [experienceName, setExperienceName] = useState("");
  const [experienceLeadTime, setExperienceLeadTime] = useState(0);

  const now = new Date();
  const [experienceStartDate, setExperienceStartDate] = useState(now);
  //Using this Luxon function for later i18n
  const [experienceEndDate, setExperienceEndDate] = useState(() => {
    now.setMonth(now.getMonth() + 3);
    return now;
  });
  const [experienceActive, setExperienceActive] = useState(false);
  const [reactionsUrl, setReactionsUrl] = useState();
  const [reactionData, setReactionData] = useState();
  const [courseName, setCourseName] = useState("");
  const [courseTimezone, setCourseTimezone] = useState("UTC");

  // For the word cloud
  const [responseWords, setResponseWords] = useState([]);
  const colors = ["#477efd", "#74d6fd", "#3d5ef9", "#2b378b", "#1f2255"];

  const getExperience = () => {
    dispatch(startTask());
    dispatch(setDirty(category));
    var url = endpoints.baseUrl + "/";
    if (null == experienceId) {
      url = url + "new/" + courseIdParam + ".json";
    } else {
      url = url + experienceId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const experience: IExperience = data.experience;
        const course = data.course;

        setCourseName(course.name);
        setCourseTimezone(course.timezone);
        setReactionsUrl(data.reactionsUrl);

        setExperienceName(experience.name || "");
        setExperienceActive(experience.active || false);
        setExperienceLeadTime(experience.lead_time || 3);

        var receivedDate = new Date(Date.parse(experience.start_date));
        setExperienceStartDate(receivedDate);

        receivedDate = new Date(Date.parse(experience.end_date));
        setExperienceEndDate(new Date(Date.parse(experience.end_date)));

        setResponseWords(data.response_words);

        dispatch(endTask());
        dispatch(setClean(category));
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(setClean(category));
      });
  };
  const saveExperience = () => {
    const method = null == experienceId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null == experienceId ? courseIdParam : experienceId) +
      ".json";

    axios({
      url: url,
      method: method,
      data: {
        experience: {
          name: experienceName,
          course_id: courseIdParam,
          lead_time: experienceLeadTime,
          active: experienceActive,
          start_date: experienceStartDate,
          end_date: experienceEndDate
        }
      }
    })
      .then(response => {
        const data = response.data;
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const experience: IExperience = data.experience;
          setExperienceId(experience.id);
          setExperienceName(experience.name);
          setExperienceActive(experience.active);

          var receivedDate = new Date(Date.parse(experience.start_date));
          setExperienceStartDate(receivedDate);

          receivedDate = new Date(Date.parse(experience.end_date));
          setExperienceEndDate(receivedDate);

          const course = data.course;
          setCourseName(course.name);
          dispatch(endTask("saving"));
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.INFO)
          );
          setMessages(data.messages);
          dispatch(setClean(category));
        } else {
          setMessages(data.messages);
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.ERROR)
          );
        }
        navigate(`../${courseIdParam}/experience/${experienceId}`, {
          replace: true
        });
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
      getExperience();
    }
  }, [endpointStatus]);

  useEffect(() => {
    dispatch(setDirty(category));
  }, [
    experienceName,
    experienceLeadTime,
    experienceActive,
    experienceStartDate,
    experienceEndDate
  ]);

  const saveButton = dirty ? (
    <Button onClick={saveExperience}>
      {null == experienceId ? t('create') : t('save')}
    </Button>
  ) : null;

  //Later I want to call the activate/deactivate right here
  const toggleActive = () => {
    setExperienceActive(!experienceActive);
  };

  const detailsComponent = (
    <Panel>
      <FloatLabel>
        <InputText
          id="experience-name"
          value={experienceName}
          onChange={event => setExperienceName(event.target.value)}
        />
        <label htmlFor="experience-name">{t('name')}</label>
      </FloatLabel>
      <FloatLabel>
        <InputText
          id="experience-lead-time"
          value={experienceLeadTime.toString()}
          onChange={event =>
            setExperienceLeadTime(parseInt(event.target.value))
          }
          type="number"
        />
        <label htmlFor="experience-lead-time">{t('lead_time_lbl')}</label>
      </FloatLabel>


      <InputSwitch
        checked={experienceActive}
        onChange={() => toggleActive()}
      />
      <label htmlFor="experience-active">{t('active')}</label><br />

      <span>{t('timezone_warning', {timezone: parse( courseTimezone ) } )}</span>
      <FloatLabel>
        <Calendar
          id="experience_start_date"
          inputId="experience_start_date"
          value={utcAdjustDate(experienceStartDate)}
          onChange={event => {
            const changeTo = event.value;
            if (null !== changeTo) {
              setExperienceStartDate(changeTo);
            }
          }
          }
          showOnFocus={false}
          showIcon={true}
        />
        <label htmlFor="experience_start_date">{t('start_date_lbl')}</label>
      </FloatLabel> {t('date_to_lbl')}
      <FloatLabel>
        <Calendar
          id="experience_end_date"
          inputId="experience_end_date"
          value={utcAdjustEndDate(experienceEndDate)}
          onChange={event => {
            const changeTo = event.value;
            if (null !== changeTo) {
              setExperienceEndDate(changeTo);
            }
          }
          }
          showOnFocus={false}
          showIcon={true}
        />
        <label htmlFor="experience_end_date">{t('end_date_lbl')}</label>
      </FloatLabel>

      <br />

      <br />
      {saveButton}
    </Panel>
  );

  const reactionListing =
    reactionsUrl != undefined && experienceId > 0 ? (
      <ReactionsList
        retrievalUrl={reactionsUrl}
        reactionsList={reactionData}
        reactionsListUpdateFunc={setReactionData}
      />
    ) : (
      <>{t("errors.must_be_created")}</>
    );
  return (
    <TabView activeIndex={curTab} onTabChange={event => setCurTab(event.index)}>
      <TabPanel header={t("tabs.details")}>{detailsComponent}</TabPanel>
      <TabPanel header={t("tabs.results")} disabled={null == experienceId}>
        {reactionListing}
      </TabPanel>
      <TabPanel header={t("tabs.response_word_cloud")}>
        <ResponsesWordCloud
          width={400}
          height={400}
          words={responseWords}
          colors={colors}
        />
      </TabPanel>
    </TabView>
  );
}
