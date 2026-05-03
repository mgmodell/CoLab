import React, { Suspense, useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router";

import { Calendar, dayjsLocalizer } from "react-big-calendar";
import dayjs from "dayjs";
import "react-big-calendar/lib/css/react-big-calendar.css";
import { Temporal, TemporalSettings as Settings, parseISO } from "./infrastructure/TemporalSettings";

import { Skeleton } from "primereact/skeleton";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { useTour } from "./infrastructure/TourContext";
import { useTranslation } from "react-i18next";
import { TabView, TabPanel } from "primereact/tabview";
import { Panel } from "primereact/panel";
import { Container, Row, Col } from "react-grid-system";

import DecisionEnrollmentsTable from "./DecisionEnrollmentsTable";
import DecisionInvitationsTable from "./DecisionInvitationsTable";
import ConsentLog from "./Consent/ConsentLog";
import ProfileDataAdmin from "./profile/ProfileDataAdmin";
import TaskList from "./TaskList";

interface Props {
  rootPath?: string;
}

export default function HomeShell(props: Props) {
  const category = "home";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const dispatch = useDispatch();
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();

  const [curTab, setCurTab] = useState(0);

  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const user = useTypedSelector(state => state.profile.user);
  const [tasks, setTasks] = useState();

  const { setTourSteps } = useTour();

  useEffect(() => {
    setTourSteps([
      {
        element: "body",
        popover: {
          title: "Welcome to the Application!",
          description: "This stuff is awesome. More information soon!",
          align: "center",
          side: "left"
        }
      }
    ]);
    return () => setTourSteps([]);
  }, [setTourSteps]);

  useEffect(() => {
    if (null !== user.lastRetrieved && undefined !== tasks) {
      const newTasks = tasks;
      newTasks.forEach((value, _index, _array) => {
        if (value.next_date) {
          value.next_date = parseISO(value.next_date, Settings.defaultZone);
        }
        if (value.start_date) {
          value.start_date = parseISO(value.start_date, Settings.defaultZone);
        }
        if (value.end_date) {
          value.end_date = parseISO(value.end_date, Settings.defaultZone);
        }
      });

      setTasks(newTasks);
    }
  }, [user.lastRetrieved, Settings.defaultZone, tasks]);

  //Initialising to null
  const [consentLogs, setConsentLogs] = useState();
  const [waitingRosters, setWaitingRosters] = useState();

  const getTasks = () => {
    const url =
      props.rootPath !== undefined
        ? `/${props.rootPath}${endpoints.taskListUrl}.json`
        : `${endpoints.taskListUrl}.json`;

    dispatch(startTask());
    axios
      .get(url, {})
      .then(resp => {
        //Process the data
        const data = resp.data;

        data["tasks"].forEach((value, index, array) => {
          switch (value.type) {
            case "assessment":
              value.title = value.group_name + " for (" + value.name + ")";
              break;
            case "bingo_game":
              if (value.instructor_task === true) {
                value.title = t("candidate_lists.review", { task: value.name });
              } else if (value.status < 0) {
                value.title = t("candidate_lists.play", { task: value.name });
              } else {
                value.title = t("candidate_lists.enter", { task: value.name });
              }
              break;
            case "submission":
            case "assignment":
            case "experience":
              value.title = value.name;
              break;
          }
          if (props.rootPath === undefined) {
            value.url = `/home/${value.link}`;
          } else {
            value.url = `/${props.rootPath}/home/${value.link}`;
          }

          value.link = value.url;
          // Set the dates for the calendar. Use next_date as start, end_date as end.
          if (null !== value.next_date) {
            value.next_date = parseISO(value.next_date);
            value.start = new Date(value.next_date.toInstant().epochMilliseconds);
          }
          if (null !== value.start_date) {
            value.start_date = parseISO(value.start_date);
          }
          if (null !== value.end_date) {
            value.end_date = parseISO(value.end_date);
            value.end = new Date(value.end_date.toInstant().epochMilliseconds);
          } else {
            value.end = value.start || new Date();
          }
        });
        setTasks(data.tasks);
        setConsentLogs(data.consent_logs);
        setWaitingRosters(data.waiting_rosters);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  useEffect(() => {
    if (endpointsLoaded && (props.rootPath !== undefined || isLoggedIn)) {
      getTasks();
    }
  }, [endpointsLoaded, isLoggedIn]);

  var pageContent = <Skeleton className="mb-2" />;
  if (undefined !== consentLogs) {
    if (consentLogs.length > 0) {
      pageContent = (
        <Suspense fallback={<Skeleton className="mb-2" />}>
          <ConsentLog
            consentFormId={consentLogs[0].consent_form_id}
            parentUpdateFunc={getTasks}
          />
        </Suspense>
      );
    } else if (isLoggedIn && !user.welcomed) {
      pageContent = <Suspense fallback={<Skeleton className="mb-2" />}><ProfileDataAdmin profileId={user.id} /></Suspense>;
    } else {
      pageContent = (
        <React.Fragment>
          <h1>{t("home.your_tasks")}</h1>
          <p>
            {t("home.greeting", { name: user.first_name })},<br />
            {t("home.task_interval", {
              postProcess: "interval",
              count: tasks.length
            })}
          </p>
          <TabView
            activeIndex={curTab}
            onTabChange={e => {
              setCurTab(e.index);
            }}
          >
            <TabPanel header="Task View">
              <Suspense fallback={<Skeleton className="mb-2" />}>
                <TaskList tasks={tasks} />
              </Suspense>
            </TabPanel>

            <TabPanel header="Calendar View">
              <Calendar
                localizer={dayjsLocalizer(dayjs)}
                events={Array.isArray(tasks) ? (tasks as any[])
                  .filter(task => task.start instanceof Date)
                  .map(task => ({
                    title: task.title,
                    start: task.start,
                    end: task.end instanceof Date ? task.end : task.start,
                    resource: task
                  })) : []}
                onSelectEvent={event => {
                  navigate(event.resource.url);
                }}
                defaultView="week"
                views={["week", "month"]}
                style={{ height: 500 }}
              />
            </TabPanel>
          </TabView>
        </React.Fragment>
      );
    }
  }

  return (
    <Panel>
      <Container fluid>
        {endpointsLoaded ? (
          <React.Fragment>
            <Row>
              <Col xs={12}>
                {undefined !== waitingRosters && waitingRosters.length > 0 ? (
                  <Suspense fallback={<Skeleton className="mb-2" />}>
                    <DecisionInvitationsTable
                      invitations={waitingRosters}
                      parentUpdateFunc={getTasks}
                    />
                  </Suspense>
                ) : null}
              </Col>
            </Row>

            <Row>
              <Col xs={12}>
                {undefined !== endpoints["courseRegRequestsUrl"] &&
                undefined !== endpoints["courseRegUpdatesUrl"] ? (
                  <Suspense fallback={<Skeleton className="mb-2" />}>
                    <DecisionEnrollmentsTable
                      init_url={endpoints["courseRegRequestsUrl"]}
                      update_url={endpoints["courseRegUpdatesUrl"]}
                    />
                  </Suspense>
                ) : null}
              </Col>
            </Row>
          </React.Fragment>
        ) : null}
        <Row>
          <Col xs={12}>{pageContent}</Col>
        </Row>
      </Container>
    </Panel>
  );
}
