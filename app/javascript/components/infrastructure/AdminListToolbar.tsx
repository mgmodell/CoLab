import React from "react";

import { useNavigate } from "react-router-dom";

import { GridToolbarContainer, GridToolbarDensitySelector, GridToolbarFilterButton } from "@mui/x-data-grid";
import { IconButton } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import Tooltip from "@mui/material/Tooltip";

export default function AdminListToolbar( props ){

    const navigate = useNavigate( );
    return(
        <GridToolbarContainer>
            <GridToolbarDensitySelector />
            <GridToolbarFilterButton />
            <Tooltip title="New School">
              <IconButton
                id="new_school"
                onClick={event => {
                  navigate("new");
                  //window.location.href =
                  //  endpoints.endpoints[endpointSet].schoolCreateUrl;
                }}
                aria-label="New School"
                size='small'
              >
                <AddIcon />
                New
              </IconButton>
            </Tooltip>
        </GridToolbarContainer>
    )
}