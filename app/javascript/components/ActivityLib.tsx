import React, { lazy } from "react";
const AssignmentIcon = lazy( () => import('@mui/icons-material/Assignment'))
const TuneIcon = lazy( () => import('@mui/icons-material/Tune'))
const LocalLibraryIcon = lazy( () => import('@mui/icons-material/LocalLibrary'))
const GridOffIcon = lazy( () => import('@mui/icons-material/GridOff'))
import AssignmentTurnedInIcon from '@mui/icons-material/AssignmentTurnedIn';

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
    case 'Assignments':
      icon = <AssignmentIcon />;
      break;
    case 'submission':
      icon = <AssignmentTurnedInIcon />;
      break;
    default:
      console.log( `No icon match for: ${type}`);
  }
  return icon;
}
