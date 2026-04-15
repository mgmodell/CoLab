import React, { Suspense, useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router";

import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import luxonPlugin from "@fullcalendar/luxon";
import { DateTime, Settings } from "luxon";

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
      newTasks.forEach((value, index, array) => {
        value.next_date = value.next_date.setZone(Settings.defaultZone);
        value.start_date = value.start_date.setZone(Settings.defaultZone);
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
          // Set the dates properly - close may need work
          value.start = value.next_date;
          if (null !== value.next_date) {
            value.next_date = DateTime.fromISO(value.next_date);
          }
          if (null !== value.start_date) {
            value.start_date = DateTime.fromISO(value.start_date);
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
              <FullCalendar
                headerToolbar={{
                  center: "thisWeek,dayGridMonth"
                }}
                initialView="thisWeek"
                views={{
                  thisWeek: {
                    type: "dayGrid",
                    duration: {
                      weeks: 2
                    },
                    buttonText: "Two Weeks"
                  },
                  dayGridMonth: {
                    buttonText: "One Month"
                  }
                }}
                displayEventTime={false}
                events={tasks}
                eventClick={info => {
                  navigate(info.event.url);
                }}
                plugins={[dayGridPlugin, luxonPlugin]}
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
