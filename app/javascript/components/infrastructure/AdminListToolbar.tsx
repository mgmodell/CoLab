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
import { Button } from "primereact/button";
import { PrimeIcons } from "primereact/api";

type Props = {
  itemType: string;
};

export default function AdminListToolbar(props: Props) {
  const { t } = useTranslation(`admin`);
  const navigate = useNavigate();
  return (
    <div className="flex flex-wrap align-items-center justify-content-between gap-2">
            <span className="text-xl text-900 font-bold">Products</span>
            <Button
              tooltip={t('new_activity', {activity_type: props.itemType})}
              id={`new_${props.itemType}`}
              onClick={event => {
                navigate("new");
              }}
              aria-label={`New ${props.itemType}`}
              icon={ PrimeIcons.PLUS} rounded raised >
                {t("new_activity", { activity_type: props.itemType })}

              </Button>
        </div>
  );
}
