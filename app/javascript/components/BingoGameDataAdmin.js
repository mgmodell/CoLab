import React from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import Paper from "@material-ui/core/Paper";
import TextField from "@material-ui/core/TextField";
import Grid from "@material-ui/core/Grid";
import ExpansionPanel from "@material-ui/core/ExpansionPanel";
import ExpansionPanelSummary from "@material-ui/core/ExpansionPanelSummary";
import ExpansionPanelDetails from "@material-ui/core/ExpansionPanelDetails";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";

import ExpandMoreIcon from "@material-ui/icons/ExpandMore";

import { withStyles } from "@material-ui/core/styles";

import ConceptChips from "./ConceptChips";
import BingoGameDataAdminTable from "./BingoGameDataAdminTable";

const styles = theme => ({
  container: {
    display: "flex",
    flexWrap: "wrap"
  },
  textField: {
    marginLeft: theme.spacing.unit,
    marginRight: theme.spacing.unit,
    width: 200
  },
  dense: {
    marginTop: 19
  },
  menu: {
    width: 200
  }
});

class BingoGameDataAdmin extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      bingo_game: {
        topic: "",
        active: false,
        description: "",
        start_date: null,
        end_date: null,
        group_option: false,
        group_discount: 0,
        lead_time: 0,
        reviewed: false,
        source: null
      }
    };
  }

  componentDidMount() {
    this.getBingoGameData();
  }

  getBingoGameData() {
    fetch(this.props.bingoGameUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        this.setState({
          bingo_game: data
        });
      });
  }

  handleTextChange = name => event => {
    let bingo = this.state.bingo_game;
    bingo[name] = event.target.value;
    this.setState({ bingo_game: bingo });
  };

  handleCheckChange = name => event => {
    let bingo = this.state.bingo_game;
    bingo[name] = event.target.checked;
    this.setState({ bingo_game: bingo });
  };

  render() {
    const { classes } = this.props;
    return (
      <Paper>
        <ExpansionPanel defaultExpanded={true}>
          <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
            Game details:
          </ExpansionPanelSummary>
          <ExpansionPanelDetails>
            <Grid container spacing={16}>
              <Grid item>
                <TextField
                  id="bingo-name"
                  label="Name"
                  className={classes.textField}
                  value={this.state.bingo_game.topic}
                  onChange={this.handleTextChange("topic")}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <TextField
                  id="bingo-description"
                  label="Description"
                  className={classes.textField}
                  value={this.state.bingo_game.description}
                  onChange={this.handleTextChange("description")}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <FormControlLabel
                  control={
                    <Switch
                      checked={this.state.bingo_game.active}
                      onChange={this.handleCheckChange("active")}
                    />
                  }
                  label="Active"
                />
              </Grid>
            </Grid>
          </ExpansionPanelDetails>
        </ExpansionPanel>

        <ExpansionPanel disabled={!this.state.bingo_game.reviewed}>
          <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
            Response data:
          </ExpansionPanelSummary>
          <ExpansionPanelDetails>
            <Grid container>
              <Grid item xs={5}>
                <ConceptChips
                  token={this.props.token}
                  url={this.props.conceptUrl}
                />
              </Grid>
              <Grid item xs={7}>
                <BingoGameDataAdminTable
                  token={this.props.token}
                  gameResultsUrl={this.props.gameResultsUrl}
                />
              </Grid>
            </Grid>
          </ExpansionPanelDetails>
        </ExpansionPanel>
      </Paper>
    );
  }
}

BingoGameDataAdmin.propTypes = {
  bingoGameUrl: PropTypes.string.isRequired,
  token: PropTypes.string.isRequired,
  conceptUrl: PropTypes.string.isRequired,
  gameResultsUrl: PropTypes.string.isRequired
};
export default withStyles(styles)(BingoGameDataAdmin);
