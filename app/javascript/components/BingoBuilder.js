import React from "react";
import BingoBoard from "./BingoBoard";
import PropTypes from "prop-types";
import { withTheme } from "@material-ui/core/styles";
import { MuiThemeProvider, createMuiTheme } from "@material-ui/core/styles";
import Chip from "@material-ui/core/Chip";
import Link from "@material-ui/core/Link";
import Paper from "@material-ui/core/Paper";
import Button from "@material-ui/core/Button";
import GridList, { GridListTile } from "@material-ui/core/GridList";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";
const styles = createMuiTheme({
  typography: {
    useNextVariants: true
  }
});
class BingoBuilder extends React.Component {
  constructor(props) {
    super(props);
    var endDate = new Date(this.props.endDateStr);
    this.state = {
      saveStatus: "",
      concepts: [],
      endDate: endDate,
      board: {
        initialised: false,
        bingo_cells: [],
        iteration: 0,
        bingo_game: {
          size: 5,
          topic: "no game"
        }
      }
    };
    this.getWorksheet = this.getWorksheet.bind(this);
    this.getPrintableBoard = this.getPrintableBoard.bind(this);
  }
  randomizeTiles() {
    var selectedConcepts = {};
    var iteration = this.state.board.iteration + 1;
    var counter = 0;
    while (
      Object.keys(selectedConcepts).length <
        this.state.board.bingo_cells.length &&
      counter < 100
    ) {
      counter++;
      var sample = this.state.concepts[
        Math.floor(Math.random() * this.state.concepts.length)
      ];

      selectedConcepts[sample.id] = sample;
    }
    //Repurpose localConcepts
    var localConcepts = Object.values(selectedConcepts);
    var size = this.state.board.bingo_game.size;
    var cells = this.state.board.bingo_cells;
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        var i = row * 5 + col;
        var concept = localConcepts[i];

        var mid = Math.round(size / 2) - 1;
        var midSquare = row == mid && col == mid && mid != size / 2;

        concept = midSquare ? { id: 0, name: "*" } : concept;

        cells[i].row = row;
        cells[i].column = col;
        cells[i].selected = midSquare ? true : false;
        cells[i].concept_id = concept.id;
        cells[i].concept = concept;
      }
    }
    var board = this.state.board;
    board.bingo_cells = cells;
    board.iteration = iteration;
    board.initialised = true;
    this.setState({
      board: board
    });
  }

  getConcepts(callbackFunc) {
    fetch(this.props.conceptsUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        this.setState(
          {
            concepts: data
          },
          callbackFunc
        );
      });
  }
  getBoard() {
    fetch(this.props.boardUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        data.initialised = data.id != null;
        data.iteration = 0;
        this.setState({
          board: data
        });
        //}, this.randomizeTiles );
      });
  }
  saveBoard() {
    var board = this.state.board;
    board.bingo_cells_attributes = board.bingo_cells;
    delete board.bingo_cells;
    fetch(this.props.boardSaveUrl + ".json", {
      method: "PATCH",
      credentials: "include",
      body: JSON.stringify({ bingo_board: this.state.board }),
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return {};
        }
      })
      .then(data => {
        data.initialised = true;
        data.iteration = 0;
        if (data.id > 0) {
          this.setState({
            saveStatus: "Your board has been saved",
            board: data
          });
        } else if ((data.id = -42)) {
          board.bingo_cells = board.bingo_cells_attributes;
          board.id = -42;
          board.iteration = 0;
          this.setState({
            saveStatus: "DEMO: Your board would have been saved",
            board: board
          });
        } else {
          board.bingo_cells = board.bingo_cells_attributes;
          this.setState({
            saveStatus: "Save failed. Please try again or contact support",
            board: board
          });
        }
      });
  }
  getWorksheet() {
    open(this.props.worksheetUrl + ".pdf");
  }
  getPrintableBoard() {
    open(this.props.boardUrl + ".pdf");
  }
  componentDidMount() {
    //Let's retrieve any existing board
    this.getConcepts(this.getBoard);
  }
  render() {
    const saveBtn =
      this.state.board.initialised &&
      this.state.board.iteration > 0 &&
      this.state.endDate > new Date() ? (
        <Button variant="contained" onClick={() => this.saveBoard()}>
          Save
        </Button>
      ) : null;
    const printBtn =
      this.state.board.id != null && this.state.board.iteration == 0 ? (
        <React.Fragment>
          <Link onClick={() => this.getPrintableBoard()}>
            Download Playble Bingo Board
          </Link>
          &nbsp;|&nbsp;
        </React.Fragment>
      ) : null;

    const workSheet =
      this.state.board.acceptable <
      this.state.board.size * this.state.board.size ? null : (
        <Link onClick={() => this.getWorksheet()}>
          Download Practice Bingo Board
        </Link>
      );

    return (
      <MuiThemeProvider theme={styles}>
        <Paper square={false}>
          <Paper>
            {this.state.concepts.map(chip => {
              return <Chip key={chip.id} label={chip.name} />;
            })}
          </Paper>
          <br />
          <Button variant="contained" onClick={() => this.randomizeTiles()}>
            Generate New Board
          </Button>
          &nbsp;
          {saveBtn}
          {printBtn}
          {workSheet}
          <div id="bingoBoard" className="mt4">
            <BingoBoard board={this.state.board} />
          </div>
        </Paper>
      </MuiThemeProvider>
    );
  }
}
BingoBuilder.propTypes = {
  endDateStr: PropTypes.string,
  token: PropTypes.string,
  boardUrl: PropTypes.string,
  conceptsUrl: PropTypes.string,
  worksheetUrl: PropTypes.string.isRequired,
  boardSaveUrl: PropTypes.string
};
export default withTheme()(BingoBuilder);
