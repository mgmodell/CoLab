import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";

import TextField from "@mui/material/TextField";
import Grid from "@mui/material/Grid";
import FormControl from "@mui/material/FormControl";
import FormGroup from "@mui/material/FormGroup";
import MenuItem from "@mui/material/MenuItem";
import Select from "@mui/material/Select";
import Typography from "@mui/material/Typography";
import InputLabel from "@mui/material/InputLabel";
import FormControlLabel from "@mui/material/FormControlLabel";
import FormHelperText from "@mui/material/FormHelperText";
import Switch from "@mui/material/Switch";

import { Button } from "primereact/button";
import { Panel } from "primereact/panel";
import { TabView, TabPanel } from "primereact/tabview";

import Skeleton from "@mui/material/Skeleton";

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";

import { DateTime } from "luxon";
import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";

import { useTranslation } from "react-i18next";

//import makeStyles from "@mui/styles/makeStyles";

import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { Checkbox, FormLabel } from "@mui/material";
import { Editor } from "primereact/editor";
import EditorToolbar from "../infrastructure/EditorToolbar";

export default function AssignmentDataAdmin(props) {
  //const classes = useStyles();

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
  const navigate = useNavigate();

  const [dirty, setDirty] = useState(false);
  const [curTab, setCurTab] = useState(0);
  const [messages, setMessages] = useState({});
  const [assignmentProjects, setAssignmentProjects] = useState([
    { id: -1, name: "None Selected" }
  ]);
  const [availableRubrics, setAvailableRubrics] = useState([
    { id: -1, name: "None Selected", version: 0 }
  ]);
  const [saveStatus, setSaveStatus] = useState("");
  const [assignmentName, setAssignmentName] = useState("");
  const [
    assignmentDescriptionEditor,
    setAssignmentDescriptionEditor
  ] = useState("");
  const [assignmentId, setAssignmentId] = useState(
    "new" === assignmentIdParam ? null : assignmentIdParam
  );
  const [assignmentActive, setAssignmentActive] = useState(false);
  const [assignmentEndDate, setAssignmentEndDate] = useState(
    DateTime.local().plus({ month: 3 })
  );
  const [assignmentStartDate, setAssignmentStartDate] = useState(
    DateTime.local()
  );
  const [assignmentFileSub, setAssignmentFileSub] = useState(false);
  const [assignmentLinkSub, setAssignmentLinkSub] = useState(false);
  const [assignmentTextSub, setAssignmentTextSub] = useState(false);
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

  const updateSubmissionTypeSelection = (
    event: React.ChangeEvent<HTMLInputElement>,
    fieldName
  ) => {
    switch (fieldName) {
      case "text":
        setAssignmentTextSub(!assignmentTextSub);
        break;
      case "file":
        setAssignmentFileSub(!assignmentFileSub);
        break;
      case "link":
        setAssignmentLinkSub(!assignmentLinkSub);
        break;
      default:
        console.log(`No such submission type: ${fieldName}`);
    }
  };

  const saveAssignment = () => {
    const method = null === assignmentId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null === assignmentId ? courseIdParam : assignmentId) +
      ".json";

    // Save
    setSaveStatus(t("edit.status_saving"));
    axios({
      url: url,
      method: method,
      data: {
        assignment: {
          course_id: courseIdParam,
          name: assignmentName,
          description: assignmentDescriptionEditor,
          active: assignmentActive,
          start_date: assignmentStartDate,
          end_date: assignmentEndDate,
          rubric_id: assignmentRubricId > 0 ? assignmentRubricId : null,
          group_enabled: assignmentGroupOption,
          file_sub: assignmentFileSub,
          text_sub: assignmentTextSub,
          link_sub: assignmentLinkSub,
          project_id:
            assignmentGroupProjectId > 0 ? assignmentGroupProjectId : null
        }
      }
    })
      .then(response => {
        const data = response.data;
        setAssignmentData(data);
        //TODO: handle save errors
        setSaveStatus(data["notice"]);
        setDirty(false);
        setMessages(data["messages"]);
        navigate(`../${courseIdParam}/assignment/${assignmentId}`, { replace: true });

        //getAssignmentData();
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask("saving"));
      });
  };

  const setAssignmentData = data => {
    const projects = new Array({ id: -1, name: "None Selected" }).concat(
      data.projects
    );
    setAssignmentProjects(projects);

    const availableRubrics = new Array({
      id: -1,
      name: "None Selected",
      version: 0
    }).concat(data.rubrics);
    setAvailableRubrics(availableRubrics);

    //Set the bingo_game stuff
    const assignment = data.assignment;
    setAssignmentId(assignment.id);
    setAssignmentName(assignment.name || "");
    setAssignmentDescriptionEditor(assignment.description || "");
    setAssignmentActive(assignment.active || false);
    var receivedDate = DateTime.fromISO(assignment.start_date).setZone(
      assignment.course.timezone
    );
    setAssignmentStartDate(receivedDate);
    setAssignmentEndDate(
      DateTime.fromISO(assignment.end_date).setZone(assignment.course.timezone)
    );
    setAssignmentFileSub(assignment.file_sub);
    setAssignmentLinkSub(assignment.link_sub);
    setAssignmentTextSub(assignment.text_sub);
    //Group options
    setAssignmentGroupOption(assignment.group_enabled || false);
    setAssignmentGroupProjectId(assignment.project_id || -1);
    setAssignmentRubricId(assignment.rubric_id || -1);
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
        setAssignmentData(data);

        setDirty(false);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      });
  };

  const save_btn = dirty ? (
    <Suspense fallback={<Skeleton variant="text" />}>
      <Button
        color="primary"
        //className={classes["button"]}
        onClick={saveAssignment}
        id="save_assignment"
        value="save_assignment"
      >
        {null == assignmentId
          ? t("new.create_assignment_btn")
          : t("edit.update_assignment_btn")}
      </Button>
    </Suspense>
  ) : null;

  const group_options = assignmentGroupOption ? (
    <Suspense fallback={<Skeleton variant="text" />}>
      <React.Fragment>
        <Grid item xs={6}>
          <FormControl
          //className={classes.formControl}
          >
            <InputLabel shrink htmlFor="assignment_project_id">
              {t("edit.group_source")}
            </InputLabel>
            <Select
              id="assignment_project_id"
              value={assignmentGroupProjectId}
              onChange={event =>
                setAssignmentGroupProjectId(event.target.value)
              }
              displayEmpty
              name="assignment_project"
            //className={classes.selectEmpty}
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
      <Panel >

        <TabView
          activeIndex={curTab}
          onTabChange={event => setCurTab(event.index)}
        >
          <TabPanel header={t("edit.assignment_details_pnl")}>
            <React.Fragment>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <TextField
                    id="name"
                    label={t("name")}
                    //className={classes.textField}
                    value={assignmentName}
                    fullWidth
                    onChange={event => setAssignmentName(event.target.value)}
                    margin="normal"
                  />
                </Grid>
                <Grid item xs={12}>
                  <Editor
                    id="description"
                    aria-label={t("description")}
                    placeholder={t("description")}
                    value={assignmentDescriptionEditor}
                    headerTemplate={<EditorToolbar />}
                    onTextChange={event => {
                      setAssignmentDescriptionEditor(event.htmlValue);
                    }}
                  />
                </Grid>
                <Grid item xs={6}>
                  <FormControl
                    component="fieldset"
                    variant="standard"
                    error={messages["submission_types"]}
                  >
                    <FormLabel component="legend">
                      {t("edit.sub_type_select")}
                    </FormLabel>
                    <FormGroup>
                      <FormControlLabel
                        control={
                          <Checkbox
                            checked={assignmentTextSub}
                            onChange={event =>
                              updateSubmissionTypeSelection(event, "text")
                            }
                            id="sub_text"
                            name="sub_text"
                          />
                        }
                        label={t("edit.text_sub")}
                      />
                      <FormControlLabel
                        control={
                          <Checkbox
                            checked={assignmentLinkSub}
                            onChange={event =>
                              updateSubmissionTypeSelection(event, "link")
                            }
                            id="sub_link"
                            name="sub_link"
                          />
                        }
                        label={t("edit.link_sub")}
                      />
                      <FormControlLabel
                        control={
                          <Checkbox
                            checked={assignmentFileSub}
                            onChange={event =>
                              updateSubmissionTypeSelection(event, "file")
                            }
                            id="sub_file"
                            name="sub_file"
                          />
                        }
                        label={t("edit.file_sub")}
                      />
                    </FormGroup>
                  </FormControl>
                </Grid>
                <Grid item xs={6}>
                  <FormControl
                  //className={classes.formControl}
                  >
                    <InputLabel shrink htmlFor="assignment_rubric_id">
                      {t("edit.select_rubric")}
                    </InputLabel>
                    <Select
                      id="assignment_rubric_id"
                      value={assignmentRubricId}
                      onChange={event =>
                        setAssignmentRubricId(event.target.value)
                      }
                      displayEmpty
                      name="assignment_rubric"
                    //className={classes.selectEmpty}
                    >
                      {availableRubrics.map(rubric => {
                        return (
                          <MenuItem
                            value={rubric.id}
                            selected={rubric.id == assignmentRubricId}
                            key={rubric.id}
                          >
                            {rubric.name}{" "}
                            {rubric.id > 0 ? `(${rubric.version})` : null}
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
                      slot={{
                        TextField: TextField
                      }}
                      slotProps={{
                        textField: {
                          id: "assignment_start_date"
                        }
                      }}
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
                      slot={{
                        TextField: TextField
                      }}
                      slotProps={{
                        textField: {
                          id: "assignment_end_date"
                        }
                      }}
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
                        onChange={event =>
                          setAssignmentActive(!assignmentActive)
                        }
                      />
                    }
                    label={t("active")}
                  />
                </Grid>
                <Grid item xs={12}>
                  <Switch
                    checked={assignmentGroupOption}
                    id="group_option"
                    onChange={event =>
                      setAssignmentGroupOption(!assignmentGroupOption)
                    }
                    disabled={
                      null == assignmentProjects ||
                      2 > assignmentProjects.length
                    }
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
          <TabPanel header={t("edit.assignment_submissions_pnl")}>
            <Grid container style={{ height: "100%" }}>
              <Grid item xs={5}>
                Nothing here yet
              </Grid>
            </Grid>
          </TabPanel>
        </TabView>
      </Panel>
    </Suspense>
  );
}

AssignmentDataAdmin.propTypes = {};
