import React from "react";
import PropTypes from "prop-types";
import deburr from 'lodash/deburr';

const Autosuggest = React.lazy( () =>
  import( "react-autosuggest" ));
import match from "autosuggest-highlight/match";
import parse from "autosuggest-highlight/parse";

import TextField from "@mui/material/TextField";
import Paper from "@mui/material/Paper";
import MenuItem from "@mui/material/MenuItem";
import withStyles from "@mui/styles/withStyles";
import axios from "axios";
function renderInputComponent(inputProps) {
  const { classes, inputRef = () => {}, ref, ...other } = inputProps;
  return (
    <TextField
      fullWidth
      InputProps={{
        inputRef: node => {
          ref(node);
          inputRef(node);
        },
        classes: {
          input: classes.input
        }
      }}
      {...other}
    />
  );
}
function renderSuggestion(suggestion, { query, isHighlighted }) {
  const matches = match(suggestion.label, query);
  const parts = parse(suggestion.label, matches);
  return (
    <MenuItem selected={isHighlighted} component="div">
      <div>
        {parts.map((part, index) =>
          part.highlight ? (
            <span key={String(index)} style={{ fontWeight: 500 }}>
              {part.text}
            </span>
          ) : (
            <strong key={String(index)} style={{ fontWeight: 300 }}>
              {part.text}
            </strong>
          )
        )}
      </div>
    </MenuItem>
  );
}
function getSuggestionValue(suggestion) {
  return suggestion.label;
}
const styles = theme => ({
  root: {
    flexGrow: 1
  },
  container: {
    position: "relative"
  },
  suggestionsContainerOpen: {
    position: "absolute",
    zIndex: 1,
    marginTop: theme.spacing(1),
    left: 0,
    right: 0
  },
  suggestion: {
    display: "block"
  },
  suggestionsList: {
    margin: 0,
    padding: 0,
    listStyleType: "none"
  },
  divider: {
    height: theme.spacing(2)
  }
});
class RemoteAutoSuggest extends React.Component {
  state = {
    single: "",
    popper: "",
    suggestions: []
  };
  handleSuggestionsFetchRequested = ({ value }) => {
    this.getData(deburr(value.trim()).toLowerCase());
  };
  handleSuggestionsClearRequested = () => {
    this.setState({
      suggestions: []
    });
  };
  handleChange = name => (event, { newValue }) => {
    this.props.setFunction(this.props.itemId, newValue);
    this.setState({
      [name]: newValue
    });
  };
  getData = function(value) {
    const url = this.props.dataUrl + ".json?search_string=" + value;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        let suggestions = [];
        data.map(item => {
          suggestions.push({ label: item.name });
        });
        this.setState({
          suggestions: suggestions
        });
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      });
  };
  render() {
    const { classes } = this.props;
    const autosuggestProps = {
      renderInputComponent,
      suggestions: this.state.suggestions,
      onSuggestionsFetchRequested: this.handleSuggestionsFetchRequested,
      onSuggestionsClearRequested: this.handleSuggestionsClearRequested,
      getSuggestionValue,
      renderSuggestion
    };
    return (
      <div className={classes.root}>
        <Autosuggest
          {...autosuggestProps}
          inputProps={{
            classes,
            id: this.props.controlId,
            placeholder: this.props.inputLabel,
            value: this.props.enteredValue,
            onChange: this.handleChange("single")
          }}
          theme={{
            container: classes.container,
            suggestionsContainerOpen: classes.suggestionsContainerOpen,
            suggestionsList: classes.suggestionsList,
            suggestion: classes.suggestion
          }}
          renderSuggestionsContainer={options => (
            <Paper {...options.containerProps} square>
              {options.children}
            </Paper>
          )}
        />
      </div>
    );
  }
}
RemoteAutoSuggest.propTypes = {
  inputLabel: PropTypes.string,
  classes: PropTypes.object.isRequired,
  itemId: PropTypes.number.isRequired,
  enteredValue: PropTypes.string,
  controlId: PropTypes.string,
  dataUrl: PropTypes.string,
  setFunction: PropTypes.func.isRequired
};
export default withStyles(styles)(RemoteAutoSuggest);
