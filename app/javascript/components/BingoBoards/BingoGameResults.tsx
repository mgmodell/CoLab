import React, { useState } from "react";
import { useTranslation } from "react-i18next";

import { TabView, TabPanel } from "primereact/tabview";
import { Button } from "primereact/button";
import { Dialog } from "primereact/dialog";
import { Container, Row, Col } from "react-grid-system";

import ScoredGameDataTable from "./ScoredGameDataTable";

interface ICandidate {
  id: number;
  concept: string;
  definition: string;
  term: string;
  feedback: string;
  feedback_id: number;
}

type Props = {
  open: boolean;
  student: string;
  board: Array<Array<string>>;
  score: number;
  close: Function;
  candidates: Array<ICandidate>;
};

export default function BingoGameResults(props: Props) {
  const { t } = useTranslation("bingo_games");
  const [curTab, setCurTab] = useState(0);

  const renderBoard = board => {
    if (board == null || board.length == 0) {
      return <p>{t("results.no_board")}</p>;
    } else {
      return (
        <Container>
          <Row>
            <Col xs={12}>
              <b>{t("results.score_label")}: </b>
              {null == props.score ? t("results.unscored") : props.score}
            </Col>
          </Row>

          <table>
            <tbody>
              {props.board.map((row, r_ind) => (
                <tr key={r_ind}>
                  {row.map((col, c_ind) => (
                    <td key={r_ind + "_" + c_ind}>{col}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </Container>
      );
    }
  };

  return (
    <Dialog
      header={<span>{t("results.for_student", { student: props.student })}</span>}
      visible={props.open}
      onHide={() => props.close()}
      footer={
        <Button
          onClick={event => {
            props.close();
          }}
        >
          {t("results.done_btn")}
        </Button>
      }
    >
      <TabView
        activeIndex={curTab}
        onTabChange={event => {
          setCurTab(event.index);
        }}
      >
        <TabPanel header={t("results.scored_results_tab")}>
          {renderBoard(props.board)}
        </TabPanel>
        <TabPanel header={t("results.answer_key_tab")}>
          <ScoredGameDataTable candidates={props.candidates} />
        </TabPanel>
      </TabView>
    </Dialog>
  );
}
