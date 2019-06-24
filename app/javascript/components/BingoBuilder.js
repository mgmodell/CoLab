import React from "react";
import BingoBoard from "./BingoBoard";
import ConceptChips from "./ConceptChips";
import ScoredGameDataTable from "./ScoredGameDataTable";
import PropTypes from "prop-types";
import { withTheme } from "@material-ui/core/styles";
import { MuiThemeProvider, createMuiTheme } from "@material-ui/core/styles";
import Chip from "@material-ui/core/Chip";
import Link from "@material-ui/core/Link";
import Paper from "@material-ui/core/Paper";
import Button from "@material-ui/core/Button";
import Tabs from "@material-ui/core/Tabs";
import Tab from "@material-ui/core/Tab";
import Typography from "@material-ui/core/Typography";
import GridList, { GridListTile } from "@material-ui/core/GridList";

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
      curTab: "builder",
      candidate_list: null,
      candidates: [],
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
    this.changeTab = this.changeTab.bind(this);
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
  getMyResults() {
    fetch(this.props.resultsUrl + ".json", {
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
        this.setState({
          candidate_list: data.candidate_list,
          candidates: data.candidates
        });
        //}, this.randomizeTiles );
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

  changeTab(event, name) {
    this.setState({
      curTab: name
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
    this.getMyResults();
  }
  render() {
    //This nested ternary operator is ugly, but it works. At some point
    // I need to figure out the right way to do it.
    const saveBtn =
      this.state.endDate < new Date() ? (
        <em>
          This game has already been played, so you cannot save a new board.
        </em>
      ) : this.state.board.initialised &&
        this.state.board.iteration > 0 &&
        this.state.endDate > new Date() ? (
        <React.Fragment>
          <Link onClick={() => this.saveBoard()}>Save</Link> the board you
          generated&hellip;
        </React.Fragment>
      ) : (
        <em>If you generate a new board, you will be able to save it here.</em>
      );

    const printBtn =
      (this.state.board.id != null && this.state.board.iteration == 0) ||
      this.state.endDate < new Date() ? (
        <React.Fragment>
          <Link onClick={() => this.getPrintableBoard()}>
            Download your Bingo Board
          </Link>{" "}
          and play along in class!
        </React.Fragment>
      ) : (
        "Save your board before this step"
      );

    const workSheetInstr = this.state.board.practicable ? (
      <li>
        Print and complete this&nbsp;
        <Link onClick={() => this.getWorksheet()}>
          Practice Bingo Board
        </Link>{" "}
        then turn it in before class begins.
      </li>
    ) : (
      <li>
        Not enough usable entries for a practice sheet. Encourage your
        classmates to complete their assignments.
      </li>
    );

    const playableInstr = this.state.board.playable ? (
      <React.Fragment>
        <li>
          <Link onClick={() => this.randomizeTiles()}>
            (Re)Generate your playable board
          </Link>{" "}
          until you get one you like and then&hellip;
        </li>
        <li>{saveBtn}</li>
        <li>{printBtn}</li>
      </React.Fragment>
    ) : (
      <li>
        Not enough usable entries to generate a playble Bingo board &mdash;
        encourage your classmates to complete their assignments.
      </li>
    );

    const builder = this.state.board.playable ? (
      <div id="bingoBoard" className="mt4">
        <BingoBoard board={this.state.board} />
      </div>
    ) : null;

    return (
      <MuiThemeProvider theme={styles}>
        <Paper>
          <Typography>
            <strong>Topic:</strong> {this.state.board.bingo_game.topic}
          </Typography>
          <Typography>
            <strong>Description:</strong>{" "}
            {this.state.board.bingo_game.description}
          </Typography>
          {null != this.state.candidate_list && (
            <Typography>
              <strong>Performance:</strong>
              {this.state.candidate_list.cached_performance}
            </Typography>
          )}
          <hr />
          <Tabs value={this.state.curTab} onChange={this.changeTab} centered>
            <Tab value="builder" label="Bingo game builder" />
            <Tab value="results" label="Your performance" />
            <Tab value="concepts" label="Concepts found by class" />
          </Tabs>
          {"builder" == this.state.curTab && (
            <Paper square={false}>
              <br />
              <ol>
                {workSheetInstr}
                {playableInstr}
              </ol>
              {builder}
            </Paper>
          )}
          {"results" == this.state.curTab && (
            <ScoredGameDataTable candidates={this.state.candidates} />
          )}
          {"concepts" == this.state.curTab && (
            <ConceptChips concepts={this.state.concepts} />
          )}
        </Paper>
      </MuiThemeProvider>
    );
  }
}
BingoBuilder.propTypes = {
  endDateStr: PropTypes.string.isRequired,
  token: PropTypes.string.isRequired,
  resultsUrl: PropTypes.string.isRequired,
  boardUrl: PropTypes.string.isRequired,
  conceptsUrl: PropTypes.string.isRequired,
  worksheetUrl: PropTypes.string.isRequired,
  boardSaveUrl: PropTypes.string.isRequired
};
export default withTheme(BingoBuilder);
