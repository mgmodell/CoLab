import { InputText } from 'primereact/inputtext';
import { InputTextarea } from 'primereact/inputtextarea';
import React from 'react';
import { Col, Container, Row } from 'react-grid-system';
import { useTranslation } from 'react-i18next';
import { ICourse } from '../CourseDataAdmin';

type Props = {
  course: ICourse
  setCourseFunc: (course: ICourse) => void;
};

export default function CourseNameAndNumberWizard(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);

  return (
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
                props.setCourseFunc({ ...props.course, name: event.target.value });
              }}
            />
          </Col>
          <Col sm={6}>

            <InputText
              placeholder="Course Number"
              id="course-number"
              value={props.course.number}
              onChange={event => {
                props.setCourseFunc({ ...props.course, number: event.target.value });
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
                props.setCourseFunc({ ...props.course, description: event.target.value });
              }}
              rows={5}
              cols={30}
              autoResize={true}
            />
          </Col>

        </Row>

      </Container>

  )
}