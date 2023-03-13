import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import Paper from "@mui/material/Paper";
import Box from "@mui/material/Box";
import TextField from "@mui/material/TextField";
import Button from "@mui/material/Button";
import Grid from "@mui/material/Grid";
import FormControl from "@mui/material/FormControl";
import MenuItem from "@mui/material/MenuItem";
import Select from "@mui/material/Select";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";
import InputLabel from "@mui/material/InputLabel";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";

import Skeleton from "@mui/material/Skeleton";

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";
import { TabContext, TabList, TabPanel } from "@mui/lab/";

import { DateTime } from "luxon";
import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";

import { EditorState, convertToRaw, ContentState } from "draft-js";
const Editor = React.lazy(() => import( "../reactDraftWysiwygEditor"));

import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";

import { useTranslation } from "react-i18next";

import makeStyles from "@mui/styles/makeStyles";

import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";

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

export default function AssignmentDataAdmin(props) {
  const classes = useStyles();

  const category = "assignment";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const { courseIdParam, assignmentIdParam } = useParams();
  const dispatch = useDispatch();

  const { t, i18n } = useTranslation(`${category}s`);

  const [dirty, setDirty] = useState(false);
  const [curTab, setCurTab] = useState("details");
  const [messages, setMessages] = useState({});
  const [assignmentProjects, setAssignmentProjects] = useState([
    { id: -1, name: "None Selected" }
  ]);
  const [availableRubrics, setAvailableRubrics] = useState([
    { id: -1, name: "None Selected", version: 0 }
  ]);
  const [saveStatus, setSaveStatus] = useState("");
  const [assignmentName, setAssignmentName] = useState("");
  const [assignmentDescriptionEditor, setAssignmentDescriptionEditor] = useState(
    EditorState.createWithContent(
      ContentState.createFromBlockArray(htmlToDraft("").contentBlocks)
    )
  );
  const [assignmentId, setAssignmentId] = useState(
    "new" === assignmentIdParam ? null : assignmentIdParam
  );
  const [assignmentActive, setAssignmentActive] = useState(false);
  const [assignmentEndDate, setAssignmentEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
  );
  const [assignmentStartDate, setAssignmentStartDate] = useState(
    DateTime.local()
  );
  //Group parameters
  const [assignmentGroupOption, setAssignmentGroupOption] = useState(false);
  const [assignmentGroupProjectId, setAssignmentGroupProjectId] = useState(-1);
  const [assignmentRubricId, setAssignmentRubricId] = useState(-1);

  useEffect(() => {
    if (endpointStatus) {
      getAssignmentData();
      // initResultData();
    }
  }, [endpointStatus]);

  useEffect(() => {
    setDirty(true);
  }, [
    assignmentName,
    assignmentDescriptionEditor,
    assignmentActive,
    assignmentStartDate,
    assignmentEndDate,
    assignmentGroupOption,
    assignmentGroupProjectId
  ]);

  const saveAssignment = () => {
    const method = null === assignmentId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null === assignmentId ? courseIdParam : assignmentId) +
      ".json";

    // Save
    setSaveStatus(t("save_status"));
    axios({
      url: url,
      method: method,
      data: {
        assignment: {
          course_id: courseIdParam,
          name: assignmentName,
          description: draftToHtml(
            convertToRaw(assignmentDescriptionEditor.getCurrentContent())
          ),
          active: assignmentActive,
          start_date: assignmentStartDate,
          end_date: assignmentEndDate,
          rubric_id: assignmentRubricId > 0 ? assignmentRubricId : null,
          group_enabled: assignmentGroupOption,
          project_id: assignmentGroupProjectId > 0 ? assignmentGroupProjectId : null
        }
      }
    })
      .then(response => {
        const data = response.data;
        //TODO: handle save errors
        setSaveStatus(data["notice"]);
        setDirty(false);
        setMessages(data["messages"]);
        dispatch(endTask("saving"));

        getAssignmentData();
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  const initResultData = () => {
    if (bingoGameId > 0) {
      dispatch(startTask());
      const url = endpoints.gameResultsUrl + "/" + bingoGameId + ".json";
      axios
        .get(url, {})
        .then(response => {
          const data = response.data;
          setResultData(data);
          dispatch(endTask());
        })
        .catch(error => {
          console.log("error", error);
        });
    }
  };

  const getAssignmentData = () => {
    setDirty(true);
    dispatch(startTask());
    var url = endpoints.baseUrl + "/";
    if (null === assignmentId) {
      url = url + "new/" + courseIdParam + ".json";
    } else {
      url = url + assignmentId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const projects = new Array({ id: -1, name: "None Selected" }).concat(
          data.projects
        );
        setAssignmentProjects(projects);
        const availableRubrics = new Array({ id: -1, name: "None Selected", version: 0 }).concat(
          data.rubrics
        );
        setAvailableRubrics(availableRubrics);


        //Set the bingo_game stuff
        const assignment = data.assignment;
        setAssignmentId(assignment.id);
        setAssignmentName(assignment.name || "");
        setAssignmentDescriptionEditor(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(assignment.description || "").contentBlocks
            )
          )
        );
        setAssignmentActive(assignment.active || false);
        var receivedDate = DateTime.fromISO(assignment.start_date).setZone(
          assignment.course.timezone
        );
        setAssignmentStartDate(receivedDate);
        setAssignmentEndDate(
          DateTime.fromISO(assignment.end_date)
            .setZone(assignment.course.timezone)
            
        );
        //Group options
        setAssignmentGroupOption(assignment.group_enabled || false);
        setAssignmentGroupProjectId(assignment.project_id || -1 );
        setAssignmentRubricId(assignment.rubric_id || -1 );
        setDirty(false);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
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
        className={classes["button"]}
        onClick={saveAssignment}
        id="save_assignment"
        value="save_assignment"
      >
        {null == assignmentId ? t("new.create_assignment_btn") : t("edit.update_assignment_btn")}
      </Button>
    </Suspense>
  ) : null;

  const group_options = assignmentGroupOption ? (
    <Suspense fallback={<Skeleton variant="text" />}>
      <React.Fragment>
        <Grid item xs={6}>
          <FormControl className={classes.formControl}>
            <InputLabel shrink htmlFor="assignment_project_id">
              {t("edit.group_source")}
            </InputLabel>
            <Select
              id="assignment_project_id"
              value={assignmentGroupProjectId}
              onChange={event => setAssignmentGroupProjectId(event.target.value)}
              displayEmpty
              name="assignment_project"
              className={classes.selectEmpty}
            >
              {assignmentProjects.map(project => {
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
        <TabContext value={curTab}>
          <Box>
            <TabList value={curTab} onChange={changeTab} centered>
              <Tab value="details" label={t("edit.assignment_details_pnl")} />
              <Tab value="results" label={t("edit.assignment_submissions_pnl")} />
            </TabList>
          </Box>
          <TabPanel value="details">
            <React.Fragment>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <TextField
                    id="name"
                    label={t("name")}
                    className={classes.textField}
                    value={assignmentName}
                    fullWidth
                    onChange={event => setAssignmentName(event.target.value)}
                    margin="normal"
                  />
                </Grid>
                <Grid item xs={12}>
                  <Editor
                    wrapperId="Description"
                    label={t("description")}
                    placeholder={t("description")}
                    onEditorStateChange={setAssignmentDescriptionEditor}
                    toolbarOnFocus
                    toolbar={{
                      options: [
                        "inline",
                        "list",
                        "link",
                        "blockType",
                        "fontSize",
                        "fontFamily"
                      ],
                      inline: {
                        options: [
                          "bold",
                          "italic",
                          "underline",
                          "strikethrough",
                          "monospace"
                        ],
                        bold: { className: "bordered-option-classname" },
                        italic: { className: "bordered-option-classname" },
                        underline: { className: "bordered-option-classname" },
                        strikethrough: {
                          className: "bordered-option-classname"
                        },
                        code: { className: "bordered-option-classname" }
                      },
                      blockType: {
                        className: "bordered-option-classname"
                      },
                      fontSize: {
                        className: "bordered-option-classname"
                      },
                      fontFamily: {
                        className: "bordered-option-classname"
                      }
                    }}
                    editorState={assignmentDescriptionEditor}
                  />
                </Grid>
                <Grid item xs={6}>
                  <FormControl className={classes.formControl}>
                    <InputLabel shrink htmlFor="assignment_rubric_id">
                      {t("edit.select_rubric")}
                    </InputLabel>
                    <Select
                      id="assignment_rubric_id"
                      value={assignmentRubricId}
                      onChange={event => setAssignmentRubricId(event.target.value)}
                      displayEmpty
                      name="assignment_rubric"
                      className={classes.selectEmpty}
                    >
                      {availableRubrics.map(rubric => {
                        return (
                          <MenuItem
                             value={rubric.id}
                             selected={rubric.id == assignmentRubricId}
                             key={rubric.id}>
                            {rubric.name} {rubric.id > 0 ? `(${rubric.version})` : null }
                          </MenuItem>
                        );
                      })}
                    </Select>
                  </FormControl>
                </Grid>
                <LocalizationProvider dateAdapter={AdapterLuxon}>
                  <Grid item xs={4}>
                    <DatePicker
                      autoOk={true}
                      format="MM/dd/yyyy"
                      margin="normal"
                      label={t("open_date")}
                      value={assignmentStartDate}
                      onChange={setAssignmentStartDate}
                      renderInput={props => (
                        <TextField id="assignment_start_date" {...props} />
                      )}
                    />
                    {null != messages.start_date ? (
                      <FormHelperText error={true}>
                        {messages.start_date}
                      </FormHelperText>
                    ) : null}
                  </Grid>
                  <Grid item xs={4}>
                    <DatePicker
                      autoOk={true}
                      format="MM/dd/yyyy"
                      margin="normal"
                      label={t("close_date")}
                      value={assignmentEndDate}
                      onChange={setAssignmentEndDate}
                      renderInput={props => (
                        <TextField id="assignment_end_date" {...props} />
                      )}
                    />
                    {null != messages.end_date ? (
                      <FormHelperText error={true}>
                        {messages.end_date}
                      </FormHelperText>
                    ) : null}
                  </Grid>
                </LocalizationProvider>
                <Grid item xs={4}>
                  <FormControlLabel
                    control={
                      <Switch
                        checked={assignmentActive}
                        onChange={event => setAssignmentActive(!assignmentActive)}
                      />
                    }
                    label={t("active")}
                  />
                </Grid>
                <Grid item xs={12}>
                  <Switch
                    checked={assignmentGroupOption}
                    id="group_option"
                    onChange={event => setAssignmentGroupOption(!assignmentGroupOption)}
                    disabled={null == assignmentProjects || 2 > assignmentProjects.length}
                  />
                  <InputLabel htmlFor="group_option">
                    {t("edit.group_option")}
                  </InputLabel>
                </Grid>
                {group_options}
              </Grid>
              {save_btn} {messages.status}
              <Typography>{saveStatus}</Typography>
            </React.Fragment>
          </TabPanel>
          <TabPanel value="results">
            <Grid container style={{ height: "100%" }}>
              <Grid item xs={5}>
                Nothing here yet
              </Grid>
            </Grid>
          </TabPanel>
        </TabContext>
      </Paper>
    </Suspense>
  );
}

AssignmentDataAdmin.propTypes = {};
