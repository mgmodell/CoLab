import React from "react";
import LocalLibraryIcon from "@mui/icons-material/LocalLibrary";
import GridOffIcon from "@mui/icons-material/GridOff";
import TuneIcon from "@mui/icons-material/Tune";
import AssignmentIcon from "@mui/icons-material/Assignment";

export function iconForType(type: string) {
  var icon;
  switch( type.toLowerCase( )){
    case 'group experience':
    case 'experience':
    case 'experiences':
      icon = <LocalLibraryIcon />;
      break;
    case 'project':
    case 'assessment':
    case 'assessments':
      icon = <TuneIcon />;
      break;
    case 'terms list':
    case 'bingo_game':
    case 'bingo games':
      icon = <GridOffIcon />;
      break;
    case 'group assignment':
    case 'assignment':
      icon = <AssignmentIcon />;
      break;
    default:
      console.log( `No icon match for: ${type}`);
  }
  return icon;
}
