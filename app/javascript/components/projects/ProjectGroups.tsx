import React, { useState, useEffect, useMemo } from "react";
import axios from "axios";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import { IUser } from '../infrastructure/ProfileSlice';
import { useDispatch } from "react-redux";

import DiversityScore from "../DiversityScore";

import { SortDirection } from "react-virtualized";

import { RadioButton } from "primereact/radiobutton";
import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { Panel } from "primereact/panel";
import { Toolbar } from "primereact/toolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";

type Props = {
  projectId: number;
  groupsUrl: string;
  suggestGroupsUrl: string;
  diversityCheckUrl: string;
  diversityRescoreGroup: string;
  diversityRescoreGroups: string;
};

export default function ProjectGroups(props: Props) {
  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [message, setMessage] = useState("");
  const [filterText, setFilterText] = useState("");
  const [targetGroupCount, setTargetGroupCount] = useState("2");
  const [sortBy, setSortBy] = useState("last_name");
  const [sortDirection, setSortDirection] = useState(SortDirection.DESC);
  const [groupsRaw, setGroupsRaw] = useState({});
  const [studentsRaw, setStudentsRaw] = useState<Record<number, IUser>>({});
  const [suggestedGroupsRaw, setSuggestedGroupsRaw] = useState(null);
  const [suggestedStudentsRaw, setSuggestedStudentsRaw] = useState(null);
  const [suggestedGroups, setSuggestedGroups] = useState([]);
  const [suggestionSummary, setSuggestionSummary] = useState(null);

  const dispatch = useDispatch();

  // Derived state: groups array directly from dict
  const groups = Object.values(groupsRaw);

  // Derived state: students array computed with filtering & sorting
  const students = useMemo(() => {
    let list = Object.values(studentsRaw);

    if (filterText) {
      list = list.filter(student =>
        (student.first_name + " " + student.last_name)
          .toUpperCase()
          .includes(filterText.toUpperCase())
      );
    }

    const directionMultiplier = sortDirection === SortDirection.ASC ? 1 : -1;
    return [...list].sort((studentOne, studentTwo) => {
      const valueOne = studentOne[sortBy] || "";
      const valueTwo = studentTwo[sortBy] || "";
      if (valueOne < valueTwo) return -1 * directionMultiplier;
      if (valueOne > valueTwo) return 1 * directionMultiplier;
      return 0;
    });
  }, [studentsRaw, filterText, sortBy, sortDirection]);

  useEffect(() => {
    getGroups();
  }, []);

  const setGroup = (student_id: number, group_id: number) => {
    setDirty(true);
    setStudentsRaw(prev => ({
      ...prev,
      [student_id]: {
        ...prev[student_id],
        group_id: group_id
      }
    }));
  };

  const setGroupName = (event: React.ChangeEvent<HTMLInputElement>, group_id: number) => {
    const newName = event.target.value;
    setDirty(true);
    setGroupsRaw(prev => ({
      ...prev,
      [group_id]: {
        ...prev[group_id],
        name: newName
      }
    }));
  };

  const addGroup = () => {
    setGroupsRaw(prev => {
      const group_ids = Object.keys(prev).map(Number);
      group_ids.push(0);
      const min_id = Math.min(...group_ids) - 1;

      return {
        ...prev,
        [min_id]: {
          name: "Team " + min_id,
          id: min_id,
          diversity: 0
        }
      };
    });
    setDirty(true);
  };

  const removeGroup = (event, group_id: number) => {
    setDirty(true);
    setStudentsRaw(prev => {
      const updated = { ...prev };
      Object.values(updated).forEach(student => {
        if (student.group_id === group_id) {
          updated[student.id] = { ...student, group_id: null };
        }
      });
      return updated;
    });

    setGroupsRaw(prev => {
      const updated = { ...prev };
      delete updated[group_id];
      return updated;
    });
  };

  const getGroups = () => {
    const url = props.groupsUrl + props.projectId + ".json";
    setWorking(true);
    dispatch(startTask());
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setWorking(false);
        setSuggestedGroupsRaw(null);
        setSuggestedStudentsRaw(null);
        setSuggestedGroups([]);
        setSuggestionSummary(null);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const rescoreGroup = (event, group_id) => {
    setWorking(true);
    const url = props.diversityRescoreGroup + props.projectId + ".json";
    dispatch(startTask());
    axios
      .post(url, { group_id: group_id })
      .then(response => {
        const data = response.data;
        setWorking(false);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const recalcDiversity = () => {
    setWorking(true);
    const url = props.diversityRescoreGroups + props.projectId + ".json";
    dispatch(startTask());
    axios
      .post(url, {})
      .then(response => {
        const data = response.data;
        setWorking(false);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const saveGroups = (nextGroups = groupsRaw, nextStudents = studentsRaw) => {
    setWorking(true);
    setMessage("Saving...");

    const url = props.groupsUrl + props.projectId + ".json";
    dispatch(startTask());
    axios
      .patch(url, {
        groups: nextGroups,
        students: nextStudents
      })
      .then(response => {
        const data = response.data;
        setWorking(false);
        setDirty(false);
        setSuggestedGroupsRaw(null);
        setSuggestedStudentsRaw(null);
        setSuggestedGroups([]);
        setSuggestionSummary(null);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
        setMessage(data.message == null ? "" : data.message);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const suggestGroups = () => {
    if (working) return;

    setWorking(true);
    setMessage("Generating recommendations...");

    const url = props.suggestGroupsUrl + props.projectId + ".json";
    dispatch(startTask());
    axios
      .post(url, { target_group_count: targetGroupCount })
      .then(response => {
        const data = response.data;
        setWorking(false);
        setSuggestedGroupsRaw(data.groups);
        setSuggestedStudentsRaw(data.students);
        setSuggestedGroups(Object.values(data.groups));
        setSuggestionSummary(data.summary);
        setMessage("");
      })
      .catch(error => {
        console.log("error", error);
        setWorking(false);
        setMessage("Unable to generate recommendations");
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const rejectSuggestedGroups = () => {
    if (working) return;
    setSuggestedGroupsRaw(null);
    setSuggestedStudentsRaw(null);
    setSuggestedGroups([]);
    setSuggestionSummary(null);
    setMessage("");
  };

  const acceptSuggestedGroups = () => {
    if (working || null == suggestedGroupsRaw || null == suggestedStudentsRaw) return;
    saveGroups(suggestedGroupsRaw, suggestedStudentsRaw);
  };

  const suggestedMembers = groupId => {
    if (null == suggestedStudentsRaw) return [];
    return Object.values(suggestedStudentsRaw).filter(student => student.group_id == groupId);
  };

  return (
    <Panel>
      {0 < suggestedGroups.length ? (
        <Panel header="Recommended Groups" className="mb-3">
          {0 < groups.length ? (
            <p id="recommended-groups-warning">
              Accepting these suggested groups will remove and replace the existing project groups.
            </p>
          ) : null}
          <dl id="recommended-groups-summary">
            <dt>Diversity score std. dev.</dt>
            <dd>{suggestionSummary?.diversity_score_standard_deviation ?? 0}</dd>
            <dt>Average diversity score</dt>
            <dd>{suggestionSummary?.average_diversity_score ?? 0}</dd>
            <dt>Average faultline strength</dt>
            <dd>{suggestionSummary?.average_faultline_strength ?? 0}</dd>
            <dt>Max faultline strength</dt>
            <dd>{suggestionSummary?.max_faultline_strength ?? 0}</dd>
          </dl>
          {suggestedGroups.map(group => (
            <Panel
              key={`suggested-${group.id}`}
              id={`recommended-group-${group.id}`}
              header={group.name}
              className="mb-2 recommended-group-card"
            >
              <div>Members: {group.member_count}</div>
              <div>Diversity score: {group.diversity}</div>
              <div>Faultline strength: {group.faultline}</div>
              <ul>
                {suggestedMembers(group.id).map(student => (
                  <li key={`suggested-member-${group.id}-${student.id}`}>
                    {student.first_name} {student.last_name}
                  </li>
                ))}
              </ul>
            </Panel>
          ))}
          <div className="flex gap-2">
            <Button onClick={acceptSuggestedGroups} icon="pi pi-check" disabled={working}>
              Accept Suggested Groups
            </Button>
            <Button
              onClick={rejectSuggestedGroups}
              icon="pi pi-times"
              severity="secondary"
              disabled={working}
            >
              Reject Suggested Groups
            </Button>
          </div>
        </Panel>
      ) : null}
      <DataTable
        value={students}
        resizableColumns
        reorderableColumns
        tableStyle={{ width: "100%" }}
        dataKey="id"
        scrollable
        className="p-datatable-striped p-datatable-gridlines"
        header={
          <Toolbar
            end={
              <>
                <span className="p-input-icon-left">
                  <i className="pi pi-search" />
                  <InputText
                    placeholder="Search Students"
                    onChange={e => setFilterText(e.target.value)}
                    value={filterText}
                  />
                </span>
                <span>
                  Showing {students.length + " of " + Object.values(studentsRaw).length}
                </span>
                {dirty ? (
                  <Button onClick={() => saveGroups()} icon="pi pi-save">
                    Save
                  </Button>
                ) : null}
                <span>{message}</span>
                <span className="p-input-icon-left">
                  <i className="pi pi-users" />
                  <InputText
                    id="target_group_count"
                    aria-label="Target Group Count"
                    placeholder="Target Group Count"
                    onChange={event => setTargetGroupCount(event.target.value)}
                    value={targetGroupCount}
                    disabled={working}
                  />
                </span>
                <Button onClick={suggestGroups} icon="pi pi-sparkles" disabled={working}>
                  Recommend Groups
                </Button>
                <Button onClick={recalcDiversity} icon="pi pi-calculator">
                  Recalculate Diversity
                </Button>
                <Button onClick={addGroup} icon="pi pi-users">
                  Add Group
                </Button>
              </>
            }
          />
        }
      >
        <Column header="Given Name" field="first_name" sortable filter key="first_name" />
        <Column header="Family Name" field="last_name" sortable filter key="last_name" />
        {groups.map(group => (
          <Column
            header={() => (
              <>
                <InputText
                  value={group.name}
                  onChange={event => setGroupName(event, group.id)}
                  id={`g_${group.id}`}
                  itemID={`g_${group.id}`}
                />
                <span
                  onClick={() => {
                    setSortBy("group_id");
                    setSortDirection(prev =>
                      prev === SortDirection.ASC ? SortDirection.DESC : SortDirection.ASC
                    );
                  }}
                >
                  <i className="pi pi-sort-alt" />
                </span>
                {group.id < 0 ? (
                  <Button
                    onClick={event => removeGroup(event, group.id)}
                    icon="pi pi-trash"
                    rounded
                    size="small"
                  />
                ) : null}
                <DiversityScore
                  groupId={group.id}
                  parentDirty={dirty}
                  documented={groupsRaw[group.id]?.diversity || 0}
                  scoreReviewUrl={props.diversityCheckUrl}
                  rescoreGroup={rescoreGroup}
                  students={studentsRaw}
                />
                <div>Faultline: {groupsRaw[group.id]?.faultline || 0}</div>
              </>
            )}
            field={"id"}
            columnKey={group.id}
            key={group.id}
            body={rowData => (
              <RadioButton
                onChange={() => setGroup(rowData.id, group.id)}
                id={"user_group_" + rowData.id + "_" + group.id}
                itemID={"user_group_" + rowData.id + "_" + group.id}
                inputId={"user_group_" + rowData.id + "_" + group.id}
                checked={group.id === rowData.group_id}
              />
            )}
          />
        ))}
        <Column
          header="No Group"
          field="id"
          filter
          key="0"
          body={rowData => (
            <RadioButton
              id={"stu-" + rowData.id}
              onChange={() => setGroup(rowData.id, null)}
              checked={null == rowData.group_id}
            />
          )}
        />
      </DataTable>
    </Panel>
  );
}