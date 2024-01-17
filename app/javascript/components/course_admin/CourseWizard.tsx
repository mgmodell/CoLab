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
import { Calendar } from "primereact/calendar";
import { Inplace, InplaceContent, InplaceDisplay } from "primereact/inplace";
import { Dropdown } from "primereact/dropdown";
import { Skeleton } from "primereact/skeleton";
import parse from 'html-react-parser'


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

  const timezones = useTypedSelector(
    state => state.context.lookups["timezones"]
  );

  const [instructorIsYou, setInstructorIsYou] = useState(true);
  const navigate = useNavigate();

  const steps = [
    {
      label: t('wizard.name_number_lbl'),
      title: t('wizard.name_number_ttl'),
      saveValid: true,
      element: (
        <>
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
        </>
      )
    },
    {
      label: t('wizard.dates_lbl'),
      title: t('wizard.dates_ttl'),
      saveValid: true,
      disabled: isNaN(props.course.id) && props.course.name === '' && props.course.number === '',
      element: (
        <>
          <Container>
            <Row>
              <Col sm={12}>
                <p>
                  {t('wizard.dates_desc')}
                </p>

              </Col>
            </Row>
            <Row>
              <Col sm={12}>
                <Calendar
                  id="course_dates"
                  selectionMode={'range'}
                  value={[props.course.start_date, props.course.end_date]}
                  placeholder="Select a Date Range"
                  onChange={event => {
                    const changeTo = event.value;
                    console.log('change', event);
                    if (null !== changeTo && changeTo.length > 1) {
                      props.setCourseValueFunc('start_date', changeTo[0]);
                      props.setCourseValueFunc('end_date', changeTo[1]);

                    }
                  }}
                />
              </Col>
            </Row>
            <Row>
              <Col sm={12}>
                <Inplace closable>
                  <InplaceDisplay>
                    <p>
                      {parse( t('wizard.dates_timezone', { timezone: props.course.timezone }) )}
                    </p>
                  </InplaceDisplay>
                  <InplaceContent>
                    {timezones.length > 0 ? (
                      <Dropdown id="course_timezone"
                        value={props.course.timezone}
                        options={timezones}
                        onChange={event => {
                          props.setCourseValueFunc('timezone', event.target.value);
                        }}
                        optionLabel="name"
                        optionValue="name"
                        placeholder="Select a Time Zone"
                      />
                    ) : (
                      <Skeleton className={"mb-2"} height={'2rem'} />
                    )}

                  </InplaceContent>
                </Inplace>
              </Col>
            </Row>
          </Container>
        </>
      )
    },
    {
      label: t('wizard.confirm_save_lbl'),
      title: t('wizard.confirm_save_ttl'),
      saveValid: false,
      disabled: props.course.start_date === null || props.course.end_date === null,
    },
    {
      label: t('wizard.instructors_lbl'),
      title: t('wizard.instructors_ttl'),
      saveValid: true,
      disabled: isNaN( props.course.id ),
    },
    {
      label: t('wizard.project_lbl'),
      title: t('wizard.project_ttl'),
      saveValid: true,
      disabled: isNaN( props.course.id ),
    },
    {
      label: t('wizard.readings_lbl'),
      title: t('wizard.readings_ttl'),
      saveValid: true,
      disabled: isNaN( props.course.id ),
    },
    {
      label: t('wizard.students_lbl'),
      title: t('wizard.students_ttl'),
      saveValid: true,
      disabled: isNaN( props.course.id ),
    }
  ];

  const [activeStep, setActiveStep] = useState(0);
  const savedSteps = steps.filter( (step)=>{
    return step.saveValid;
  });

  return (
    <Panel>
      <Steps
        model={ isNaN( props.course.id ) ? steps : savedSteps }
        activeIndex={activeStep}
        onSelect={(e) => {
          setActiveStep(e.index);
        }}
        readOnly={false}
      />
      { /*
        The following statement is ugly but it is compact and functional.
        1. Check which array I should use (ternary)
        2. index into that array with the activeStep
        3. get the title key from that step
      */}
      <Panel header={( isNaN( props.course.id ) ? steps : savedSteps ) [activeStep].title} >
        {steps[activeStep].element}
      </Panel>
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
            console.log(steps[activeStep + 1], activeStep)
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
