import React from "react";

import { Panel } from "primereact/panel";
import { BingoBoard } from "./BingoBuilder";

type Props = {
  board: BingoBoard;
};

export default function BingoBoard(props: Props) {
  const gameDate = new Date(props.board.bingo_game.end_date);
  return (
    <Panel>
      <hr />
      <center>
        {props.board.bingo_game.topic}&nbsp; ({gameDate.toDateString()})
      </center>
      <hr />
        {props.board.initialised ? (
          <table>
            <tbody>
              <tr>
                {props.board.bingo_cells.map((cell, index) => {
                  const rowBreak = index % props.board.bingo_game.size === 0 ?
                    <tr></tr> : null;
                  return (
                    <td key={index}>
                      <center>
                        <br />
                        <br />
                        {cell.concept.name}
                        <br />
                        <br />
                      </center>
                    </td>
                  )
                })}
              </tr>
            </tbody>
          </table>

        ) : null}
      <hr />
    </Panel>
  );
}
