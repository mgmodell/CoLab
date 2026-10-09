import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router";
import { useDispatch } from "react-redux";
import { Button } from "primereact/button";
import { Panel } from "primereact/panel";
import { Skeleton } from "primereact/skeleton";
import { Container, Row, Col } from "react-grid-system";
import { useTranslation } from "react-i18next";

import { useTypedSelector } from "../infrastructure/AppReducers";
import { endTask, startTask } from "../infrastructure/StatusSlice";
import {
  DATETIME_SHORT,
  formatZonedDateTime,
  parseISO
} from "../infrastructure/TemporalSettings";

interface StudentProject {
  project: {
    name: string;
    description: string;
    course_name: string;
    completion_percentage: number;
  };
  group: {
    name: string;
    users: Array<{ id: number; name: string }>;
    perspective_points: number;
    faultline_strength: number;
  };
  next_check_in: string | null;
}

export default function StudentProjectInfo() {
  const infoUrl = useTypedSelector(
    state => state.context.endpoints.home?.studentProjectInfoUrl
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t } = useTranslation("projects");
  const { projectId } = useParams();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [data, setData] = useState<StudentProject | null>(null);
  const [loadFailed, setLoadFailed] = useState(false);

  useEffect(() => {
    if (!endpointsLoaded || !projectId || !infoUrl) {
      return;
    }

    setData(null);
    setLoadFailed(false);
    dispatch(startTask());
    axios
      .get(`${infoUrl}${projectId}.json`)
      .then(response => setData(response.data))
      .catch(() => setLoadFailed(true))
      .finally(() => dispatch(endTask()));
  }, [dispatch, endpointsLoaded, infoUrl, projectId]);

  if (loadFailed) {
    return (
      <Panel>
        <p>{t("show.load_error")}</p>
        <Button
          label={t("show.back_to_tasks")}
          onClick={() => navigate("/home")}
        />
      </Panel>
    );
  }

  if (!data) {
    return <Skeleton className="mb-2" height="10rem" />;
  }

  return (
    <Panel>
      <Container>
        <Row>
          <Col xs={12}>
            <h1>{data.project.name}</h1>
            <p>{data.project.course_name}</p>
            <h2>{t("description_lbl")}</h2>
            <p>{data.project.description}</p>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <h2>{t("show.team")}</h2>
            <p>{data.group.name}</p>
            <ul>
              {data.group.users.map(member => (
                <li key={member.id}>{member.name}</li>
              ))}
            </ul>
          </Col>
        </Row>
        <Row>
          <Col xs={12} md={6}>
            <h2>{t("show.perspective_points")}</h2>
            <p>{data.group.perspective_points}</p>
          </Col>
          <Col xs={12} md={6}>
            <h2>{t("show.faultline_strength")}</h2>
            <p>{data.group.faultline_strength}</p>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <h2>{t("show.next_check_in")}</h2>
            <p>
              {data.next_check_in
                ? formatZonedDateTime(
                    parseISO(data.next_check_in),
                    DATETIME_SHORT
                  )
                : t("show.no_next_check_in")}
            </p>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <h2>{t("show.check_in_completion")}</h2>
            <p>{data.project.completion_percentage}%</p>
          </Col>
        </Row>
        <Button
          label={t("show.back_to_tasks")}
          onClick={() => navigate("/home")}
        />
      </Container>
    </Panel>
  );
}
