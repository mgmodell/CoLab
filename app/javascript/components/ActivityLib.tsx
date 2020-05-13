import React from 'react';
import LocalLibraryIcon from "@material-ui/icons/LocalLibrary";
import GridOffIcon from "@material-ui/icons/GridOff";
import TuneIcon from "@material-ui/icons/Tune";

export function iconForType( type ){
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
  };