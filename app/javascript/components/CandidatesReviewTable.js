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
import TablePagination from "@material-ui/core/TablePagination";
import Typography from "@material-ui/core/Typography";
import ViewColumnRounded from "@material-ui/icons/ViewColumnRounded";
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
      candidates_raw: [],
      bingo_game: null,
      field_prefix: "",
      rowsPerPage: 5,
      page: 1,
      review_complete_lbl: "Review completed",
      review_complete: false,
      reviewStatus: "",
      columns: [
        {
          width: 20,
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
          width: 100,
          flexGrow: 1.0,
          label: "Submitted by",
          dataKey: "submitter",
          numeric: false,
          visible: false,
          sortable: true,
          render_func: c => this.submitterRender(c)
        },
        {
          width: 100,
          flexGrow: 0.0,
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
          flexGrow: 2.0,
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
  }
  componentDidMount() {
    //Retrieve concepts
    this.getData();
  }
  getData() {
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
          candidates_raw: data.candidates,
          feedback_opts: feedback_opts
        });
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
        candidates: this.state.candidates,
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
        //window.location.href = data.next_stop
        //      open( data.next_stop, '_self' )
      });
  }
  handleChange = function(name) {
    this.setState({ [name]: !this.state[name] });
    //this.setState( {[name]: event.target.checked } )
  };
  handleChangePage = function(event, page) {
    this.setState({ page: page });
  };
  handleChangeRowsPerPage = function(event) {
    this.setState({ rowsPerPage: event.target.value });
  };
  filter = function(event) {
    console.log(this.state.candidates_raw.length);
    var filtered = this.state.candidates_raw.filter(candidate =>
      candidate.definition
        .toUpperCase()
        .includes(event.target.value.toUpperCase())
    );
    this.setState({
      candidates: filtered,
      page: 1
    });
  };
  conceptSet = function(id, value) {
    let candidates_map = this.state.candidates_map;
    candidates_map[id].concept.name = value;
    let candidates = Object.values(candidates_map);
    //We'll sort here later
    this.setState({
      candidates_map: candidates_map,
      candidates: candidates
    });
  };
  feedbackSet = function(id, value) {
    let candidates_map = this.state.candidates_map;
    candidates_map[id].candidate_feedback_id = parseInt(value);
    let candidates = Object.values(candidates_map);
    //We'll sort here later
    this.setState({
      candidates_map: candidates_map,
      candidates: candidates
    });
  };
  colSel = function(event, index) {
    let cols = this.state.columns;
    cols[index].visible = !cols[index].visible;
    this.setState({
      columns: cols
    });
  };
  conceptRender = function(c) {
    const label = "Concept";
    return (
      <RemoteAutosuggest
        inputLabel={label}
        itemId={c.id}
        enteredValue={c.concept.name}
        controlId={"concept_4_" + c.id}
        dataUrl={this.props.conceptUrl}
        setFunction={this.conceptSet}
      />
    );
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
    const {
      columns,
      candidates,
      candidates_raw,
      rowsPerPage,
      page
    } = this.state;
    return (
      <Paper style={{ width: "100%" }}>
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
              <Typography>
                <Checkbox
                  id="review_complete"
                  checked={this.state.review_complete}
                />
                {this.state.review_complete_lbl}
              </Typography>
            </div>
          </Grid>
          <Grid item>
            <Button variant="contained" onClick={() => this.saveFeedback()}>
              Save
            </Button>
          </Grid>
          <Grid item>
            <Typography>{this.state.reviewStatus}</Typography>
          </Grid>
        </Grid>
        <div>
          <Table>
            <TableHead>
              <TableRow>
                {columns.map(cell => {
                  if (cell.visible) {
                    return (
                      <TableCell key={"h_" + cell.dataKey}>
                        {cell.label}
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
