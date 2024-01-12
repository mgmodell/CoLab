import React, { useState } from "react";
import { Outlet, Route, Routes } from "react-router-dom";
//Redux store stuff


import { useTypedSelector } from "../infrastructure/AppReducers";

const CourseUsersList = React.lazy(() => import("./CourseUsersList"));
import { useTranslation } from "react-i18next";
import { Course } from "./CourseDataAdmin";
import { Panel } from "primereact/panel";
import { Steps } from "primereact/steps";
import { Col, Container, Row } from "react-grid-system";
import { InputText } from "primereact/inputtext";
import { Message } from "primereact/message";
import { C } from "@fullcalendar/core/internal-common";
import { InputTextarea } from "primereact/inputtextarea";

type Props = {
  course: Course;
  setCourseValueFunc: (field: string, value: Date | string | number) => void;
  saveCourseFunc: () => void;
}

export default function CourseWizard(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);

  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const steps = [
    {
      label: t('wizard.name_number_ttl'),
      element: (
        <Panel header={t('wizard.name_number_ttl')} >
          <Container>
            <Row>
              <Col sm={12}>
                <p>
                  {t('wizard.name_number_desc')}
                </p>

              </Col>
            </Row>
            <Row>
              <Col sm={6}>
                <InputText
                  placeholder="Course Name"
                  id="course-name"
                  value={props.course.name}
                  onChange={event => {
                    props.setCourseValueFunc('name', event.target.value);
                  }}
                />
              </Col>
              <Col sm={6}>

                <InputText
                  placeholder="Course Number"
                  id="course-number"
                  value={props.course.number}
                  onChange={event => {
                    props.setCourseValueFunc('number', event.target.value);
                  }}
                />
              </Col>

            </Row>
            <Row>
              <Col sm={12}>
                <p>
                  {t('wizard.course_description_desc')}
                </p>

              </Col>
              <Col sm={12}>
                <InputTextarea
                  placeholder="Course Description"
                  id="course-description"
                  value={props.course.description}
                  onChange={event => {
                    props.setCourseValueFunc('description', event.target.value);
                  }}
                  rows={5}
                  cols={30}
                  autoResize={true}
                />
              </Col>

            </Row>

          </Container>
        </Panel>
      )
    },
    {
      label: t('wizard.instructor_ttl'),
    },
    {
      label: t('wizard.dates_ttl'),
    },
    {
      label: t('wizard.confirm_save_ttl'),
    }
  ];

  const [activeStep, setActiveStep] = useState(0);

  return (
    <Panel>
      <Steps model={steps} activeIndex={activeStep}
        onSelect={(e) => {
          setActiveStep(e.index);
        }}
        readOnly={false}
      />
      {steps[activeStep].element}
    </Panel>
  );
}
