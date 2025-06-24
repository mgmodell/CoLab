import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import axios from "axios";


import { Button } from "primereact/button";
import { Panel } from "primereact/panel";
import { TabView, TabPanel } from "primereact/tabview";
import { Editor } from "primereact/editor";
import { Dropdown } from "primereact/dropdown";
import { Skeleton } from "primereact/skeleton";
import { InputText } from "primereact/inputtext";
import { Calendar } from "primereact/calendar";
import { InputSwitch } from "primereact/inputswitch";
import { Checkbox } from "primereact/checkbox";

import { useTranslation } from "react-i18next";

import EditorToolbar from "../toolbars/EditorToolbar";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask, addMessage, Priorities } from "../infrastructure/StatusSlice";
import { Col, Container, Row } from "react-grid-system";


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
  const now = new Date();
  const [assignmentStartDate, setAssignmentStartDate] = useState(
    now
  );
  const [assignmentEndDate, setAssignmentEndDate] = useState(
    () => {
      now.setMonth(now.getMonth() + 3);
      return now;
    }
  );

  const setMessages = msgs => {
    Object.keys(msgs).forEach(key => {
      if ("main" === key) {
        dispatch(addMessage(msgs[key], new Date(), Priorities.INFO));
      } else {
        dispatch(addMessage(msgs[key], new Date(), Priorities.WARNING));
      }
    });
  };

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
        console.log("data", data);
        setMessages( data.messages );
        setDirty(false);
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
    var receivedDate = new Date(Date.parse(assignment.start_date));
    setAssignmentStartDate(receivedDate);

    setAssignmentEndDate(
      new Date(Date.parse(assignment.end_date))
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
    <Suspense fallback={<Skeleton className="mb-2" />}>
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
    <Suspense fallback={<Skeleton className="mb-2" />}>
      <Col xs={6}>
        <span className="p-float-label w-full">
          <Dropdown
            id="assignment_project_id"
            value={assignmentGroupProjectId}
            onChange={event =>
              setAssignmentGroupProjectId(event.target.value)
            }
            name="assignment_project"
            options={assignmentProjects}
            optionLabel="name"
            optionValue="id"
          />
          <label htmlFor="assignment_project_id">
            {t("edit.group_source")}
          </label>
        </span>
      </Col>
    </Suspense>
  ) : null;
  return (
    <Suspense fallback={<Skeleton className="mb-2" />}>
      <Panel >

        <TabView
          activeIndex={curTab}
          onTabChange={event => setCurTab(event.index)}
        >
          <TabPanel header={t("edit.assignment_details_pnl")}>
            <Container>
              <Row>
                <Col xs={12}>
                  <span className="p-float-label">
                    <InputText
                      id='name'
                      value={assignmentName}
                      onChange={event => setAssignmentName(event.target.value)}
                      type="text"
                    />
                    <label htmlFor="name">{t("name")}</label>
                  </span>
                </Col>
                <Col xs={12}>
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
                </Col>
                <Col xs={12}>
                  <div className="flex flex-wrap justify-content-center gap-3">
                    <div className="flex align-items-center">
                      <Checkbox
                        checked={assignmentTextSub}
                        onChange={event =>
                          updateSubmissionTypeSelection(event.value, "text")
                        }
                        id="sub_text"
                        itemID="sub_text"
                        name="sub_text"
                      />
                      <label htmlFor="sub_text">{t("edit.text_sub")}</label>
                    </div>
                    <div className="flex align-items-center">
                      <Checkbox
                        checked={assignmentLinkSub}
                        onChange={event =>
                          updateSubmissionTypeSelection(event.value, "link")
                        }
                        id="sub_link"
                        itemID="sub_link"
                        name="sub_link"
                      />
                      <label htmlFor="sub_link">{t("edit.link_sub")}</label>
                    </div>
                    <div className="flex align-items-center">
                      <Checkbox
                        checked={assignmentFileSub}
                        onChange={event =>
                          updateSubmissionTypeSelection(event.value, "file")
                        }
                        id="sub_file"
                        itemID="sub_file"
                        name="sub_file"
                      />
                      <label htmlFor="sub_file">{t("edit.file_sub")}</label>
                    </div>
                  </div>
                </Col>
                <Col xs={6}>
                  <span className="p-float-label w-full">
                    <Dropdown
                      id="assignment_rubric_id"
                      value={assignmentRubricId}
                      onChange={event =>
                        setAssignmentRubricId(event.target.value)
                      }
                      name="assignment_rubric"
                      options={availableRubrics}
                      itemTemplate={(selected) => {
                        const output = null !== selected ? `${selected.name} v${selected.version}` : "None Selected";
                        return output;
                      }}
                      valueTemplate={(selected, props) => {
                        const output = null !== selected ? `${selected.name} v${selected.version}` : "None Selected";
                        return output;
                      }}
                      optionValue="id"
                      optionLabel="name"
                    />
                    <label htmlFor="assignment_rubric_id">
                      {t("edit.select_rubric")}
                    </label>
                  </span>

                </Col>
                <Col xs={4}>
                  <span className="p-float-label">
                    <Calendar
                      id="assignment_dates"
                      value={[assignmentStartDate, assignmentEndDate]}
                      onChange={event => {
                        const changeTo = event.value;
                        if (null !== changeTo && changeTo.length > 1) {
                          console.log( event );
                          console.log(changeTo[0], changeTo[1]);

                          setAssignmentStartDate(changeTo[0]);
                          setAssignmentEndDate(changeTo[1]);
                        }

                      }
                      }
                      selectionMode="range"
                      showIcon={true}
                      hideOnRangeSelection={true}
                      showOnFocus={false}
                      inputId="assignment_start_date"
                      name="assignment_start_date"
                    />
                    <label htmlFor="assignment_dates">
                      Assignment Dates
                    </label>
                  </span>
                </Col>
                <Col xs={4}>
                  <InputSwitch
                    checked={assignmentActive}
                    onChange={event => setAssignmentActive(!assignmentActive)}
                    name="active"
                    itemID="active"
                    id="active"
                  />
                  <label htmlFor="active">{t("active")}</label>
                </Col>
                <Col xs={12}>
                  <InputSwitch
                    checked={assignmentGroupOption}
                    id='group_option'
                    itemID="group_option"
                    onChange={event =>
                      setAssignmentGroupOption(!assignmentGroupOption)
                    }
                    disabled={
                      null == assignmentProjects ||
                      2 > assignmentProjects.length
                    }
                  />
                  <label htmlFor="group_option">
                    {t("edit.group_option")}
                  </label>

                </Col>
                {group_options}
                <Col xs={12}>
                  {save_btn}
                  <span>{saveStatus}</span>
                </Col>
              </Row>
            </Container>
          </TabPanel>
          <TabPanel header={t("edit.assignment_submissions_pnl")}>
            <Container>
              <Row>
                <Col xs={5}>
                  <span>Nothing here yet</span>
                </Col>
              </Row>
            </Container>
          </TabPanel>
        </TabView>
      </Panel>
    </Suspense>
  );
}