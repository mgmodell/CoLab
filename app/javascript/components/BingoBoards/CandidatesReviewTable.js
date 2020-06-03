/* eslint-disable no-console */
import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Paper from "@material-ui/core/Paper";
import Button from "@material-ui/core/Button";
import CircularProgress from "@material-ui/core/CircularProgress";
import Grid from "@material-ui/core/Grid";
import InputBase from "@material-ui/core/InputBase";
import Link from "@material-ui/core/Link";
import SearchIcon from "@material-ui/icons/Search";
import Checkbox from "@material-ui/core/Checkbox";
import Table from "@material-ui/core/Table";
import TableHead from "@material-ui/core/TableHead";
import TableBody from "@material-ui/core/TableBody";
import TableCell from "@material-ui/core/TableCell";
import TableRow from "@material-ui/core/TableRow";
import TableSortLabel from "@material-ui/core/TableSortLabel";
import TablePagination from "@material-ui/core/TablePagination";
import Tooltip from "@material-ui/core/Tooltip";
import Typography from "@material-ui/core/Typography";
import { SortDirection } from "react-virtualized";
import ColumnMenu from "../ColumnMenu";
import SelectFrom from "../SelectFrom";
import RemoteAutosuggest from "../RemoteAutosuggest";

import { useEndpointStore } from '../infrastructure/EndPointStore';
import {i18n } from '../infrastructure/i18n';
import { useTranslation } from 'react-i18next';

export default function CandidatesReviewTable( props ){
  const { t } = useTranslation( 'bingo_games' );
  const endpointSet = 'candidate_review';
  const [endpoints, endpointsActions] = useEndpointStore( );
  const [search, setSearch] = useState( '' );
  const [candidates, setCandidates] = useState( [] );
  const [candidateLists, setCandidateLists] = useState( [] );
  const [candidateMap, setCandidateMap] = useState( {} );
  const [bingoGame, setBingoGame] = useState( );
  const [fieldPrefix, setFieldPrefix] = useState( '' );
  const [rowsPerPage, setRowsPerPage] = useState( 5 );
  const [page, setPage] = useState( 0 );
  const [filterText, setFilterText] = useState( '' );
  const [reviewComplete, setReviewComplete] = useState( false );
  const [reviewStatus, setReviewStatus] = useState( '' );
  const [progress, setProgress] = useState( 0 );
  const [uniqueConcepts, setUniqueConcepts] = useState( 0 );
  const [acceptableUniqueConcepts, setAcceptableUniqueConcepts] = useState( 0 );
  const [sortBy, setSortBy ] = useState( 'number' );
  const [sortDirection, setSortDirection] = useState( SortDirection.DESC );
  const [dirty, setDirty] = useState( false );
  const [users, setUsers] = useState( {} );
  const [groups, setGroups] = useState( {} );
  const [feedbackOpts, setFeedbackOpts ] =  useState( {} );
  useEffect(()=>{
    setDirty( true );
    updateProgress( )
  },[
    reviewComplete,
    candidateMap
  ])
  const [columns, setColumns ] = useState([
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
            return 100 == c.completed ? "*" : null;
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
          render_func: c => submitterRender(c)
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
            return feedbackRender(c);
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
            return conceptRender(c);
          }
        }

  ])

  const review_complete_lbl = 'Review completed';

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
  }, []);

  useEffect(() =>{
    if( 'loaded' === endpoints.endpointStatus[endpointSet] ){
      getData( );
    }

  }, [endpoints.endpointStatus[endpointSet]]);

  const sortCandidates = (key, direction, candidates) => {
    const dataKey = key;
    const mod = direction == SortDirection.ASC ? -1 : 1;

    if ("feedback" == dataKey) {
      candidates.sort((a, b) => {
        let a_val = !a["candidate_feedback_id"]
          ? 0
          : a["candidate_feedback_id"];
        let b_val = !b["candidate_feedback_id"]
          ? 0
          : b["candidate_feedback_id"];
        return mod * (a_val - b_val);
      });
    } else if ("concept" == dataKey) {
      candidates.sort((a, b) => {
        return mod * a[dataKey].name.localeCompare(b[dataKey].name);
      });
    } else if ("submitter" == dataKey) {
      candidates.sort((a, b) => {
        //Using users from state
        //This is ugly
        const af = users[a.user_id].last_name;
        const bf = users[b.user_id].last_name;
        return mod * af.localeCompare(bf);
      });
    } else if ("number" == dataKey) {
      candidates.sort((a, b) => {
        return mod * (a[dataKey] - b[dataKey]);
      });
    } else if ("completed" == dataKey) {
      candidates.sort((a, b) => {
        const retval = a.completed - b.completed;
        return mod * retval;
      });
    } else {
      candidates.sort((a, b) => {
        return mod * a[dataKey].localeCompare(b[dataKey]);
      });
    }

    return candidates;
  }
  const setCompleted = (item) => {
    //This use feedbackOpts from state
    const fb_id = item.candidate_feedback_id;
    if (fb_id != null) {
      item.completed = 100;
      if (
        "term_problem" != feedbackOpts[fb_id].critique &&
        item.concept.name.length < 1
      ) {
        item.completed = 50;
      }
    } else {
      item.completed = 0;
    }
  };

  const updateProgress = () => {
    //We're using feedbackOpts and candidatesMap from state
    const candidates = Object.values(candidateMap);
    const completed = candidates.reduce((acc, item) => {
      if (100 == item.completed) {
        acc = acc + 1;
      }
      return acc;
    }, 0);
    //Concept count
    const concepts = new Array(...Object.values(candidateMap).entries());
    let filtered = concepts
      .filter(x => "" != x[1].concept.name)
      .map(x => x[1].concept.name.toLowerCase());

    const unique_concepts = new Set(filtered).size;
    //Now for just the acceptable ones
    filtered = concepts
      .filter(
        x =>
          "" != x[1].concept.name &&
          "acceptable" == feedbackOpts[x[1].candidate_feedback_id].critique
      )
      .map(x => x[1].concept.name.toLowerCase());
    const acceptable_unique_concepts = new Set(filtered).size;

    setUniqueConcepts( unique_concepts );
    setAcceptableUniqueConcepts( acceptable_unique_concepts );
    setProgress( Math.round((completed / candidates.length ) * 100 ))
  }

  const sortEvent = (dataKey) => {
    //const { candidates, sortBy, sortDirection } = this.state;

    let direction = SortDirection.DESC;
    if (dataKey == sortBy && direction == sortDirection) {
      direction = SortDirection.ASC;
    }
    sortCandidates(dataKey, direction, candidates);
    setCandidates( candidates );
    setSortDirection( direction );
    setSortDirection( dataKey );
  }

  const getData = () => {
    setReviewStatus( "Loading data" );

    fetch( `${endpoints.endpoints[endpointSet].baseUrl}${props.bingoGameId}.json`, {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
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
        const feedback_opts = {};
        data.feedback_opts.map(item => {
          feedback_opts[item.id] = item;
        });
        setFeedbackOpts( feedback_opts)

        const found_groups = {};
        data.groups.map(item => {
          found_groups[item.id] = item;
        });
        setGroups( found_groups );
        const found_users = {};
        data.users.map(item => {
          found_users[item.id] = item;
        });
        setUsers( found_users );
        setCandidates( data.candidates );

        const candidate_lists = {};
        data.candidate_lists.map(item => {
          candidate_lists[item.id] = item;
        });
        setCandidateLists( candidate_lists );

        const candidates_map = {};
        data.candidates.map(item => {
          setCompleted(item);
          candidates_map[item.id] = item;
        });
        setCandidateMap( candidates_map );

        setBingoGame( data.bingo_game );
        setFieldPrefix( "_bingo_candidates_review_" + data.bingo_game.id )
        setRowsPerPage( data.candidates.length );

        setReviewStatus( 'Data loaded' );
        setDirty( false );
        updateProgress();
      });
  }
  // conceptStats() {}
  const saveFeedback = () => {
    setDirty( false );
    setReviewStatus( 'Saving feedback.' )

    fetch(`${endpoints.endpoints[endpointSet].reviewSaveUrl}${props.bingoGameId}.json`, {
      method: "PATCH",
      credentials: "include",
      body: JSON.stringify({
        candidates: candidates.filter(c => 0 < c.completed),
        reviewed: review_complete
      }),
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          const fail_data = new Object();
          fail_data.notice = "The operation failed";
          fail_data.success = false;
          console.log("error");
          return fail_data;
        }
      })
      .then(data => {
        setDirty( typeof data.success !== "undefined" )
        setReviewStatus( data.notice );
      });
  }

  handleChangeRowsPerPage = (event) => {
    setRowsPerPage( event.target.value );
    setPage( 1 );
  };

  const filter = (event) => {
    //const { sortBy, sortDirection, candidates_map } = this.state;
    //We'll be using sortBy, sortDirection and candidatesMap
    const filter_text = event.target.value;
    const filtered = Object.values(candidateMap).filter(candidate =>
      candidate.definition.toUpperCase().includes(filter_text.toUpperCase())
    );
    sortCandidates(sortBy, sortDirection, filtered);

    setCandidates( filtered );
    setFilterText( filter_text );
    setPage( 1 );
  };
  const conceptSet = (id, value) => {
    //let candidates_map = this.state.candidates_map;
    candidates_map[id].concept.name = value;

    setCompleted(candidates_map[id]);
    setCandidateMap( candidates_map )
  };
  const feedbackSet = (id, value) => {
    const candidates_map = this.state.candidates_map;
    candidates_map[id].candidate_feedback_id = parseInt(value);
    setCompleted(candidates_map[id]);
    setCandidateMap( candidates_map );
  };
  const colSel = (event, index) => {
    let cols = columns;
    cols[index].visible = !cols[index].visible;
    setColumns( cols );
  };
  const conceptRender = (c) => {
    //const { feedback_opts } = this.state;
    const label = "Concept";
    const fb_id = c.candidate_feedback_id;

    let output = "N/A";
    if (fb_id != null && "term_problem" != feedbackOpts[fb_id].critique) {
      output = (
        <RemoteAutosuggest
          inputLabel={label}
          itemId={c.id}
          enteredValue={c.concept.name}
          controlId={"concept_4_" + c.id}
          dataUrl={endpoints.endpoints[endpointSet].conceptUrl}
          setFunction={conceptSet}
        />
      );
    }
    return output;
  };
  const feedbackRender = (c)=> {
    const label = "Feedback";
    const id = c.candidate_feedback_id > 0 ? "" + c.candidate_feedback_id : "0";
    return (
      <SelectFrom
        options={feedbackOpts}
        selectLbl={label}
        itemId={c.id}
        selectedValue={id}
        controlId={"feedback_4_" + c.id}
        selectFunction={feedbackSet}
      />
    );
  };
  const submitterRender = (c)=> {
    let cl = candidateLists[c.candidate_list_id];
    let u = users[c.user_id];
    return (
      <div>
        <Link href={"mailto:" + u.email}>
          {u.last_name},&nbsp;{u.first_name}
        </Link>
        {cl.is_group && (
          <em>
            {"\n"}
            (on behalf of {groups[cl.group_id].name})
          </em>
        )}
      </div>
    );
  };

    const direction = {
      [SortDirection.ASC]: "asc",
      [SortDirection.DESC]: "desc"
    };

    const notify =
      progress < 100 ? null : (
        <div onClick={setReviewComplete} >
          <Checkbox id="review_complete" checked={reviewComplete} />
          <Typography>{review_complete_lbl}</Typography>
        </div>
      );
    const statusMsg = dirty ? null : (
      <Typography>{reviewStatus}</Typography>
    );
    const saveButton = dirty ? (
      <Button variant="contained" onClick={() => saveFeedback()}>
        Save
      </Button>
    ) : (
      <Button disabled variant="contained" onClick={() => saveFeedback()}>
        Save
      </Button>
    );

    const toolbar = (
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
            value={filterText}
            onChange={filter}
          />
          <SearchIcon />
        </Grid>
        <Grid item>
          <ColumnMenu columns={columns} selMethod={colSel} />
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
            onChangePage={(event,page)=>setPage( page )}
            onChangeRowsPerPage={handleChangeRowsPerPage}
          />
        </Grid>
        <Grid item>
          <CircularProgress
            size={10}
            variant={progress > 0 ? "static" : "indeterminate"}
            value={progress}
          />
          &nbsp;
          {progress}%
          <Tooltip title="Unique concepts identified [acceptably explained]">
            <Typography>
              {uniqueConcepts} [
              {acceptableUniqueConcepts}]
            </Typography>
          </Tooltip>
          {statusMsg}
          {notify}
        </Grid>
        <Grid item>
          <Button variant="contained" onClick={() => getData()}>
            Reload
          </Button>
          {saveButton}
        </Grid>
      </Grid>
    );

    return (
      <Paper style={{ height: "95%", width: "100%" }}>
        <Grid container>
          <Grid item xs={12} sm={3}>
            {t('topic')}:
          </Grid>
          <Grid item xs={12} sm={9}>
            {bingoGame.topic}
          </Grid>
          <Grid item xs={12} sm={3}>
            {t('close_date')}:
          </Grid>
          <Grid item xs={12} sm={9}>
            {bingoGame.end_date}
          </Grid>
          <Grid item xs={12} sm={3}>
            {t('description')}:
          </Grid>
          <Grid item xs={12} sm={9}>
            <p
              dangerouslySetInnerHTML={{
                __html: bingoGame.description
              }}
            />
          </Grid>
        </Grid>
        {toolbar}
        <div>
          <Table>
            <TableHead>
              <TableRow>
                {columns.map(cell => {
                  if (cell.visible) {
                    const header = cell.sortable ? (
                      <TableSortLabel
                        active={cell.dataKey == sortBy}
                        direction={direction[sortDirection]}
                        onClick={() => sortEvent(cell.dataKey)}
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
      </Paper>
    );
}
CandidatesReviewTable.propTypes = {
  token: PropTypes.string.isRequired,
  getEndPpointsUrl: PropTypes.string.isRequired,
  bingoGameId: PropTypes.number.isRequired
};
