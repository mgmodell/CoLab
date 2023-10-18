import React, { useState } from "react";

import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import {
  GridToolbarQuickFilter,
  GridToolbarContainer,
  GridToolbarDensitySelector,
  GridToolbarFilterButton
} from "@mui/x-data-grid";
import { IconButton, Menu, MenuItem } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import Tooltip from "@mui/material/Tooltip";

import { iconForType } from "../ActivityLib";

interface IActivityLink {
  name: string;
  link: string;
}
type Props = {
  newActivityLinks: Array<IActivityLink>;
};

export default function CourseAdminListToolbar(props: Props) {
  const { t } = useTranslation(`admin`);
  const navigate = useNavigate();

  const [menuAnchorEl, setMenuAnchorEl] = useState(null);
  const addButton = (
    <React.Fragment>
      <IconButton
        onClick={event => {
          setMenuAnchorEl(event.currentTarget);
        }}
        aria-label="Add Activity"
        size="large"
      >
        <AddIcon />
      </IconButton>
      <Menu
        id="addMenu"
        anchorEl={menuAnchorEl}
        keepMounted
        open={Boolean(menuAnchorEl)}
        onClose={() => {
          setMenuAnchorEl(null);
        }}
      >
        {props.newActivityLinks.map(linkData => {
          return (
            <MenuItem
              key={linkData.name}
              onClick={event => {
                setMenuAnchorEl(null);
                navigate(`${linkData.link}/new`);
                // window.location.href = linkData.link;
              }}
            >
              {iconForType(linkData.name)}
              {" New " + linkData.name}&hellip;
            </MenuItem>
          );
        })}
      </Menu>
    </React.Fragment>
  );
  return (
    <GridToolbarContainer>
      <GridToolbarDensitySelector />
      <GridToolbarFilterButton />
      {addButton}
      <GridToolbarQuickFilter debounceMs={50} />
    </GridToolbarContainer>
  );
}
