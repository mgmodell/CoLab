import React from "react";

import { useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";

//Redux store stuff
import { useTypedSelector } from "../infrastructure/AppReducers";

import { Col, Container, Row } from "react-grid-system";
import parse from "html-react-parser";

interface ICriteria {
  id: number;
  description: string;
  weight: number;
  sequence: number;
  l1_description: string;
  l2_description: string | null;
  l3_description: string | null;
  l4_description: string | null;
  l5_description: string | null;
}

interface IRubricData {
  name: string;
  description: string;
  version: number;
  criteria: Array<ICriteria>;
}

type Props = {
  rubric: IRubricData;
};

const CLEAN_RUBRIC: IRubricData = {
  name: "",
  description: "",
  version: 0,
  criteria: []
};

export default function RubricViewer(props: Props) {
  const endpointSet = "assignment";
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const { assignmentId } = useParams();

  const [t, i18n] = useTranslation(`${endpointSet}s`);

  const evaluation =
    props.rubric !== undefined ? (
      <>
        <Container fluid>
          <Row>
            <Col xs={2}>{t("status.rubric_name")}:</Col>
            <Col xs={4}>{props.rubric.name}</Col>
            <Col xs={2}>{t("status.rubric_version")}:</Col>
            <Col xs={4}>{props.rubric.version}</Col>
          </Row>
        </Container>
        <table>
          <tbody>
            {props.rubric.criteria
              .sort((a: ICriteria, b: ICriteria) => a.sequence - b.sequence)
              .map(criterium => {
                const levels = [
                  criterium.l1_description,
                  criterium.l2_description,
                  criterium.l3_description,
                  criterium.l4_description,
                  criterium.l5_description
                ];
                for (let index = levels.length - 1; index > 0; index--) {
                  if (levels[index] !== null && levels[index].length > 0) {
                    index = -1;
                  } else {
                    levels.pop();
                  }
                }
                const span = 60 / (levels.length + 1);
                const renderedLevels = [];
                let index = 0;
                levels.forEach(levelText => {
                  index++;
                  renderedLevels.push(
                    <td key={`${criterium.id}-${index}`} colSpan={span}>
                      {parse(levelText)}
                    </td>
                  );
                });

                return (
                  <React.Fragment key={criterium.id}>
                    <tr>
                      <td colSpan={70}>
                        <hr />
                      </td>
                    </tr>
                    <tr>
                      <td colSpan={10}>{criterium.description}</td>
                      <td colSpan={span}>{t("status.rubric_minimum")}</td>
                      {renderedLevels}
                    </tr>
                  </React.Fragment>
                );
              })}
            <tr>
              <td colSpan={70}>
                <hr />
              </td>
            </tr>
          </tbody>
        </table>
      </>
    ) : null;

  return evaluation;
}

export { IRubricData, CLEAN_RUBRIC, ICriteria };
