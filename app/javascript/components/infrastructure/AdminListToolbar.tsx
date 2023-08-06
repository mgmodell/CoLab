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
    itemType: string;
}

export default function AdminListToolbar(props: Props) {
  const { t } = useTranslation(`admin`);
  const navigate = useNavigate();
  return (
    <GridToolbarContainer>
      <GridToolbarDensitySelector />
      <GridToolbarFilterButton />
      <Tooltip title="New">
        <IconButton
          id="new_school"
          onClick={event => {
            navigate("new");
            //window.location.href =
            //  endpoints.endpoints[endpointSet].schoolCreateUrl;
          }}
          aria-label={`New ${props.itemType}`}
          size="small"
        >
          <AddIcon />
          {t("new_activity", { activity_type: props.itemType })}
        </IconButton>
      </Tooltip>
      <GridToolbarQuickFilter debounceMs={50} />
    </GridToolbarContainer>
  );
}
