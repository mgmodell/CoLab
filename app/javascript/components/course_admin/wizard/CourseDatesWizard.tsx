import React from "react";

import { useTranslation } from "react-i18next";
import parse from "html-react-parser";

import { Inplace, InplaceContent, InplaceDisplay } from "primereact/inplace";

import { Col, Container, Row } from "react-grid-system";

import { ICourse } from "../CourseDataAdmin";
import { Calendar } from "primereact/calendar";
import { useTypedSelector } from "../../infrastructure/AppReducers";
import { Dropdown } from "primereact/dropdown";
import { Skeleton } from "primereact/skeleton";

type Props = {
  course: ICourse;
  setCourseFunc: (course: ICourse) => void;
};

export default function CourseDatesWizard(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);

  const timezones = useTypedSelector(
    state => state.context.lookups["timezones"]
  );

  return (
    <Container>
      <Row>
        <Col sm={12}>
          <p>{t("wizard.dates_desc")}</p>
        </Col>
      </Row>
      <Row>
        <Col sm={12}>
          <Calendar
            id="course_dates"
            selectionMode={"range"}
            value={[props.course.start_date, props.course.end_date]}
            placeholder="Select a Date Range"
            showIcon={true}
            onChange={event => {
              const changeTo = event.value;
              if (null === changeTo) {
                return;
              } else if (2 === changeTo.length) {
                props.setCourseFunc({
                  ...props.course,
                  start_date: changeTo[0],
                  end_date: changeTo[1]
                });
              } else {
                props.setCourseFunc({
                  ...props.course,
                  start_date: changeTo[0],
                  end_date: changeTo[0]
                });
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
                {parse(
                  t("wizard.dates_timezone", {
                    timezone: props.course.timezone
                  })
                )}
              </p>
            </InplaceDisplay>
            <InplaceContent>
              {timezones.length > 0 ? (
                <Dropdown
                  id="course_timezone"
                  value={props.course.timezone}
                  options={timezones}
                  onChange={event => {
                    props.setCourseFunc({
                      ...props.course,
                      timezone: event.target.value
                    });
                  }}
                  optionLabel="name"
                  optionValue="name"
                  placeholder="Select a Time Zone"
                />
              ) : (
                <Skeleton className={"mb-2"} height={"2rem"} />
              )}
            </InplaceContent>
          </Inplace>
        </Col>
      </Row>
    </Container>
  );
}
