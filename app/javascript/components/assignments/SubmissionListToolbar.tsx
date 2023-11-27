import React from "react";

import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import {
  GridToolbarQuickFilter,
  GridToolbarContainer,
  GridToolbarDensitySelector,
  GridToolbarFilterButton
} from "@mui/x-data-grid";
import { IconButton } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import Tooltip from "@mui/material/Tooltip";

type Props = {
  selectSubmissionFunc: (selectedSub: string) => void;
};

export default function SubmissionListToolbar(props: Props) {
  const category = "assignment";
  const { t } = useTranslation(`${category}s`);

  return (
    <GridToolbarContainer>
      <GridToolbarDensitySelector />
      <GridToolbarFilterButton />
      <Tooltip title={t("submissions.new_btn")}>
        <IconButton
          id="new_sub"
          onClick={event => {
            props.selectSubmissionFunc("new");
            // Pop up the AssignmentSubmission component in a dialog
          }}
          aria-label={t(`submissions.new_btn`)}
          size="small"
        >
          <AddIcon />
          {t("submissions.new_btn")}
        </IconButton>
      </Tooltip>
      <GridToolbarQuickFilter debounceMs={50} />
    </GridToolbarContainer>
  );
}
