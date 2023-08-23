import React from "react";

import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import {
  GridToolbarQuickFilter,
  GridToolbarContainer,
  GridToolbarDensitySelector,
  GridToolbarFilterButton,
  GridToolbarColumnsButton
} from "@mui/x-data-grid";
import { Button, Checkbox, CircularProgress, FormControlLabel, IconButton, Typography } from "@mui/material";
import Grid from '@mui/material/Grid';
import AddIcon from "@mui/icons-material/Add";
import Tooltip from "@mui/material/Tooltip";

type Props = {
    progress: number;
    uniqueConcepts: number;
    acceptableUniqueConcepts: number;
    dirty: boolean;
    reviewStatus: string;
    reviewComplete: boolean;
    setReviewCompleteFunc: (boolean) => void;
    saveFeedbackFunc: () => void;
    reloadFunc: () => void;
}

export default function CandidateReviewListToolbar(props: Props) {
  const category = 'bingo_games';
  const { t } = useTranslation(category);

  const notify =
    props.progress < 100 ? null : (
      <FormControlLabel
        control={
          <Checkbox
            id="review_complete"
            onClick={() => props.setReviewCompleteFunc(!props.reviewComplete)}
            checked={props.reviewComplete}
          />
        }
        label={t('review.review_complete_msg')}
      />
    );
  const saveButton = (
    <Button
      disabled={!props.dirty}
      variant="contained"
      onClick={() => props.saveFeedbackFunc()}
    >
      Save
    </Button>
  );
  return (
    <GridToolbarContainer>
      <GridToolbarColumnsButton />
      <GridToolbarDensitySelector />
      <GridToolbarFilterButton />
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
            variant={props.progress > 0 ? "determinate" : "indeterminate"}
            value={props.progress}
          />
          &nbsp;
          {props.progress}%
          <Tooltip title="Unique concepts identified [acceptably explained]">
            <Typography>
              {props.uniqueConcepts} [{props.acceptableUniqueConcepts}]
            </Typography>
          </Tooltip>
          {props.reviewStatus}
          {notify}
        </Grid>
        <Grid item>
          <Button variant="contained" onClick={() => props.reloadFunc()}>
            {t('review.reload_btn')}
          </Button>
          {saveButton}
        </Grid>
      </Grid>

      <GridToolbarQuickFilter debounceMs={50} />
    </GridToolbarContainer>
  );
}
