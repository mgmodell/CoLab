import React from "react";

import { useTranslation } from "react-i18next";

import {
    GridSeparatorIcon,
    GridToolbarColumnsButton,
    GridToolbarContainer,
    GridToolbarDensitySelector,
    GridToolbarExport,
    GridToolbarFilterButton,
    GridToolbarQuickFilter
} from '@mui/x-data-grid';


export default function StandardListToolbar( props ){

    return(
        <GridToolbarContainer>
            <GridToolbarDensitySelector />
            <GridToolbarColumnsButton />
            <GridToolbarFilterButton />
            <GridSeparatorIcon />
            <GridToolbarQuickFilter />
        </GridToolbarContainer>
    )
}