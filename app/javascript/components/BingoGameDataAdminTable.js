/* eslint-disable no-console */
import React from "react";
import PropTypes from "prop-types";
import BingoGameResults from "./BingoGameResults";
import Paper from "@material-ui/core/Paper";
import InputBase from "@material-ui/core/InputBase";
import LinearProgress from "@material-ui/core/LinearProgress";
import SearchIcon from "@material-ui/icons/Search";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";
import { SortDirection } from "react-virtualized";
import WrappedVirtualizedTable from "../components/WrappedVirtualizedTable";


class BingoGameDataAdminTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      search: "",
      sortBy: "student",
      sortDirection: SortDirection.DESC,
      results: this.props.results_raw,
      individual: {
        open: false,
        student: "",
        board: [],
        close: this.closeDialog,
        candidates: []
      },
      columns: [
        {
          width: 120,
          flexGrow: 1.0,
          label: "List Performance",
          dataKey: "performance",
          numeric: true,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          flexGrow: 1.0,
          label: "Worksheet Score",
          dataKey: "score",
          numeric: true,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          flexGrow: 1.0,
          label: "Student",
          dataKey: "student",
          numeric: false,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          label: "Group",
          dataKey: "group",
          numeric: false,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          label: "Expected",
          dataKey: "concepts_expected",
          numeric: true,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          label: "Entered",
          dataKey: "concepts_entered",
          numeric: true,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          label: "Credited",
          dataKey: "concepts_credited",
          numeric: true,
          disableSort: false,
          visible: true
        },
        {
          width: 120,
          label: "Term Problems",
          dataKey: "term_problems",
          numeric: true,
          disableSort: false,
          visible: true
        }
      ]
    };
    this.filter = this.filter.bind(this);
    this.colSort = this.colSort.bind(this);
    this.closeDialog = this.closeDialog.bind(this);
    this.openDialog = this.openDialog.bind(this);
  }
  openDialog(event) {
    const index = event.index;
    this.setState({
      individual: {
        open: true,
        student: this.state.results[index].student,
        board: this.state.results[index].practice_answers,
        candidates: this.state.results[index].candidates,
        score: this.state.results[index].score
      }
    });
  }
  closeDialog() {
    this.setState({
      individual: {
        open: false
      }
    });
  }
  filter = function(event) {
    var filtered = this.props.results_raw.filter(user =>
      user.student.toUpperCase().includes(event.target.value.toUpperCase())
    );
    this.setState({ results: filtered });
  };

  colSort = function(event) {
    let tmpArray = this.props.results_raw;
    let direction = SortDirection.DESC;
    let mod = 1;
    if (
      event.sortBy == this.state.sortBy &&
      direction == this.state.sortDirection
    ) {
      direction = SortDirection.ASC;
      mod = -1;
    }
    let index = 0;
    for (index = 0; index < this.state.columns.length; ++index) {
      if (this.state.columns[index].dataKey == event.sortBy) {
        break;
      }
    }

    if (this.state.columns[index].numeric) {
      tmpArray.sort((a, b) => {
        return mod * a[event.sortBy] - b[event.sortBy];
      });
    } else {
      tmpArray.sort((a, b) => {
        return mod * a[event.sortBy].localeCompare(b[event.sortBy]);
      });
    }
    this.setState({
      results: tmpArray,
      sortDirection: direction,
      sortBy: event.sortBy
    });
  };
  render() {
    return (
      <Paper style={{ height: "100%", width: "100%" }}>
        {null == this.props.results_raw || null == this.state.results ? (
          <React.Fragment>
            <br />
            <Typography variant={"h3"} align={"center"}>
              Loading&hellip;
            </Typography>
            <LinearProgress />
          </React.Fragment>
        ) : (
          <React.Fragment>
            <Toolbar>
              <InputBase placeholder="Search results" onChange={this.filter} />
              <SearchIcon />
              <Typography color="inherit">
                Showing {this.state.results.length} of{" "}
                {this.props.results_raw.length}
              </Typography>
            </Toolbar>
            <WrappedVirtualizedTable
              rowCount={this.state.results.length}
              rowGetter={({ index }) => this.state.results[index]}
              sort={this.colSort}
              sortBy={this.state.sortBy}
              sortDirection={this.state.sortDirection}
              onRowClick={event => this.openDialog(event)}
              columns={this.state.columns}
            />
            <BingoGameResults
              open={this.state.individual.open}
              student={this.state.individual.student}
              board={this.state.individual.board}
              score={this.state.individual.score}
              close={this.closeDialog}
              candidates={this.state.individual.candidates}
            />
          </React.Fragment>
        )}
      </Paper>
    );
  }
}
BingoGameDataAdminTable.propTypes = {
  results_raw: PropTypes.array
};
export default BingoGameDataAdminTable;
