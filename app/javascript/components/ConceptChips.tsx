import React from "react";
import PropTypes from "prop-types";
import Chip from "@mui/material/Chip";
import Paper from "@mui/material/Paper";

export default function ConceptChips(props) {
  var c = [{ id: 1, name: "nothing" }];

  return (
    <Paper>
      {props.concepts.map(chip => {
        return (
          <Chip key={chip.id} id={`concept_${chip.id}`} label={chip.name} />
        );
      })}
    </Paper>
  );
}

ConceptChips.propTypes = {
  concepts: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string
    })
  )
};
