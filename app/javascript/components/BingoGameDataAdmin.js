import React from "react";
import PropTypes from "prop-types";
import classNames from "classnames";
import Paper from "@material-ui/core/Paper";
import TextField from "@material-ui/core/TextField";
import Button from "@material-ui/core/Button";
import Grid from "@material-ui/core/Grid";
import FormControl from "@material-ui/core/FormControl";
import MenuItem from "@material-ui/core/MenuItem";
import Select from "@material-ui/core/Select";
import Input from "@material-ui/core/Input";
import Typography from "@material-ui/core/Typography";
import InputLabel from "@material-ui/core/InputLabel";
import ExpansionPanel from "@material-ui/core/ExpansionPanel";
import ExpansionPanelSummary from "@material-ui/core/ExpansionPanelSummary";
import ExpansionPanelDetails from "@material-ui/core/ExpansionPanelDetails";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";

import { EditorState, convertToRaw, ContentState } from "draft-js";
import { Editor } from "react-draft-wysiwyg";
import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";

import get_i18n from "./i18n";

import ExpandMoreIcon from "@material-ui/icons/ExpandMore";

import { withStyles } from "@material-ui/core/styles";

import ConceptChips from "./ConceptChips";
import BingoGameDataAdminTable from "./BingoGameDataAdminTable";

const t = get_i18n("bingo_games");

const styles = theme => ({
  container: {
    display: "flex",
    flexWrap: "wrap"
  },
  textField: {
    marginLeft: theme.spacing(),
    marginRight: theme.spacing(),
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
    let start = new Date();
    let end = new Date();
    end.setDate(end.getDate() + 7);
    this.state = {
      dirty: false,
      messages: {},
      saveStatus: "",
      tz_extra_start: start.toISOString().substr(10),
      tz_extra_end: end.toISOString().substr(10),
      bingo_game: {
        topic: "",
        active: false,
        description: "",
        start_date: start.toISOString().substr(0, 10),
        end_date: end.toISOString().substr(0, 10),
        group_option: false,
        group_discount: 0,
        individual_count: 0,
        lead_time: 0,
        reviewed: false,
        source: null,
        project_id: ""
      }
    };
    this.saveBingoGame = this.saveBingoGame.bind(this);
  }

  componentDidMount() {
    this.getBingoGameData();
  }

  saveBingoGame() {
    const { bingo_game, descriptionEditor } = this.state;
    var bg_sav = Object.assign({}, bingo_game);
    delete bg_sav.projects;
    delete bg_sav.reviewed;
    bg_sav.start_date = bg_sav.start_date + this.state.tz_extra_start;
    bg_sav.end_date = bg_sav.end_date + this.state.tz_extra_end;
    bg_sav.description = draftToHtml(
      convertToRaw(descriptionEditor.getCurrentContent())
    );
    this.setState({
      saveStatus: t("save_status")
    });
    fetch(this.props.bingoGameUrl + ".json", {
      method: "PATCH",
      credentials: "include",
      body: JSON.stringify({ bingo_game: bg_sav }),
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
          return {};
        }
      })
      .then(data => {
        //TODO: handle save errors
        this.setState({
          saveStatus: data.notice,
          dirty: false,
          messages: data.messages
        });
        this.getBingoGameData();
      });
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
        const tz_extra_start = data.start_date.substr(10);
        const tz_extra_end = data.end_date.substr(10);
        data.start_date = data.start_date.substr(0, 10);
        data.end_date = data.end_date.substr(0, 10);
        if (data.group_discount == null) {
          data.group_discount = 0;
        }
        if (data.project_id == null) {
          data.project_id = data.projects[0].id;
        }
        const contentBlock = htmlToDraft(data.description);
        const contentState = ContentState.createFromBlockArray(
          contentBlock.contentBlocks
        );
        const editorState = EditorState.createWithContent(contentState);
        this.setState({
          tz_extra_start: tz_extra_start,
          tz_extra_end: tz_extra_end,
          descriptionEditor: editorState,
          bingo_game: data
        });
      });
  }

  handleChange = name => event => {
    let bingo = this.state.bingo_game;
    bingo[name] = event.target.value;
    this.setState({
      dirty: true,
      bingo_game: bingo
    });
  };

  handleNumberChange = name => event => {
    let bingo = this.state.bingo_game;
    bingo[name] = parseInt(event.target.value);
    this.setState({
      dirty: true,
      bingo_game: bingo
    });
  };

  handleCheckChange = name => event => {
    let bingo = this.state.bingo_game;
    bingo[name] = event.target.checked;
    this.setState({
      dirty: true,
      bingo_game: bingo
    });
  };

  onEditorStateChange = editorState => {
    this.setState({
      dirty: true,
      descriptionEditor: editorState
    });
  };

  render() {
    const { classes } = this.props;
    const save_btn = this.state.dirty ? (
      <React.Fragment>
        <Button
          variant="contained"
          color="primary"
          className={classes.button}
          onClick={this.saveBingoGame}
          id="save_bingo_game"
          value="save_bingo_game"
        >
          {t("update_bingo_btn")}
        </Button>
      </React.Fragment>
    ) : null;

    const group_options = this.state.bingo_game.group_option ? (
      <React.Fragment>
        <Grid item>
          <TextField
            id="bingo-name"
            label={t("group_discount")}
            type="number"
            className={classes.textField}
            value={this.state.bingo_game.group_discount}
            onChange={this.handleChange("group_discount")}
            margin="normal"
          />
        </Grid>
        <Grid item>
          <FormControl className={classes.formControl}>
            <InputLabel shrink htmlFor="bingo_game_project_id">
              {t("group_source")}
            </InputLabel>
            <Select
              value={this.state.bingo_game.project_id}
              onChange={this.handleChange("project_id")}
              input={
                <Input name="bingo_game_project" id="bingo_game_project_id" />
              }
              displayEmpty
              name="bingo_game_project"
              className={classes.selectEmpty}
            >
              {this.state.bingo_game.projects.map(project => {
                return (
                  <MenuItem value={project.id} key={project.id}>
                    {project.name}
                  </MenuItem>
                );
              })}
            </Select>
          </FormControl>
        </Grid>
      </React.Fragment>
    ) : null;
    return (
      <Paper>
        <ExpansionPanel defaultExpanded={true}>
          <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
            {t("game_details_pnl")}:
          </ExpansionPanelSummary>
          <ExpansionPanelDetails>
            <Grid container spacing={10}>
              <Grid item>
                <TextField
                  id="topic"
                  label={t("topic")}
                  className={classes.textField}
                  value={this.state.bingo_game.topic}
                  onChange={this.handleChange("topic")}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <Editor
                  toolbarClassName="demo-toolbar-absolute"
                  wrapperId="Description"
                  label={t("description")}
                  onEditorStateChange={this.onEditorStateChange}
                  toolbarOnFocus
                  toolbar={{
                    options: ["inline", "list", "link"]
                  }}
                  editorState={this.state.descriptionEditor}
                />
              </Grid>
              <Grid item>
                <TextField
                  id="bingo-lead-time"
                  label={t("lead_time")}
                  className={classes.lead_time}
                  value={this.state.bingo_game.lead_time}
                  type="number"
                  onChange={this.handleNumberChange("lead_time")}
                  InputLabelProps={{
                    shrink: true
                  }}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <TextField
                  id="bingo-individual_count"
                  label={t("ind_term_count")}
                  className={classes.textField}
                  value={this.state.bingo_game.individual_count}
                  type="number"
                  onChange={this.handleNumberChange("individual_count")}
                  InputLabelProps={{
                    shrink: true
                  }}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <TextField
                  id="bingo-start_date"
                  label={t("open_date")}
                  className={classes.textField}
                  value={this.state.bingo_game.start_date}
                  type="date"
                  onChange={this.handleChange("start_date")}
                  InputLabelProps={{
                    shrink: true
                  }}
                  helperText={this.state.messages["start_date"]}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <TextField
                  id="bingo-close_date"
                  label={t("close_date")}
                  className={classes.textField}
                  value={this.state.bingo_game.end_date}
                  type="date"
                  onChange={this.handleChange("end_date")}
                  InputLabelProps={{
                    shrink: true
                  }}
                  helperText={this.state.messages["end_date"]}
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
                  label={t("active")}
                />
              </Grid>
              <Grid item>
                <Switch
                  checked={this.state.bingo_game.group_option}
                  id="group_option"
                  onChange={this.handleCheckChange("group_option")}
                />
                <InputLabel htmlFor="group_option">
                  {t("group_option")}
                </InputLabel>
              </Grid>
              {group_options}
            </Grid>
            {save_btn}
            <Typography>{this.state.saveStatus}</Typography>
          </ExpansionPanelDetails>
        </ExpansionPanel>

        <ExpansionPanel disabled={!this.state.bingo_game.reviewed}>
          <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
            {t("response_pnl")}:
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
