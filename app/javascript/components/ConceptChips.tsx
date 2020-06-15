import React from "react";
import PropTypes from "prop-types";
import Chip from "@material-ui/core/Chip";
import Paper from "@material-ui/core/Paper";

export default function ConceptChips(props) {
  var c = [{ id: 1, name: "nothing" }];

  return (
      <Paper>
        {props.concepts.map(chip => {
          return <Chip key={chip.id} id={`concept_${chip.id}`} label={chip.name} />;
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
