import React, { useEffect, useState } from "react";

import { useNavigate } from "react-router";
//Redux store stuff

import { useTypedSelector } from "../../infrastructure/AppReducers";

const CourseUsersList = React.lazy(() => import("../CourseUsersList"));
import { useTranslation } from "react-i18next";
import { ICourse } from "../CourseDataAdmin";
import { Panel } from "primereact/panel";
import { Steps } from "primereact/steps";
import { Button } from "primereact/button";
import CourseNameAndNumberWizard from "./CourseNameAndNumberWizard";
import CourseDatesWizard from "./CourseDatesWizard";
import CourseSummaryWizard from "./CourseSummaryWizard";

type Props = {
  course: ICourse;
  setCourseFunc: (course: ICourse) => void;
  saveCourseFunc: () => void;
};

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
  const [activeStep, setActiveStep] = useState(0);

  useEffect(() => {
    if (isNaN(props.course.id)) {
      if ("" === props.course.name && "" === props.course.number) {
        setActiveStep(0);
      } else {
        setActiveStep(1);
      }
    } else {
      setActiveStep(2);
    }
  }, []);

  const steps = [
    {
      label: t("wizard.name_number_lbl"),
      title: t("wizard.name_number_ttl"),
      saveValid: isNaN(props.course.id),
      element: (
        <CourseNameAndNumberWizard
          course={props.course}
          setCourseFunc={props.setCourseFunc}
        />
      )
    },
    {
      label: t("wizard.dates_lbl"),
      title: t("wizard.dates_ttl"),
      saveValid: isNaN(props.course.id),
      disabled:
        isNaN(props.course.id) &&
        (props.course.name === "" || props.course.number === ""),
      element: (
        <CourseDatesWizard
          course={props.course}
          setCourseFunc={props.setCourseFunc}
        />
      )
    },
    {
      label: isNaN(props.course.id)
        ? t("wizard.confirm_create_lbl")
        : t("wizard.confirm_save_lbl"),
      title: t("wizard.confirm_save_ttl"),
      saveValid: true,
      disabled:
        null === props.course.start_date ||
        null === props.course.end_date ||
        isNaN(props.course.start_date.getTime()) ||
        isNaN(props.course.end_date.getTime()),
      element: (
        <CourseSummaryWizard
          course={props.course}
          setCourseFunc={props.setCourseFunc}
          goToStepFunc={setActiveStep}
        />
      )
    },
    {
      label: t("wizard.instructors_lbl"),
      title: t("wizard.instructors_ttl"),
      saveValid: true,
      disabled: isNaN(props.course.id)
    },
    {
      label: t("wizard.project_lbl"),
      title: t("wizard.project_ttl"),
      saveValid: true,
      disabled: isNaN(props.course.id)
    },
    {
      label: t("wizard.readings_lbl"),
      title: t("wizard.readings_ttl"),
      saveValid: true,
      disabled: isNaN(props.course.id)
    },
    {
      label: t("wizard.students_lbl"),
      title: t("wizard.students_ttl"),
      saveValid: true,
      disabled: isNaN(props.course.id)
    }
  ];

  const savedSteps = steps.filter(step => {
    return step.saveValid;
  });

  return (
    <Panel>
      <Steps
        model={isNaN(props.course.id) ? steps : savedSteps}
        activeIndex={activeStep}
        onSelect={e => {
          setActiveStep(e.index);
        }}
        readOnly={false}
      />
      {/*
        The following statement is ugly but it is compact and functional.
        1. Check which array I should use (ternary)
        2. index into that array with the activeStep
        3. get the title key from that step
      */}
      <Panel
        header={(isNaN(props.course.id) ? steps : savedSteps)[activeStep].title}
      >
        {steps[activeStep].element}
      </Panel>
      <Button
        label={t("wizard.advanced_switch")}
        onClick={() => {
          navigate("../");
        }}
      />

      {0 < activeStep && steps.length > activeStep ? (
        <Button
          iconPos={"left"}
          icon={"pi pi-chevron-left"}
          label={t("wizard.prev_btn")}
          onClick={() => {
            setActiveStep(activeStep - 1);
          }}
        />
      ) : null}
      {steps.length - 1 > activeStep ? (
        <Button
          iconPos={"right"}
          icon={"pi pi-chevron-right"}
          label={t("wizard.next_btn")}
          onClick={() => {
            if (steps[activeStep + 1].disabled === false) {
              setActiveStep(activeStep + 1);
            }
          }}
          disabled={steps[activeStep + 1].disabled}
        />
      ) : (
        <Button
          label={t("wizard.save_btn")}
          onClick={() => {
            props.saveCourseFunc();
          }}
        />
      )}
    </Panel>
  );
}
