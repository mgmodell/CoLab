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
import { FloatLabel } from "primereact/floatlabel";
import { utcAdjustDate, utcAdjustEndDate } from "../../infrastructure/Utilities";
import { co } from "@fullcalendar/core/internal-common";

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
      <FloatLabel>
        <Calendar
          id="course_start_date"
          inputId="course_start_date"
          value={utcAdjustDate(props.course.start_date)}
          onChange={event => {
            const changeTo = event.value;
            props.setCourseFunc({
              ...props.course,
              start_date: changeTo
            });
          }
          }
          showOnFocus={false}
          showIcon={true}
        />
        <label htmlFor="course_start_date">{t('start_date_lbl')}</label>
      </FloatLabel>
      {t('date_to_lbl')}
      <FloatLabel>
        <Calendar
          id="course_end_date"
          inputId="course_end_date"
          value={utcAdjustEndDate(props.course.end_date)}
          onChange={event => {
            const changeTo = event.value;
            props.setCourseFunc({
              ...props.course,
              end_date: changeTo
            });
          }
          }
          showOnFocus={false}
          showIcon={true}
        />
        <label htmlFor="course_end_date">{t('end_date_lbl')}</label>
      </FloatLabel>
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
