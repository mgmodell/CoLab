import React from "react";
import Paper from "@mui/material/Paper";
import ImageList from "@mui/material/ImageList";
import ImageListItem from "@mui/material/ImageListItem";

type Props = {
  board: Object;
};

export default function BingoBoard(props: Props) {
  const gameDate = new Date(props.board.bingo_game.end_date);
  return (
    <Paper>
      <hr />
      <center>
        {props.board.bingo_game.topic}&nbsp; ({gameDate.toDateString()})
      </center>
      <hr />
      <ImageList cols={props.board.bingo_game.size} rowHeight="auto">
        {props.board.initialised ? (
          props.board.bingo_cells.map(cell => {
            return (
              <ImageListItem
                key={cell.row + "-" + cell.column + "-" + cell.concept_id}
              >
                <center>
                  <br />
                  <br />
                  {cell.concept.name}
                  <br />
                  <br />
                </center>
              </ImageListItem>
            );
          })
        ) : (
          <ImageListItem />
        )}
      </ImageList>
      <hr />
    </Paper>
  );
}
