import React from "react";
import LocalLibraryIcon from "@mui/icons-material/LocalLibrary";
import GridOffIcon from "@mui/icons-material/GridOff";
import TuneIcon from "@mui/icons-material/Tune";

export function iconForType(type) {
  var icon;
  if (["Group Experience", "Experiences"].includes(type)) {
    icon = <LocalLibraryIcon />;
  } else if (["Project", "Assessments"].includes(type)) {
    icon = <TuneIcon />;
  } else if (["Terms List", "Bingo Games"].includes(type)) {
    icon = <GridOffIcon />;
  } else {
    console.log(type);
  }
  return icon;
}
