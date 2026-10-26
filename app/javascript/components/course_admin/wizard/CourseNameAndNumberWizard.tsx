import { InputText } from "primereact/inputtext";
import { Editor } from "primereact/editor";
import React from "react";
import { Col, Container, Row } from "react-grid-system";
import { useTranslation } from "react-i18next";
import { ICourse } from "../CourseDataAdmin";
import EditorToolbar from "../../toolbars/EditorToolbar";

type Props = {
  course: ICourse;
  setCourseFunc: (course: ICourse) => void;
};

export default function CourseNameAndNumberWizard(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);

  return (
    <Container>
      <Row>
        <Col sm={12}>
          <p>{t("wizard.name_number_desc")}</p>
        </Col>
      </Row>
      <Row>
        <Col sm={6}>
          <InputText
            placeholder="Course Name"
            id="course-name"
            value={props.course.name}
            onChange={event => {
              props.setCourseFunc({
                ...props.course,
                name: event.target.value
              });
            }}
          />
        </Col>
        <Col sm={6}>
          <InputText
            placeholder="Course Number"
            id="course-number"
            value={props.course.number}
            onChange={event => {
              props.setCourseFunc({
                ...props.course,
                number: event.target.value
              });
            }}
          />
        </Col>
      </Row>
      <Row>
        <Col sm={12}>
          <p>{t("wizard.course_description_desc")}</p>
        </Col>
        <Col sm={12}>
          <Editor
            placeholder="Course Description"
            id="course-description"
            aria-label="Course Description"
            value={props.course.description}
            headerTemplate={<EditorToolbar />}
            onTextChange={event => {
              if ('user' !== event.source) {
                return;
              }
              props.setCourseFunc({
                ...props.course,
                description: null === event.htmlValue ? "" : event.htmlValue
              });
            }}
          />
        </Col>
      </Row>
    </Container>
  );
}
