/* eslint-disable no-console */
import React from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import { withStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Button from "@material-ui/core/Button";
import Grid from "@material-ui/core/Grid";
import IconButton from "@material-ui/core/IconButton";
import Input from "@material-ui/core/Input";
import InputBase from "@material-ui/core/InputBase";
import Link from "@material-ui/core/Link";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import SearchIcon from "@material-ui/icons/Search";
import MenuList from "@material-ui/core/MenuList";
import MenuItem from "@material-ui/core/MenuItem";
import Checkbox from "@material-ui/core/Checkbox";
import Table from "@material-ui/core/Table";
import TableHead from "@material-ui/core/TableHead";
import TableBody from "@material-ui/core/TableBody";
import TableCell from "@material-ui/core/TableCell";
import TableRow from "@material-ui/core/TableRow";
import TableSortLabel from "@material-ui/core/TableSortLabel";
import TablePagination from "@material-ui/core/TablePagination";
import Typography from "@material-ui/core/Typography";
import ViewColumnRounded from "@material-ui/icons/ViewColumnRounded";
import { SortDirection } from "react-virtualized";
import ColumnMenu from "../components/ColumnMenu";
import SelectFrom from "../components/SelectFrom";
import RemoteAutosuggest from "../components/RemoteAutosuggest";
const styles = theme => ({
  table: {
    fontFamily: theme.typography.fontFamily
  },
  flexContainer: {
    display: "flex",
    alignItems: "center",
    boxSizing: "border-box"
  },
  tableRow: {
    cursor: "pointer"
  },
  tableRowHover: {
    "&:hover": {
      backgroundColor: theme.palette.grey[200]
    }
  },
  tableCell: {
    flex: 1
  },
  noClick: {
    cursor: "initial"
  }
});
class CandidatesReviewTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      search: "",
      candidates: [],
      bingo_game: null,
      field_prefix: "",
      rowsPerPage: 5,
      page: 1,
      filter_text: "",
      review_complete_lbl: "Review completed",
      review_complete: false,
      reviewStatus: "",
      progress: 0,
      sortBy: "number",
      sortDirection: SortDirection.DESC,
      columns: [
        {
          width: 1,
          flexGrow: 0,
          label: "#",
          dataKey: "number",
          numeric: true,
          visible: true,
          sortable: true,
          render_func: c => {
            return c.number;
          }
        },
        {
          width: 1,
          flexGrow: 0,
          label: "Complete",
          dataKey: "completed",
          numeric: true,
          visible: true,
          sortable: true,
          render_func: c => {
            return c.completed ? "*" : null;
          }
        },
        {
          width: 75,
          flexGrow: 1.0,
          label: "Submitted by",
          dataKey: "submitter",
          numeric: false,
          visible: false,
          sortable: true,
          render_func: c => this.submitterRender(c)
        },
        {
          width: 50,
          flexGrow: 1.0,
          label: "Term",
          dataKey: "term",
          numeric: false,
          visible: true,
          sortable: true,
          render_func: c => {
            return c.term;
          }
        },
        {
          width: 200,
          flexGrow: 1.5,
          label: "Definition",
          dataKey: "definition",
          numeric: false,
          visible: true,
          sortable: true,
          render_func: c => {
            return c.definition;
          }
        },
        {
          width: 200,
          flexGrow: 1.0,
          label: "Feedback",
          dataKey: "feedback",
          numeric: false,
          visible: true,
          sortable: true,
          render_func: c => {
            return this.feedbackRender(c);
          }
        },
        {
          width: 200,
          flexGrow: 1.0,
          label: "Concept",
          dataKey: "concept",
          numeric: false,
          visible: true,
          sortable: true,
          render_func: c => {
            return this.conceptRender(c);
          }
        }
      ]
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleChangePage = this.handleChangePage.bind(this);
    this.handleChangeRowsPerPage = this.handleChangeRowsPerPage.bind(this);
    this.feedbackRender = this.feedbackRender.bind(this);
    this.submitterRender = this.submitterRender.bind(this);
    this.conceptRender = this.conceptRender.bind(this);
    this.filter = this.filter.bind(this);
    this.colSel = this.colSel.bind(this);
    this.feedbackSet = this.feedbackSet.bind(this);
    this.conceptSet = this.conceptSet.bind(this);
    this.updateProgress = this.updateProgress.bind(this);
  }
  componentDidMount() {
    //Retrieve concepts
    this.getData();
  }

  sortTable(key, direction) {
    const { candidates_map } = this.state;
    const dataKey = key;
    const mod = direction == SortDirection.ASC ? -1 : 1;

    var filtered = Object.values(candidates_map).filter(candidate =>
      candidate.definition.toUpperCase().includes(this.state.filter_text)
    );

    if ("feedback" == dataKey) {
      filtered.sort((a, b) => {
        let a_val = !a["candidate_feedback_id"]
          ? 0
          : a["candidate_feedback_id"];
        let b_val = !b["candidate_feedback_id"]
          ? 0
          : b["candidate_feedback_id"];
        let comparison = a_val - b_val;
        return mod * (a_val - b_val);
      });
    } else if ("concept" == dataKey) {
      filtered.sort((a, b) => {
        return mod * a[dataKey].name.localeCompare(b[dataKey].name);
      });
    } else if ("submitter" == dataKey) {
      filtered.sort((a, b) => {
        const af = this.state.users[a.user_id].last_name;
        const bf = this.state.users[b.user_id].last_name;
        return mod * (af.localeCompare( bf ) );
      });
    } else if ("number" == dataKey) {
      filtered.sort((a, b) => {
        return mod * (a[dataKey] - b[dataKey]);
      });
    } else if ("completed" == dataKey) {
      filtered.sort((a, b) => {
        const retval = a.completed === b.completed ? 0 : a.completed ? -1 : 1;
        return mod * retval;
      });
    } else {
      filtered.sort((a, b) => {
        return mod * a[dataKey].localeCompare(b[dataKey]);
      });
    }

    //Calculate progress
    this.updateProgress();

    this.setState({
      candidates: filtered
    });
  }

  updateProgress() {
    const { feedback_opts, candidates_map } = this.state;
    let completed = 0;
    const candidates = Object.values(candidates_map);
    candidates.forEach(candidate => {
      const fb_id = candidate.candidate_feedback_id;
      if (
        fb_id != null &&
        (feedback_opts[fb_id].name_en.startsWith("Term") ||
          candidate.concept.name.length > 0)
      ) {
        completed = completed + 1;
        candidate.completed = true;
      } else {
        candidate.completed = false;
      }
    });
    this.setState({
      progress: Math.round((completed / candidates.length) * 100)
    });
  }

  sortEvent(event, dataKey) {
    const { candidates_map, sortBy, sortDirection } = this.state;

    let direction = SortDirection.DESC;
    if (dataKey == sortBy && direction == sortDirection) {
      direction = SortDirection.ASC;
    }
    this.setState({
      sortDirection: direction,
      sortBy: dataKey
    });
    this.sortTable(dataKey, direction);
  }

  getData() {
    this.setState({
      reviewStatus: "Loading data"
    });
    fetch(this.props.dataUrl + ".json", {
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
        data.candidates.map((candidate, index) => {
          candidate.number = index;
          if (!candidate.concept) {
            candidate.concept = { name: "" };
          }
        });
        let feedback_opts = {};
        data.feedback_opts.map(item => {
          feedback_opts[item.id] = item;
        });
        let groups = {};
        data.groups.map(item => {
          groups[item.id] = item;
        });
        let users = {};
        data.users.map(item => {
          users[item.id] = item;
        });
        let candidate_lists = {};
        data.candidate_lists.map(item => {
          candidate_lists[item.id] = item;
        });
        let candidates_map = {};
        data.candidates.map(item => {
          candidates_map[item.id] = item;
        });
        this.setState({
          bingo_game: data.bingo_game,
          field_prefix: "_bingo_candidates_review_" + data.bingo_game.id,
          groups: groups,
          users: users,
          rowsPerPage: data.candidates.length,
          candidate_lists: candidate_lists,
          candidates_map: candidates_map,
          candidates: data.candidates,
          feedback_opts: feedback_opts
        });
        this.setState({
          reviewStatus: "Data loaded"
        });
        this.updateProgress();
      });
  }
  saveFeedback() {
    this.setState({
      reviewStatus: "Saving feedback."
    });
    fetch(this.props.reviewSaveUrl + ".json", {
      method: "PATCH",
      credentials: "include",
      body: JSON.stringify({
        candidates: this.state.candidates.filter(c => c.completed),
        reviewed: this.state.review_complete
      }),
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
        //TODO: handle save errors
        this.setState({
          reviewStatus: data.notice
        });
      });
  }
  handleChange = function(name) {
    this.setState({ [name]: !this.state[name] });
    this.updateProgress();
    //this.setState( {[name]: event.target.checked } )
  };
  handleChangePage = function(event, page) {
    this.setState({ page: page });
  };
  handleChangeRowsPerPage = function(event) {
    this.setState({ rowsPerPage: event.target.value });
  };
  filter = function(event) {
    const filter_text = event.target.value.toUpperCase();
    this.setState({
      filter_text: filter_text,
      page: 1
    });
    this.sortTable(this.state.sortBy, this.state.sortDirection);
  };
  conceptSet = function(id, value) {
    let candidates_map = this.state.candidates_map;
    candidates_map[id].concept.name = value;
    this.setState({
      candidates_map: candidates_map
    });
    this.updateProgress();
  };
  feedbackSet = function(id, value) {
    const candidates_map = this.state.candidates_map;
    candidates_map[id].candidate_feedback_id = parseInt(value);
    this.setState({
      candidates_map: candidates_map
    });
    this.updateProgress();
  };
  colSel = function(event, index) {
    let cols = this.state.columns;
    cols[index].visible = !cols[index].visible;
    this.setState({
      columns: cols
    });
  };
  conceptRender = function(c) {
    const { feedback_opts, candidates } = this.state;
    const label = "Concept";
    const fb_id = c.candidate_feedback_id;


    let output = "N/A";
    if (fb_id != null && !feedback_opts[fb_id].name_en.startsWith("Term")) {
      output = (
        <RemoteAutosuggest
          inputLabel={label}
          itemId={c.id}
          enteredValue={c.concept.name}
          controlId={"concept_4_" + c.id}
          dataUrl={this.props.conceptUrl}
          setFunction={this.conceptSet}
        />
      );
    }
    return output;
  };
  feedbackRender = function(c) {
    const label = "Feedback";
    const id = c.candidate_feedback_id > 0 ? "" + c.candidate_feedback_id : "0";
    return (
      <SelectFrom
        options={this.state.feedback_opts}
        selectLbl={label}
        itemId={c.id}
        selectedValue={id}
        controlId={"feedback_4_" + c.id}
        selectFunction={this.feedbackSet}
      />
    );
  };
  submitterRender = function(c) {
    let cl = this.state.candidate_lists[c.candidate_list_id];
    let u = this.state.users[c.user_id];
    let behalf;
    return (
      <div>
        <Link href={"mailto:" + u.email}>
          {u.last_name},&nbsp;{u.first_name}
        </Link>
        {cl.is_group && (
          <em>
            {"\n"}
            (on behalf of {this.state.groups[cl.group_id].name})
          </em>
        )}
      </div>
    );
  };
  render() {
    const direction = {
      [SortDirection.ASC]: "asc",
      [SortDirection.DESC]: "desc"
    };
    const { columns, candidates, rowsPerPage, page } = this.state;

    const notify = this.state.progress < 100 ? null :
              <Typography>
                <Checkbox
                  id="review_complete"
                  checked={this.state.review_complete}
                />
                {this.state.review_complete_lbl}
              </Typography>
    const toolbar =
        <Grid
          container
          spacing={8}
          direction="row"
          justify="flex-end"
          alignItems="stretch"
        >
          <Grid item>
            <InputBase
              placeholder="Search definitions"
              onChange={this.filter}
            />
            <SearchIcon />
          </Grid>
          <Grid item>
            <ColumnMenu columns={columns} selMethod={this.colSel} />
          </Grid>
          <Grid item>
            <TablePagination
              rowsPerPageOptions={[5, 10, 25, candidates.length]}
              component="div"
              count={candidates.length}
              rowsPerPage={rowsPerPage}
              page={page}
              backIconButtonProps={{
                "aria-label": "Previous Page"
              }}
              nextIconButtonProps={{
                "aria-label": "Next Page"
              }}
              onChangePage={this.handleChangePage}
              onChangeRowsPerPage={this.handleChangeRowsPerPage}
            />
          </Grid>
          <Grid item>
            <div onClick={() => this.handleChange("review_complete")}>
              <Typography>{this.state.progress}%</Typography>
              <Typography>{this.state.reviewStatus}</Typography>
              {notify}
            </div>
          </Grid>
          <Grid item>
            <Button variant="contained" onClick={() => this.getData()}>
              Reload
            </Button>
            <Button variant="contained" onClick={() => this.saveFeedback()}>
              Save
            </Button>
          </Grid>
        </Grid>

    return (
      <Paper style={{ width: "100%" }}>
        {toolbar}
        <div>
          <Table>
            <TableHead>
              <TableRow>
                {columns.map(cell => {
                  if (cell.visible) {
                    const header = cell.sortable ? (
                      <TableSortLabel
                        active={cell.dataKey == this.state.sortBy}
                        direction={direction[this.state.sortDirection]}
                        onClick={() => this.sortEvent(event, cell.dataKey)}
                      >
                        {cell.label}
                      </TableSortLabel>
                    ) : (
                      cell.label
                    );
                    return (
                      <TableCell width={cell.width} key={"h_" + cell.dataKey}>
                        {header}
                      </TableCell>
                    );
                  }
                })}
              </TableRow>
            </TableHead>
            <TableBody>
              {candidates
                .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                .map(candidate => {
                  return (
                    <TableRow key={"r_" + candidate.id}>
                      {columns.map(cell => {
                        if (cell.visible) {
                          return (
                            <TableCell key={candidate.id + "_c" + cell.dataKey}>
                              {cell.render_func(candidate)}
                            </TableCell>
                          );
                        }
                      })}
                    </TableRow>
                  );
                })}
            </TableBody>
          </Table>
        </div>
        {toolbar}
      </Paper>
    );
  }
}
CandidatesReviewTable.propTypes = {
  dataUrl: PropTypes.string.isRequired,
  conceptUrl: PropTypes.string.isRequired,
  token: PropTypes.string.isRequired,
  bingo_game_id: PropTypes.number.isRequired
};
export default CandidatesReviewTable;
