import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
//Redux store stuff
import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";
import Button from "@mui/material/Button";

import { useTranslation } from "react-i18next";
import Grid from "@mui/material/Grid";
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";

import { Panel } from "primereact/panel";

export default function EnrollInCourse(props) {
  const category = "home";
  const dispatch = useDispatch();
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const [t, i18n] = useTranslation(category);
  const { courseId } = useParams();

  const navigate = useNavigate();

  const [courseName, setCourseName] = useState("loading");
  const [courseNumber, setCourseNumber] = useState("loading");

  const [enrollable, setEnrollable] = useState(false);
  const [messageHeader, setMessageHeader] = useState("Enrollment");
  const [message, setMessage] = useState("Loading...");

  const enrollConfirm = (confirm: boolean) => {
    if (confirm) {
      const url = `${endpoints.selfRegUrl}${courseId}.json`;
      axios
        .post(url, {})
        .then(response => {
          // Success!
        })
        .catch(error => {
          console.log("error", error);
        });
    }
    navigate("/");
  };

  const enrollButton = (
    <Button
      disabled={!endpointsLoaded || !enrollable}
      variant="contained"
      onClick={() => {
        enrollConfirm(true);
      }}
    >
      {t("self_enroll")}
    </Button>
  );
  const cancelButton = (
    <Button
      variant="contained"
      onClick={() => {
        enrollConfirm(true);
      }}
    >
      {t("self_enroll_cancel")}
    </Button>
  );

  useEffect(() => {
    if (endpointsLoaded) {
      const url = `${endpoints.selfRegUrl}/${courseId}.json`;
      dispatch(startTask());
      axios
        .get(url, {})
        .then(response => {
          const data = response.data;
          setCourseName(data.course.name);
          setCourseNumber(data.course.number);
          setEnrollable(data.enrollable);
          setMessageHeader(data.message_header);
          setMessage(data.message);
        })
        .catch(error => {
          console.log("error", error);
        })
        .finally(() => {
          dispatch(endTask());
        });
    }
  }, [endpointsLoaded]);

  return (
    <Panel>
      <h1>{t(messageHeader)}</h1>
      <p>
        {t(message, {
          course_name: courseName,
          course_number: courseNumber
        })}
      </p>
      <Grid container>
        <Grid item xs={12} sm={6}>
          {enrollButton}
        </Grid>
        <Grid item xs={12} sm={6}>
          {cancelButton}
        </Grid>
      </Grid>
    </Panel>
  );
}
EnrollInCourse.propTypes = {};
