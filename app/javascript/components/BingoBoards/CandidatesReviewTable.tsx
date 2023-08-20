/* eslint-disable no-console */
import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import PropTypes from "prop-types";
import Paper from "@mui/material/Paper";
import Grid from "@mui/material/Grid";
import Link from "@mui/material/Link";
import Skeleton from "@mui/material/Skeleton";
import Select from "@mui/material/Select";
import MenuItem from "@mui/material/MenuItem";

import { useTranslation } from "react-i18next";
const RemoteAutosuggest = React.lazy(() => import("./RemoteAutosuggest"));
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import parse from 'html-react-parser';

import WorkingIndicator from "../infrastructure/WorkingIndicator";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import CandidateReviewListToolbar from "./CandidateReviewListToolbar";
import useResizeObserver from 'resize-observer-hook';
import { width } from "@mui/system";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";
import { DataTable } from "primereact/datatable";

import { Column } from "primereact/column";
import { Button } from "primereact/button";
import { standardTemplate } from "../StandardPaginatorTemplate";

export default function CandidatesReviewTable(props) {
  const category = "candidate_review";

  // Inconsistent naming follows. This should be cleaned up.
  const { t } = useTranslation("bingo_games");
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { bingoGameId } = useParams();
  const [ref, chartWidth, height] = useResizeObserver( );

  const paginatorLeft = <Button type="button" icon="pi pi-refresh" text />;
  const paginatorRight = <Button type="button" icon="pi pi-download" text />;

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
          name: t('review.not_set_opt')
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

        setReviewStatus(t('review.data_loaded_msg'));
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
    setReviewStatus(t('review.saving_msg'));

    const url = 
      props.rootPath === undefined
        ? `${endpoints.reviewSaveUrl}${bingoGameId}.json`
        : `/${props.rootPath}${endpoints.reviewSaveUrl}${bingoGameId}.json`;

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
        fail_data.notice = t('review.save_fail_msg');
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

  const toolbarHdr = <CandidateReviewListToolbar 
    progress={progress}
    uniqueConcepts={uniqueConcepts}
    acceptableUniqueConcepts={acceptableUniqueConcepts}
    dirty={dirty}
    reviewStatus={reviewStatus}
    reviewComplete={reviewComplete}
    setReviewCompleteFunc={setReviewComplete}
    saveFeedbackFunc={saveFeedback}
    reloadFunc={getData}
  />

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
            <p>
              {parse( bingoGame.description ) }
            </p>
          </Grid>
        </Grid>
      ) : (
        <Skeleton variant="rectangular" height={20} />
      )}
      <div ref={ref}>
        <DataTable value={candidates} resizableColumns tableStyle={{minWidth: '50rem'}}
          header={toolbarHdr}
          paginator rows={5} rowsPerPageOptions={[5, 10, 20, candidates.length]} paginatorDropdownAppendTo={'self'}
          paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
          currentPageReportTemplate="{first} to {last} of {totalRecords}" paginatorLeft={paginatorLeft} paginatorRight={paginatorRight}
          dataKey="id"
        >
          <Column field="number"  header='#' />
          <Column field='completed' header={t('review.completed_col')}
              body={(param)=>{ return 100 == param ? '*' : null}} />
          <Column field="user_id" header={t('review.submitter_col')}
              hidden
              body={(candidate) =>{
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

              }} />
          <Column field="term" header={t('review.term_col')} />
          <Column field="definition" header={t('review.definition_col')} />
          <Column field="candidate_feedback_id" header={t('review.feedback_col')}
            key='id'
              body={(candidate)=>{
                return (
                  <Select
                    value={candidate.candidate_feedback_id || 0}
                    onChange={event => {
                      feedbackSet(candidate.id, event.target.value);
                    }}
                    id={`feedback_4_${candidate.id}`}
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

              }}
              />
          <Column field='concept_id' header={t('review.concept_col')}
              body={(candidate)=>{
                let output = <div>{t('review.none_msg' )}</div>
                //const candidate = getById(candidates, params.row.id);
                const feedback = getById(
                  feedbackOptions,
                  candidate.candidate_feedback_id || 0
                );
                
                if (feedback.id !== 0 && "term_problem" !== feedback.critique) {
                  output = (
                    <RemoteAutosuggest
                      inputLabel={t('concept')}
                      itemId={candidate.id}
                      enteredValue={candidate.concept.name}
                      controlId={"concept_4_" + candidate.id}
                      dataUrl={endpoints.conceptUrl}
                      setFunction={conceptSet}
                      rootPath={props.rootPath}
                    />
                  );
                }
                return output;

              }}
          
              />
        </DataTable>

      </div>
    </Paper>
  );
}
CandidatesReviewTable.propTypes = {
  rootPath: PropTypes.string
};
