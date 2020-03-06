import React, { Suspense, useState, useEffect } from "react";
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
import Tabs from "@material-ui/core/Tabs";
import Tab from "@material-ui/core/Tab";
import Typography from "@material-ui/core/Typography";
import InputLabel from "@material-ui/core/InputLabel";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";

import Skeleton from "@material-ui/lab/Skeleton";

import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";

import { DateTime } from "luxon";
import LuxonUtils from "@date-io/luxon";
import {useEndpointStore} from './EndPointStore'
import { useUserStore } from "./UserStore"

import { EditorState, convertToRaw, ContentState } from "draft-js";
import { Editor } from "react-draft-wysiwyg";
import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";

import i18n from "./i18n";
import { useTranslation } from "react-i18next";

import { makeStyles } from "@material-ui/core/styles";

import ConceptChips from "./ConceptChips";
import BingoGameDataAdminTable from "./BingoGameDataAdminTable";

const useStyles = makeStyles({
  container: {
    display: "flex",
    flexWrap: "wrap"
  },
  textField: {
    width: 200
  },
  dense: {
    marginTop: 19
  },
  menu: {
    width: 200
  }
});

export default function BingoGameDataAdmin(props) {
  const classes = useStyles();

  const endpointSet = 'bingo_game'
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();

  const { t, i18n } = useTranslation("bingo_games");

  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState( false );
  const [curTab, setCurTab] = useState("details");
  const [messages, setMessages] = useState({});
  const [gameProjects, setGameProjects] = useState([
    { id: -1, name: "None Selected" }
  ]);
  const [concepts, setConcepts] = useState([]);
  const [saveStatus, setSaveStatus] = useState("");
  const [resultData, setResultData] = useState(null);
  const [gameTopic, setGameTopic] = useState("");
  const [gameDescriptionEditor, setGameDescriptionEditor] = useState(
    EditorState.createWithContent(
      ContentState.createFromBlockArray(htmlToDraft("").contentBlocks)
    )
  );
  const [bingoGameId, setBingoGameId] = useState( props.bingoGameId)
  const [gameSource, setGameSource] = useState("");
  const [gameTimezone, setGameTimezone] = useState("UTC");
  const [gameActive, setGameActive] = useState(false);
  const [gameEndDate, setGameEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      .toJSDate()
  );
  const [gameStartDate, setGameStartDate] = useState(
    DateTime.local().toJSDate()
  );
  const [gameIndividualCount, setGameIndividualCount] = useState(0);
  const [gameLeadTime, setGameLeadTime] = useState(0);
  //Group parameters
  const [gameGroupOption, setGameGroupOption] = useState(false);
  const [gameGroupDiscount, setGameGroupDiscount] = useState(0);
  const [gameGroupProjectId, setGameGroupProjectId] = useState(-1);

  useEffect(() => {
    if( endpoints.endpointStatus[endpointSet] != 'loaded'){
      endpointsActions.fetch(endpointSet,props.getEndpointsUrl, props.token);
    }
  }, []);

  useEffect(() =>{
    if (endpoints.endpointStatus[endpointSet] == 'loaded') {
      getBingoGameData();
      initResultData();
    }
  }, [
    endpoints.endpointStatus[endpointSet]
  ]);

  useEffect(() => {
    setDirty(true);
  }, [
    gameTopic,
    gameDescriptionEditor,
    gameSource,
    gameTimezone,
    gameActive,
    gameStartDate,
    gameEndDate,
    gameIndividualCount,
    gameLeadTime,
    gameGroupOption,
    gameGroupDiscount,
    gameGroupProjectId
  ]);

  const saveBingoGame = () => {
    const method = null == bingoGameId ? 'POST' : 'PATCH';
    setWorking( true );

    const url =
    endpoints.endpoints[endpointSet].bingoGameUrl + '/' + (null == bingoGameId ? props.courseId : bingoGameId) + '.json';

    // Save
    setSaveStatus(t("save_status"));
    fetch(url, {
      method: method,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        bingo_game: {
          course_id: props.courseId,
          topic: gameTopic,
          description: draftToHtml(
            convertToRaw(gameDescriptionEditor.getCurrentContent())
          ),
          source: gameSource,
          active: gameActive,
          start_date: gameStartDate,
          end_date: gameEndDate,
          individual_count: gameIndividualCount,
          lead_time: gameLeadTime,
          group_option: gameGroupOption,
          group_discount: gameGroupDiscount,
          project_id: gameGroupProjectId
        }
      })
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
        setSaveStatus(data.notice);
        setDirty(false);
        setMessages(data.messages);

        getBingoGameData();
      });
  };

  const initResultData = () => {
    if( bingoGameId > 0 ){
    fetch(endpoints.endpoints[endpointSet].gameResultsUrl + '/' + bingoGameId + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
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
        setResultData(data);
      });

    }
  };

  const getBingoGameData = () => {
    setDirty( true );
    var url = endpoints.endpoints[endpointSet].bingoGameUrl + '/'
    if( null == bingoGameId ){
      url = url + 'new/' + props.courseId  + '.json';
    } else {
      url = url + bingoGameId + '.json';
    }
    fetch( url, {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
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
        const projects = new Array({ id: -1, name: "None Selected" }).concat(
          data.projects
        );

        setGameProjects(projects);
        setConcepts(data.concepts);

        //Set the bingo_game stuff
        const bingo_game = data.bingo_game;
        setBingoGameId(bingo_game.id);
        setGameTopic(bingo_game.topic || '');
        setGameDescriptionEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(bingo_game.description || '').contentBlocks
            )
          )
        );
        setGameSource(bingo_game.source || '');
        setGameActive(bingo_game.active || false);
        var receivedDate = DateTime.fromISO( bingo_game.start_date).setZone( bingo_game.course.timezone )
        setGameStartDate(receivedDate.toISO());
        setGameEndDate(DateTime.fromISO(bingo_game.end_date).setZone( bingo_game.course.timezone ).toISO());
        setGameIndividualCount(bingo_game.individual_count || 0);
        setGameLeadTime(bingo_game.lead_time || 0);
        //Group options
        setGameGroupOption(bingo_game.group_option || false);
        setGameGroupDiscount(bingo_game.group_discount || 0);
        setGameGroupProjectId(bingo_game.project_id);
        setDirty(false);
      });
  };

  const changeTab = (event, name) => {
    setCurTab(name);
  };

  const save_btn = dirty ? (
    <Suspense fallback={<Skeleton variant="text" />}>
      <Button
        variant="contained"
        color="primary"
        className={classes.button}
        onClick={saveBingoGame}
        id="save_bingo_game"
        value="save_bingo_game"
      >
        {null == bingoGameId ? t('create_bingo_btn') : t('update_bingo_btn')}
      </Button>
    </Suspense>
  ) : null;

  const group_options = gameGroupOption ? (
    <Suspense fallback={<Skeleton variant="text" />}>
      <React.Fragment>
        <Grid item>
          <TextField
            id="bingo-name"
            label={t("group_discount")}
            type="number"
            className={classes.textField}
            value={gameGroupDiscount}
            onChange={event => setGameGroupDiscount(event.target.value)}
            margin="normal"
            error={null != messages.name}
            helper={messages.name}
          />
        </Grid>
        <Grid item>
          <FormControl className={classes.formControl}>
            <InputLabel shrink htmlFor="bingo_game_project_id">
              {t("group_source")}
            </InputLabel>
            <Select
              id="bingo_game_project_id"
              value={gameGroupProjectId}
              onChange={event => setGameGroupProjectId(event.target.value)}
              displayEmpty
              name="bingo_game_project"
              className={classes.selectEmpty}
            >
              {gameProjects.map(project => {
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
    </Suspense>
  ) : null;
  return (
    <Suspense fallback={<Skeleton variant="text" />}>
      <Paper style={{ height: "95%", width: "100%" }}>
        <Tabs value={curTab} onChange={changeTab} centered>
          <Tab value="details" label={t("game_details_pnl")} />
          <Tab value="results" label={t("response_pnl")} />
        </Tabs>
        {"details" == curTab && (
          <React.Fragment>
            <Grid container spacing={10}>
              <Grid item>
                <TextField
                  id="topic"
                  label={t("topic")}
                  className={classes.textField}
                  value={gameTopic}
                  onChange={event => setGameTopic(event.target.value)}
                  margin="normal"
                />
              </Grid>
              <Grid item>
                <Editor
                  wrapperId='Description'
                  label={t("description")}
                  placeholder={t('description')}
                  onEditorStateChange={setGameDescriptionEditor}
                  toolbarOnFocus
                  toolbar={{
                    options: ["inline", "list", "link"]
                  }}
                  editorState={gameDescriptionEditor}
                />
              </Grid>
              <Grid item>
                <TextField
                  id="bingo-lead-time"
                  label={t("lead_time")}
                  className={classes.lead_time}
                  value={gameLeadTime}
                  type="number"
                  onChange={event => setGameLeadTime(event.target.value)}
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
                  value={gameIndividualCount}
                  type="number"
                  onChange={event => setGameIndividualCount(event.target.value)}
                  InputLabelProps={{
                    shrink: true
                  }}
                  margin="normal"
                  error={null != messages.individual_count}
                  helperText={messages.individual_count}
                />
              </Grid>
              <MuiPickersUtilsProvider utils={LuxonUtils}>
                <Grid item>
                  <KeyboardDatePicker
                    disableToolbar
                    variant="inline"
                    autoOk={true}
                    format="MM/dd/yyyy"
                    margin="normal"
                    id="bingo_game_start_date"
                    label={t("open_date")}
                    value={gameStartDate}
                    onChange={setGameStartDate}
                  />
                  { null != messages.start_date ?
                  (<FormHelperText error={true}>
                    {messages.start_date}
                  </FormHelperText>): null}
                </Grid>
                <Grid item>
                  <KeyboardDatePicker
                    disableToolbar
                    variant="inline"
                    autoOk={true}
                    format="MM/dd/yyyy"
                    margin="normal"
                    id="bingo_game_end_date"
                    label={t("close_date")}
                    value={gameEndDate}
                    onChange={setGameEndDate}
                  />
                  { null != messages.end_date ?
                  (<FormHelperText error={true}>
                    {messages.end_date}
                  </FormHelperText>): null}
                </Grid>
              </MuiPickersUtilsProvider>
              <Grid item>
                <FormControlLabel
                  control={
                    <Switch
                      checked={gameActive}
                      onChange={event => setGameActive(!gameActive)}
                    />
                  }
                  label={t("active")}
                />
              </Grid>
              <Grid item>
                <Switch
                  checked={gameGroupOption}
                  id="group_option"
                  onChange={event => setGameGroupOption(!gameGroupOption)}
                  disabled={null == gameProjects || 2 > gameProjects.length}
                />
                <InputLabel htmlFor="group_option">
                  {t("group_option")}
                </InputLabel>
              </Grid>
              {group_options}
            </Grid>
            {save_btn} {messages.status}
            <Typography>{saveStatus}</Typography>
          </React.Fragment>
        )}
        {"results" == curTab && (
          <Grid container style={{ height: "100%" }}>
            <Grid item xs={5}>
              <ConceptChips concepts={concepts} />
            </Grid>
            <Grid item xs={7}>
              <BingoGameDataAdminTable results_raw={resultData} />
            </Grid>
          </Grid>
        )}
      </Paper>
    </Suspense>
  );
}

BingoGameDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  courseId: PropTypes.number.isRequired,
  bingoGameId: PropTypes.number
};
