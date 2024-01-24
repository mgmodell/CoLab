import React, { useState, useEffect, Fragment } from "react";
//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  addMessage,
  Priorities,
  setDirty,
  setClean
} from "../infrastructure/StatusSlice";
import { useNavigate, useParams } from "react-router-dom";

import { DataTable } from "primereact/datatable";

//import i18n from './i18n';
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import RubricCriteriaToolbar from "./RubricCriteriaToolbar";
import { Column } from "primereact/column";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { Button } from "primereact/button";
import { Panel } from "primereact/panel";

export default function RubricDataAdmin(props) {
  const category = "rubric";
  const navigate = useNavigate();

  const endpoints = useTypedSelector(state => {
    return state.context.endpoints[category];
  });
  const { t } = useTranslation(`${category}s`);
  const endpointStatus = useTypedSelector(state => {
    return state.context.status.endpointsLoaded;
  });
  const userLoaded = useTypedSelector(state => {
    return null != state.profile.lastRetrieved;
  });

  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });

  const dispatch = useDispatch();
  const freshCriteria = {
    description: "New Criteria",
    weight: 1,
    l1_description: "The bare minimum to register a score."
  };

  const addCriteria = () => {
    const newList = [...rubricCriteria];
    const newCriteria = Object.assign(
      {
        id: -1 * (rubricCriteria.length + 1),
        sequence: 2 * (rubricCriteria.length + 1)
      },
      freshCriteria
    );
    newList.push(newCriteria);
    setRubricCriteria(newList);
  };

  const editableTextValueSetter = event => {
    let { rowData, newValue, field, originalEvent: oEvent } = event;

    rowData[field] = newValue;
    const row = rubricCriteria.find(criterium => {
      return criterium.id === rowData.id;
    });
    row[field] = newValue;

    setRubricCriteria(rubricCriteria);
  };

  const renumCriteria = criteriaArray => {
    const tmpCriteria = [...criteriaArray];
    tmpCriteria.sort((a, b) => {
      return a.sequence - b.sequence;
    });
    for (let index = 0; index < tmpCriteria.length; index++) {
      tmpCriteria[index].sequence = index * 2;
    }
    return tmpCriteria;
  };

  let { rubricIdParam } = useParams();
  const [rubricId, setRubricId] = useState(rubricIdParam);
  const [rubricName, setRubricName] = useState("");
  const [rubricDescription, setRubricDescription] = useState("");
  const [rubricPublished, setRubricPublished] = useState(false);
  const [rubricActive, setRubricActive] = useState(false);
  const [rubricVersion, setRubricVersion] = useState(1);
  const [rubricCreator, setRubricCreator] = useState("");
  const [rubricSchoolId, setRubricSchoolId] = useState(0);

  const [rubricCriteria, setRubricCriteria] = useState([
    Object.assign(
      {
        id: -1,
        sequence: 1
      },
      freshCriteria
    )
  ]);

  const [messages, setMessages] = useState({});

  const timezones = useTypedSelector(state => {
    return state.context.lookups["timezones"];
  });

  const getRubric = () => {
    dispatch(startTask());
    var url = endpoints.baseUrl + "/";
    if (null == rubricId) {
      url = url + "new.json";
    } else {
      url = url + rubricId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const rubric = response.data.rubric;

        setRubricName(rubric.name || "");
        setRubricDescription(rubric.description || "");
        setRubricPublished(rubric.published || false);
        setRubricActive(rubric.active || false);
        setRubricVersion(rubric.version || 1);
        setRubricCreator(rubric.creator);
        setRubricSchoolId(rubric.school_id);

        rubric.criteria = renumCriteria(rubric.criteria);
        setRubricCriteria(rubric.criteria || []);

        dispatch(setClean(category));
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
        dispatch(setClean(category));
      });
  };
  const publishOrActivateRubric = () => {
    const action = rubricPublished ? "activate" : "publish";
    const url = `${endpoints["baseUrl"]}/${action}/${rubricId}.json`;
    dispatch(startTask(action));

    axios
      .get(url)
      .then(resp => {
        const data = resp["data"];
        const messages = data["messages"];

        if (messages != null && Object.keys(messages).length < 2) {
          const rubric = data.rubric;
          setRubricId(rubric.id);
          setRubricName(rubric.name);
          setRubricDescription(rubric.description);
          setRubricVersion(rubric.version);
          setRubricPublished(rubric.published);
          setRubricActive(rubric.active);
          setRubricCreator(rubric.creator);

          rubric.criteria = renumCriteria(rubric.criteria);
          setRubricCriteria(rubric.criteria || []);

          dispatch(setClean(category));
          dispatch(addMessage(messages.main, new Date(), Priorities.INFO));
          //setMessages(data.messages);
          dispatch(endTask("saving"));
        } else {
          dispatch(addMessage(messages.main, new Date(), Priorities.ERROR));
          setMessages(messages);
          dispatch(endTask(action));
        }
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  const saveRubric = () => {
    const method = null == rubricId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints["baseUrl"] +
      "/" +
      (null == rubricId ? props.rubricId : rubricId) +
      ".json";

    const saveableCriteria = [...rubricCriteria].map((value, index, array) => {
      const tmpCriteria = Object.assign({}, value);
      tmpCriteria.id = value.id < 1 ? null : value.id;
      return tmpCriteria;
    });
    axios({
      method: method,
      url: url,
      data: {
        rubric: {
          name: rubricName,
          description: rubricDescription,
          criteria_attributes: renumCriteria(saveableCriteria)
        }
      }
    })
      .then(resp => {
        const data = resp["data"];
        const messages = data["messages"];

        if (messages != null && Object.keys(messages).length < 2) {
          const rubric = data.rubric;
          if (rubric.id != rubricId) {
            dispatch(endTask("saving"));
            setMessages({ main: "A new version was created" });
            navigate(`../rubrics/${String(rubric.id)}`);
          } else {
            setRubricId(rubric.id);
            setRubricName(rubric.name);
            setRubricDescription(rubric.description);
            setRubricVersion(rubric.version);
            setRubricPublished(rubric.published);
            setRubricActive(rubric.active);
            setRubricCreator(rubric.creator);

            rubric.criteria = renumCriteria(rubric.criteria);
            setRubricCriteria(rubric.criteria || []);

            dispatch(setClean(category));
            dispatch(addMessage(messages.main, new Date(), Priorities.INFO));
          }
          navigate(`../${rubricId}`, { replace: true });
        } else {
          dispatch(addMessage(messages.main, new Date(), Priorities.ERROR));
          setMessages(messages);
        }
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask("saving"));
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getRubric();
    }
  }, [endpointStatus]);

  useEffect(() => {
    dispatch(setDirty(category));
  }, [rubricName, rubricDescription, rubricCriteria]);

  const saveButton = dirty ? (
    <Button aria-label="save-rubric" onClick={saveRubric} disabled={!dirty}>
      {parseInt(rubricId) > 0 ? "Save" : "Create"} Rubric
    </Button>
  ) : null;

  const publishOrActivateButton =
    parseInt(rubricId) > 0 ? (
      <Button
        aria-label="activate-or-publish-rubric"
        onClick={publishOrActivateRubric}
      >
        {t(
          `${rubricPublished
            ? rubricActive
              ? "Deactivate"
              : "Activate"
            : "Publish"
          } Rubric`
        )}
      </Button>
    ) : null;

  const cellEditor = options => {
    switch (options.field) {
      case "weight":
        return (
          <InputText
            type={"number"}
            id={options.field}
            value={options.value || 0}
            onChange={event => {
              options.editorCallback(event.target.value);
            }}
          />
        );
        break;
      case "description":
      case "l1_description":
      case "l2_description":
      case "l3_description":
      case "l4_description":
      case "l5_description":
        return (
          <InputTextarea
            value={options.value || ""}
            id={options.field}
            onChange={event => {
              options.editorCallback(event.target.value);
            }}
          />
        );
        break;
      default:
        return options.value;
    }
  };

  const detailsComponent = endpointStatus ? (
    <Panel>
      <span className="p-float-label">
        <InputText
          itemID="rubric-name"
          value={rubricName}
          onChange={event => setRubricName(event.target.value)}
        />
        <label htmlFor="rubric-name">{t("name")}</label>
      </span>


      &nbsp;
      <br />
      <span className="p-float-label">
        <InputTextarea
          itemID="rubric-description"
          placeholder="Enter a description of the rubric"
          rows={2}
          autoResize={true}
          value={rubricDescription}
          onChange={event => setRubricDescription(event.target.value)}
        />
        <label htmlFor="rubric-description">{t("description")}</label>
      </span>

      <p>Version {rubricVersion}</p>
      <p>Published {rubricPublished ? "Yes" : "No"}</p>
      <p>Active {rubricActive ? "Yes" : "No"}</p>
      <br />
      <div style={{ display: "flex", height: "100%" }}>
        <div style={{ flexGrow: 1 }}>
          <DataTable
            value={rubricCriteria}
            resizableColumns
            tableStyle={{
              minWidth: "50rem"
            }}
            header={
              <RubricCriteriaToolbar
                itemType={"activity"}
                newItemFunc={addCriteria}
              />
            }
            sortField="sequence"
            editMode={"cell"}
            paginatorTemplate="CurrentPageReport"
            currentPageReportTemplate="{totalRecords} Criteria"
            dataKey="id"
          >
            <Column
              header={t("criteria.sequence")}
              field="sequence"
              key="sequence"
            />
            <Column
              header={t("criteria.description")}
              field="description"
              key="description"
              editor={options => cellEditor(options)}
              onCellEditComplete={editableTextValueSetter}
            />
            <Column
              header={t("criteria.weight")}
              field="weight"
              key="weight"
              editor={options => cellEditor(options)}
              onCellEditComplete={editableTextValueSetter}
            />
            <Column
              header={t("criteria.l1_description")}
              field="l1_description"
              key="l1_description"
              editor={options => cellEditor(options)}
              onCellEditComplete={editableTextValueSetter}
            />
            <Column
              header={t("criteria.l2_description")}
              field="l2_description"
              key="l2_description"
              editor={options => cellEditor(options)}
              onCellEditComplete={editableTextValueSetter}
            />
            <Column
              header={t("criteria.l3_description")}
              field="l3_description"
              key="l3_description"
              editor={options => cellEditor(options)}
              onCellEditComplete={editableTextValueSetter}
            />
            <Column
              header={t("criteria.l4_description")}
              field="l4_description"
              key="l4_description"
              editor={options => cellEditor(options)}
              onCellEditComplete={editableTextValueSetter}
            />
            <Column
              header={t("criteria.l5_description")}
              field="l5_description"
              key="l5_description"
              editor={options => cellEditor(options)}
              onCellEditComplete={editableTextValueSetter}
            />
            <Column
              header={t("criteria.actions")}
              field="id"
              key="id"
              body={rowData => {
                return (
                  <Fragment>
                    <Button
                      tooltip={t("criteria.up")}
                      tooltipOptions={{
                        style: { width: "10rem" }
                      }}
                      icon="pi pi-arrow-up"
                      aria-label={t("criteria.up")}
                      id="up_criteria"
                      onClick={event => {
                        const tmpCriteria = [...rubricCriteria];
                        const criterium = tmpCriteria.find(value => {
                          return rowData.id == value.id;
                        });
                        criterium.sequence -= 3;
                        setRubricCriteria(renumCriteria(tmpCriteria));
                      }}
                    />
                    <Button
                      tooltip={t("criteria.down")}
                      icon="pi pi-arrow-down"
                      tooltipOptions={{
                        style: { width: "10rem" }
                      }}
                      aria-label={t("criteria.down")}
                      id="down_criteria"
                      onClick={event => {
                        const tmpCriteria = [...rubricCriteria];
                        const criterium = tmpCriteria.find(value => {
                          return rowData.id == value.id;
                        });
                        criterium.sequence += 3;
                        setRubricCriteria(renumCriteria(tmpCriteria));
                      }}
                    />
                    <Button
                      tooltip={t("criteria.copy")}
                      icon="pi pi-copy"
                      id="copy_criteria"
                      aria-label={t("criteria.copy")}
                      tooltipOptions={{
                        style: { width: "10rem" }
                      }}
                      onClick={event => {
                        const tmpCriteria = [...rubricCriteria];
                        const criterium = Object.assign(
                          {},
                          tmpCriteria.find(value => {
                            return rowData.id == value.id;
                          })
                        );
                        criterium.id = 0 - (2 * tmpCriteria.length + 1);
                        criterium.description += " (copy)";
                        criterium.sequence =
                          tmpCriteria.reduce((accumulator, current) => {
                            return accumulator > current.sequence
                              ? accumulator
                              : current.sequence;
                          }, 0) + 1;
                        tmpCriteria.push(criterium);

                        setRubricCriteria(renumCriteria(tmpCriteria));
                      }}
                    />
                    <Button
                      tooltip={t("criteria.delete")}
                      icon="pi pi-trash"
                      id="delete_criteria"
                      tooltipOptions={{
                        style: { width: "10rem" }
                      }}
                      aria-label={t("criteria.delete")}
                      onClick={event => {
                        const tmpCriteria = [...rubricCriteria];

                        setRubricCriteria(
                          renumCriteria(
                            tmpCriteria.filter(value => {
                              return rowData.id != value.id;
                            })
                          )
                        );
                      }}
                    />
                  </Fragment>
                );
              }}
            />
          </DataTable>
        </div>
      </div>
      {saveButton}
      {publishOrActivateButton}
    </Panel>
  ) : null;

  return detailsComponent;
}
