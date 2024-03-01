import React from "react";

import { Panel } from "primereact/panel";
import { IBingoBoard } from "./BingoBuilder";

type Props = {
  board: IBingoBoard;
};

export default function BingoBoard(props: Props) {
  const gameDate = new Date(props.board.bingo_game.end_date);

  const tableCells = props.board.initialised ? props.board.bingo_cells.map((cell, index) => {
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
  }) : null;

  const tableRows = [];
  if (props.board.initialised) {
    for (let i = 0; i < tableCells.length; i+=props.board.bingo_game.size) {
      tableRows.push(<tr>
        {tableCells.slice(i, i+props.board.bingo_game.size)}
      </tr>);
    }
  }

  return (
    <Panel>
      <hr />
      <center>
        {props.board.bingo_game.topic}&nbsp; ({gameDate.toDateString()})
      </center>
      <hr />
      {props.board.initialised ? (
        <table className="bingoBoardTable">
          <tbody>
            { tableRows }
          </tbody>
        </table>

      ) : null}
      <hr />
    </Panel>
  );
}
