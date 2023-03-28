/* eslint-disable no-console */
import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import PropTypes from "prop-types";
import Paper from "@mui/material/Paper";
import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";
import Grid from "@mui/material/Grid";
import Link from "@mui/material/Link";
import Skeleton from "@mui/material/Skeleton";
import Checkbox from "@mui/material/Checkbox";
import Tooltip from "@mui/material/Tooltip";
import Typography from "@mui/material/Typography";
import FormControlLabel from "@mui/material/FormControlLabel";
import Select from "@mui/material/Select";
import MenuItem from "@mui/material/MenuItem";

import { useTranslation } from "react-i18next";
const RemoteAutosuggest = React.lazy(() => import("../RemoteAutosuggest"));
import MUIDataTable from "mui-datatables";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";

import WorkingIndicator from "../infrastructure/WorkingIndicator";

export default function CandidatesReviewTable(props) {
  const { t } = useTranslation("bingo_games");
  const endpointSet = "candidate_review";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { bingoGameId } = useParams();

  const [candidates, setCandidates] = useState([]);
  const [candidateLists, setCandidateLists] = useState([]);
  const [feedbackOptions, setFeedbackOptions] = useState([]);
  const [bingoGame, setBingoGame] = useState();
  const [users, setUsers] = useState([]);
  const [groups, setGroups] = useState([]);

  const [reviewComplete, setReviewComplete] = useState(false);
  const [reviewStatus, setReviewStatus] = useState("");
  const [progress, setProgress] = useState(0);

  const [uniqueConcepts, setUniqueConcepts] = useState(0);
  const [acceptableUniqueConcepts, setAcceptableUniqueConcepts] = useState(0);

  const dispatch = useDispatch();
  const [dirty, setDirty] = useState(false);

  useEffect(() => {
    setDirty(true);
    updateProgress();
  }, [reviewComplete, candidates]);

  const getById = (list, id) => {
    return list.filter(item => {
      return id === item.id;
    })[0];
  };

  const columns = [
    {
      label: "#",
      name: "number",
      options: {
        filter: false
      }
    },
    {
      label: "Complete",
      name: "completed",
      options: {
        customBodyRender: value => {
          return 100 == value ? "*" : null;
        }
      }
    },
    {
      label: "Submitted by",
      name: "id",
      options: {
        display: false,
        customBodyRender: value => {
          const candidate = getById(candidates, value);
          const user = getById(users, candidate.user_id);
          let cl = getById(candidateLists, candidate.candidate_list_id);
          const output = [
            <div>
              <Link href={"mailto:" + user.email}>
                {user.last_name},&nbsp;{user.first_name}
              </Link>
            </div>
          ];
          if (cl.is_group) {
            output.push(
              <em>
                {"\n"}
                (on behalf of {getById(groups, cl.group_id).name})
              </em>
            );
          }
          return output;
        }
      }
    },
    {
      label: "Term",
      name: "term"
    },
    {
      label: "Definition",
      name: "definition"
    },
    {
      label: "Feedback",
      name: "id",
      options: {
        customBodyRender: value => {
          const candidate = getById(candidates, value);
          return (
            <Select
              value={candidate.candidate_feedback_id || 0}
              onChange={event => {
                feedbackSet(value, event.target.value);
              }}
              id={`feedback_4_${value}`}
            >
              {feedbackOptions.map(opt => {
                return (
                  <MenuItem key={`fb_${opt.id}`} value={opt.id}>
                    {opt.name}
                  </MenuItem>
                );
              })}
            </Select>
          );
        }
      }
    },
    {
      label: "Concept",
      name: "id",
      options: {
        customBodyRender: value => {
          let output = "N/A";
          const candidate = getById(candidates, value);
          const feedback = getById(
            feedbackOptions,
            candidate.candidate_feedback_id || 0
          );

          if (feedback.id !== 0 && "term_problem" !== feedback.critique) {
            output = (
              <RemoteAutosuggest
                inputLabel={"Concept"}
                itemId={value}
                enteredValue={candidate.concept.name}
                controlId={"concept_4_" + candidate.id}
                dataUrl={endpoints.conceptUrl}
                setFunction={conceptSet}
              />
            );
          }
          return output;
        }
      }
    }
  ];

  const review_complete_lbl = "Review completed";

  useEffect(() => {
    if (endpointStatus) {
      getData();
    }
  }, [endpointStatus]);

  const setCompleted = (item, options) => {
    //This use feedbackOpts from state
    const fb_id = item.candidate_feedback_id;
    if (fb_id != null) {
      item.completed = 100;
      const fb = getById(options, fb_id);
      if ("term_problem" != fb.critique && item.concept.name.length < 1) {
        item.completed = 50;
      }
    } else {
      item.completed = 0;
    }
  };

  const updateProgress = () => {
    //We're using feedbackOpts and candidatesMap from state
    const completed = candidates.reduce((acc, item) => {
      if (100 == item.completed) {
        acc = acc + 1;
      }
      return acc;
    }, 0);
    //Concept count
    const concepts = new Array(...candidates);

    let filtered = concepts
      .filter(x => "" != x.concept.name)
      .map(x => x.concept.name.toLowerCase());

    const unique_concepts = new Set(filtered).size;
    //Now for just the acceptable ones
    filtered = concepts
      .filter(
        x =>
          "" != x.concept.name &&
          "acceptable" ==
            getById(feedbackOptions, x.candidate_feedback_id).critique
      )
      .map(x => x.concept.name.toLowerCase());
    const acceptable_unique_concepts = new Set(filtered).size;

    setUniqueConcepts(unique_concepts);
    setAcceptableUniqueConcepts(acceptable_unique_concepts);
    setProgress(Math.round((completed / candidates.length) * 100));
  };

  const getData = () => {
    dispatch(startTask());
    setReviewStatus("Loading data");

    const url =
      props.rootPath === undefined
        ? `${endpoints.baseUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.baseUrl}${bingoGameId}.json`;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        // Add a non-response for the UI
        data.feedback_opts.unshift({
          credit: 0,
          critique: "empty",
          id: 0,
          name: "Not set"
        });
        setFeedbackOptions(data.feedback_opts);

        setBingoGame(data.bingo_game);

        setGroups(data.groups);
        setUsers(data.users);
        setCandidateLists(data.candidate_lists);

        data.candidates.map((item, index) => {
          item["number"] = index + 1;
          if (null == item.concept_id) {
            item["concept"] = {
              name: ""
            };
          }
          setCompleted(item, data.feedback_opts);
        });

        setCandidates(data.candidates);

        setReviewStatus("Data loaded");
        setDirty(false);
        dispatch(endTask());
        updateProgress();
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  // conceptStats() {}
  const saveFeedback = () => {
    setDirty(false);
    dispatch(startTask("saving"));
    setReviewStatus("Saving feedback.");

    const url = `${endpoints.reviewSaveUrl}${bingoGameId}.json`;

    axios
      .patch(url, {
        candidates: candidates.filter(c => 0 < c.completed),
        reviewed: reviewComplete
      })
      .then(response => {
        const data = response.data;
        setDirty(typeof data.success !== "undefined");
        dispatch(endTask("saving"));
        setReviewStatus(data.notice);
      })
      .catch(error => {
        const fail_data = new Object();
        fail_data.notice = "The operation failed";
        fail_data.success = false;
        console.log("error");
        return fail_data;
      });
  };

  const conceptSet = (id, value) => {
    const candidates_temp = [...candidates];
    const candidate = getById(candidates_temp, id);
    candidate.concept.name = value;

    setCompleted(candidate, feedbackOptions);
    setCandidates(candidates_temp);
  };

  const feedbackSet = (id, value) => {
    const candidates_temp = [...candidates];
    const candidate = getById(candidates_temp, id);
    const fb = getById(feedbackOptions, value);
    candidate.candidate_feedback_id = value;

    setCompleted(candidate, feedbackOptions);
    setCandidates(candidates_temp);
  };

  const notify =
    progress < 100 ? null : (
      <FormControlLabel
        control={
          <Checkbox
            id="review_complete"
            onClick={() => setReviewComplete(!reviewComplete)}
            checked={reviewComplete}
          />
        }
        label={review_complete_lbl}
      />
    );
  const saveButton = (
    <Button
      disabled={!dirty}
      variant="contained"
      onClick={() => saveFeedback()}
    >
      Save
    </Button>
  );

  return (
    <Paper>
      <WorkingIndicator identifier="waiting" />

      {bingoGame != null ? (
        <Grid container>
          <Grid item xs={12} sm={3}>
            {t("topic")}:
          </Grid>
          <Grid item xs={12} sm={9}>
            {bingoGame.topic}
          </Grid>
          <Grid item xs={12} sm={3}>
            {t("close_date")}:
          </Grid>
          <Grid item xs={12} sm={9}>
            {bingoGame.end_date}
          </Grid>
          <Grid item xs={12} sm={3}>
            {t("description")}:
          </Grid>
          <Grid item xs={12} sm={9}>
            <p
              dangerouslySetInnerHTML={{
                __html: bingoGame.description
              }}
            />
          </Grid>
        </Grid>
      ) : (
        <Skeleton variant="rectangular" height={20} />
      )}
      <MUIDataTable
        data={candidates}
        columns={columns}
        options={{
          responsive: "standard",
          filter: false,
          print: false,
          download: false,
          selectableRows: "none",
          rowsPerPageOptions: [10, 15, 100, candidates.length],
          customToolbar: () => {
            return (
              <Grid
                container
                spacing={8}
                direction="row"
                justifyContent="flex-end"
                alignItems="stretch"
              >
                <Grid item>
                  <CircularProgress
                    size={10}
                    variant={progress > 0 ? "determinate" : "indeterminate"}
                    value={progress}
                  />
                  &nbsp;
                  {progress}%
                  <Tooltip title="Unique concepts identified [acceptably explained]">
                    <Typography>
                      {uniqueConcepts} [{acceptableUniqueConcepts}]
                    </Typography>
                  </Tooltip>
                  {reviewStatus}
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
          }
        }}
      />
    </Paper>
  );
}
CandidatesReviewTable.propTypes = {
  rootPath: PropTypes.string
};
