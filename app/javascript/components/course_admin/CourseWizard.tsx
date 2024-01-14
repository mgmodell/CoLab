import React, { useState } from "react";
import { Outlet, Route, Routes, useNavigate } from "react-router-dom";
//Redux store stuff


import { useTypedSelector } from "../infrastructure/AppReducers";

const CourseUsersList = React.lazy(() => import("./CourseUsersList"));
import { useTranslation } from "react-i18next";
import { Course } from "./CourseDataAdmin";
import { Panel } from "primereact/panel";
import { Steps } from "primereact/steps";
import { Col, Container, Row } from "react-grid-system";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { Button } from "primereact/button";
import { RadioButton } from "primereact/radiobutton";

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

  const [instructorIsYou, setInstructorIsYou] = useState(true);
  const navigate = useNavigate();

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
      disabled: props.course.name === "" || props.course.number === "",
      element: (
        <Panel header={t('wizard.instructor_ttl')} >
          <Container>
            <Row>
              <Col sm={12}>
                <p>
                  {t('wizard.instructor_is_you_desc')}
                </p>

              </Col>
            </Row>
            <Row>
              <Col sm={6}>
                <RadioButton
                  name='instrutor-is-you'
                  inputId="instrutor-is-you-yes"
                  value={true}
                  onChange={event => {
                    setInstructorIsYou(true);
                  }}
                  checked={instructorIsYou}
                />
                <label htmlFor="instrutor-is-you-yes">
                  &nbsp;{t('wizard.inst_is_you_yes_rdo')}
                </label>

              </Col>
              <Col sm={6}>
                <RadioButton
                  name='instrutor-is-you'
                  inputId="instrutor-is-you-no"
                  value={true}
                  onChange={event => {
                    setInstructorIsYou(false);
                  }}
                  checked={!instructorIsYou}
                />
                <label htmlFor="instrutor-is-you-no">
                  &nbsp;{t('wizard.inst_is_you_no_rdo')}
                </label>

              </Col>
            </Row>
            <Row>
              <Col sm={12}>
                {t('wizard.instructor_additional')}
              </Col>
            </Row>
          </Container>
        </Panel>
      )
    },
    {
      label: t('wizard.dates_ttl'),
    },
    {
      label: t('wizard.confirm_save_ttl'),
      disabled: props.course.start_date === null || props.course.end_date === null,
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
      <Button
        label={t('wizard.advanced_switch')}
        onClick={() => {
          navigate('../');
        }}
      />

      {0 < activeStep && (steps.length) > activeStep ? (
        <Button
          iconPos={'left'}
          icon={'pi pi-chevron-left'}
          label={t('wizard.prev_btn')}
          onClick={() => {
            setActiveStep(activeStep - 1);
          }}
        />
      ) : null}
      {(steps.length - 1) > activeStep ? (
        <Button
          iconPos={'right'}
          icon={'pi pi-chevron-right'}
          label={t('wizard.next_btn')}
          onClick={() => {
            if (steps[activeStep + 1].disabled === false) {
              setActiveStep(activeStep + 1);
            }
          }}
          disabled={steps[activeStep + 1].disabled}
        />
      ) : (
        <Button
          label={t('wizard.save_btn')} l
          onClick={() => {
            props.saveCourseFunc();
          }}
        />

      )

      }
    </Panel>
  );
}
