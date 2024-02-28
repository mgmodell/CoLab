import React, { useState } from "react";

import { TabView, TabPanel } from "primereact/tabview";
import { Button } from "primereact/button";
import { Dialog } from "primereact/dialog";
import { Container, Row, Col } from "react-grid-system";

const ScoredGameDataTable = React.lazy(() => import("./ScoredGameDataTable"));

interface ICandidate {
  id: number;
  concept: string;
  definition: string;
  term: string;
  feedback: string;
  feedback_id: number;
};

type Props = {
  open: boolean;
  student: string;
  board: Array<Array<string>>;
  score: number;
  close: Function;
  candidates: Array<ICandidate>;
};


export default function BingoGameResults(props: Props) {
  const [curTab, setCurTab] = useState(0);

  const renderBoard = board => {
    if (board == null || board.length == 0) {
      return <p>No board available</p>;
    } else {
      return (
        <Container>
          <Row>
            <Col xs={12}>
            <b>Score: </b>
            {null == props.score ? "unscored" : props.score}
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
    header={
      <span>
        Results for {props.student}
      </span>
    }
    visible={props.open}
    onHide={() => props.close()}
    footer={
        <Button onClick={(event) => {props.close()}}>Done</Button>
    }
    >

        <TabView activeIndex={curTab} onTabChange={(event)=>{setCurTab(event.index)}}>
          <TabPanel header={"Scored Results"}>
            {renderBoard(props.board)}
          </TabPanel>
          <TabPanel header={"Answer Key"}>
            <ScoredGameDataTable candidates={props.candidates} />
          </TabPanel>
        </TabView>
    </Dialog>
  );
}
