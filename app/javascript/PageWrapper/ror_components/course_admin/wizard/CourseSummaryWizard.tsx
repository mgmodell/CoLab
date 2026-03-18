import React from 'react';

import parse from 'html-react-parser';
import { DateTime } from 'luxon';

import { Col, Container, Row } from 'react-grid-system';
import { useTranslation } from 'react-i18next';

import { ICourse } from '../CourseDataAdmin';

type Props = {
  course: ICourse
  setCourseFunc: (course: ICourse) => void;
  goToStepFunc: (step: number) => void;
};

export default function CourseSummaryWizard(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);

  return (
        <Container>
          <Row>
            <Col sm={12}>
              <p>
                {t('wizard.confirm_save_desc')}
              </p>

            </Col>
          </Row>
          <Row onClick={() => {
            props.goToStepFunc(0);
          }}>
            <Col sm={3}>
              <p>
                {t('wizard.confirm_save_name')}
              </p>
            </Col>
            <Col sm={3}>
              <p>
                {props.course.name}
              </p>
            </Col>
            <Col sm={3}>
              <p>
                {t('wizard.confirm_save_number')}
              </p>
            </Col>
            <Col sm={3}>
              <p>
                {props.course.number}
              </p>
            </Col>
          </Row>
          <Row onClick={() => {
            props.goToStepFunc(0);
          }}>

            <Col sm={3}>
              <p>
                {t('wizard.confirm_save_description')}
              </p>
            </Col>
            <Col sm={9}>
              <p>
                {props.course.description}
              </p>
            </Col>
          </Row>
          <Row onClick={() => {
            props.goToStepFunc(1);
          }}>
            <Col sm={12}>
              <p>
                {
                  parse(
                    t('wizard.confirm_save_dates',
                      {
                        open_date: DateTime.fromISO( props.course.start_date ),
                        close_date: props.course.end_date?.toLocaleDateString(),
                        timezone: props.course.timezone
                      })
                  )
                }
              </p>

            </Col>
          </Row>
        </Container>

  )
}