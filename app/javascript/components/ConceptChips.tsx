import React from "react";
import PropTypes from "prop-types";
import { withTheme } from "@material-ui/core/styles";
import { MuiThemeProvider, createMuiTheme } from "@material-ui/core/styles";
import Chip from "@material-ui/core/Chip";
import Paper from "@material-ui/core/Paper";

function ConceptChips(props) {
  const theme = createMuiTheme();
  var c = [{ id: 1, name: "nothing" }];

  return (
    <MuiThemeProvider theme={theme}>
      <Paper>
        {props.concepts.map(chip => {
          return <Chip key={chip.id} label={chip.name} />;
        })}
      </Paper>
    </MuiThemeProvider>
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
export default withTheme(ConceptChips);
