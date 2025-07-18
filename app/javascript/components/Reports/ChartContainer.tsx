import React, { useState, useEffect } from "react";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { useTranslation } from "react-i18next";

import SubjectChart, { unit_codes, code_units } from "./SubjectChart";
import { Skeleton } from "primereact/skeleton";
import { Dropdown } from "primereact/dropdown";
import { InputSwitch } from "primereact/inputswitch";
import { Col, Container, Row } from "react-grid-system";
import { Panel } from "primereact/panel";
import { FloatLabel } from "primereact/floatlabel";

const ConfirmDialog = React.lazy(() => import("./ConfirmDialog"));

interface IProject {
  id: number;
  name: string;
}

type Props = {
  unitOfAnalysis: string;
  projects?: IProject[];
  anonymize?: boolean;
  forResearch?: boolean;
};

export default function ChartContainer(props: Props) {
  const category = "graphing";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);

  const { t, i18n } = useTranslation(category);

  const [projects, setProjects] = useState(props.projects || []);
  const [selectedProject, setSelectedProject] = useState(-1);
  const [subjects, setSubjects] = useState([]);
  const [selectedSubject, setSelectedSubject] = useState(-1);
  const [anonymizeOpen, setAnonymizeOpen] = useState(false);
  const [forResearchOpen, setForResearchOpen] = useState(false);
  const [anonymize, setAnonymize] = useState(props.anonymize || false);
  const [forResearch, setForResearch] = useState(props.forResearch || false);

  const [charts, setCharts] = useState({});

  const getSubjectsForProject = projectId => {
    if (0 < selectedProject) {
      const url = endpoints.subjectsUrl + ".json";
      axios
        .post(url, {
          project_id: selectedProject,
          unit_of_analysis: unit_codes[props.unitOfAnalysis],
          for_research: forResearch,
          anonymous: anonymize
        })
        .then(resp => {
          setSubjects(resp.data);
        })
        .catch(error => {
          console.log("subject retrieval error", error);
        });
    }
  };

  const getProjects = () => {
    const url = endpoints.projectsUrl + ".json";
    axios
      .post(url, {
        for_research: forResearch,
        anonymous: anonymize
      })
      .then(resp => {
        setProjects(resp.data);
      })
      .catch(error => {
        console.log("project retrieval error", error);
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      if (null == props.projects) {
        clearCharts();
      } else {
        if (1 === props.projects.length) {
          setSelectedProject(props.projects[0].id);
          getSubjectsForProject(props.projects[0].id);
        }
      }
    }
  }, [endpointStatus, forResearch, anonymize]);

  const clearCharts = () => {
    if (endpointStatus) {
      setCharts({});
      setSelectedSubject(-1);
      setSelectedProject(-1);
      getProjects();
      setSubjects([]);
    }
  };

  useEffect(() => {
    if (endpointStatus) {
      getSubjectsForProject(selectedProject);
    }
  }, [selectedProject]);

  // If there's only one project
  useEffect(() => {
    if (1 == projects.length) {
      setSelectedProject(projects[0].id);
    }
  }, [projects]);

  const selectSubject = (subjectId: number) => {
    if (0 < subjectId) {
      const chartsCopy = Object.assign({}, charts);
      const chart = chartsCopy[subjectId];
      if (null == chart) {
        chartsCopy[subjectId] = {
          index: Object.keys(charts).length + 1,
          hidden: false,
          subjectId: subjectId
        };
      } else {
        chart.hidden = false;
      }
      setCharts(chartsCopy);
    }
    setSelectedSubject(subjectId);
  };

  const hideChart = (subjectId: number) => {
    const chartsCopy = Object.assign({}, charts);
    chartsCopy[subjectId]["hidden"] = true;
    setCharts(chartsCopy);
  };

  const subjectSelect = () => {
    if (null == selectedProject) {
      return <React.Fragment>Please select a project.</React.Fragment>;
    } else if (1 > subjects.length) {
      return <React.Fragment>No groups for this project.</React.Fragment>;
    } else {
      const unit_code = unit_codes[props.unitOfAnalysis];
      return (
        <FloatLabel>
          <Dropdown
            id={`${props.unitOfAnalysis}_list`}
            value={selectedSubject}
            options={subjects}
            onChange={evt => {
              selectSubject(evt.target.value);
            }}
            optionLabel="name"
            optionValue="id"
            placeholder={t(`${props.unitOfAnalysis}}_list`)}
          />
          <label htmlFor={`${props.unitOfAnalysis}_list`}>
            {t(`${props.unitOfAnalysis}_list`)}
          </label>
        </FloatLabel>
      );
    }
  };

  const projectSelect = () => {
    if (null == projects || 0 == projects.length) {
      return <Skeleton className="mb-2" />;
    } else if (1 < projects.length) {
      return (
        <FloatLabel>
          <Dropdown
            id="project_list"
            value={selectedProject}
            options={projects}
            onChange={evt => {
              setSelectedProject(evt.target.value);
            }}
            optionLabel="name"
            optionValue="id"
            placeholder={t("projects_list")}
          />
          <label htmlFor="project_list">{t("projects_list")}</label>
        </FloatLabel>
      );
    } else {
      return (
        <React.Fragment>
          Data for <strong>{projects[0].name}</strong>
        </React.Fragment>
      );
    }
  };

  const closeForResearch = agree => {
    if (agree) {
      setForResearch(!forResearch);
    }
    setForResearchOpen(false);
  };

  const forResearchBlock =
    null == props.forResearch && (user.is_admin || user.is_instructor || user.researcher) ? (
      <Col xs={6}>
        <InputSwitch
          checked={forResearch}
          id="for_research"
          name="for_research"
          itemID="for_research"
          inputId="for_research"
          onChange={() => setForResearchOpen(true)}
        />
        <label htmlFor="for_research">{t("consent_switch")}</label>
        <ConfirmDialog isOpen={forResearchOpen} closeFunc={closeForResearch} />
      </Col>
    ) : null;

  const closeAnonymize = agree => {
    if (agree) {
      setAnonymize(!anonymize);
    }
    setAnonymizeOpen(false);
  };

  const anonymizeBlock =
    ( null == props.anonymize && (user.is_admin || user.is_instructor) )  ? (
      <Col xs={6}>
        <InputSwitch
          checked={anonymize}
          id="anonymize"
          inputId="anonymize"
          itemID="anonymize"
          name="anonymize"
          onChange={() => setAnonymizeOpen(true)}
          disabled={2 > projects.length}
        />
        <label htmlFor="anonymize">{t("anon_switch")}</label>
        <ConfirmDialog isOpen={anonymizeOpen} closeFunc={closeAnonymize} />
      </Col>
    ) : null;

  return (
    <Container>
      <Row>
        {forResearchBlock}
        {anonymizeBlock}
      </Row>
      <Row>
        <Col xs={12} sm={6}>
          {projectSelect()}
        </Col>
        <Col xs={12} sm={6}>
          {subjectSelect()}
        </Col>
      </Row>
      <Row>
        <Col xs={12}>
          <Panel>
            {Object.values(charts)
              .sort((a, b) => {
                a.index - b.index;
              })
              .map(chart => {
                return (
                  <SubjectChart
                    key={chart.index}
                    subjectId={chart.subjectId}
                    projectId={selectedProject}
                    unitOfAnalysis={props.unitOfAnalysis}
                    forResearch={forResearch}
                    anonymize={anonymize}
                    hideFunc={() => hideChart(chart.subjectId)}
                    hidden={chart.hidden}
                  />
                );
              })}
          </Panel>
        </Col>
      </Row>
    </Container>
  );
}
