import React, { useState, useEffect } from "react";
import axios from "axios";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useDispatch } from "react-redux";

const DiversityScore = React.lazy(() => import("../DiversityScore"));

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
  diversityCheckUrl: string;
  diversityRescoreGroup: string;
  diversityRescoreGroups: string;
};

export default function ProjectGroups(props: Props) {
  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [message, setMessage] = useState("");
  const [filterText, setFilterText] = useState("");
  const [sortBy, setSortBy] = useState("last_name");
  const [sortDirection, setSortDirection] = useState(SortDirection.DESC);
  const [groupsRaw, setGroupsRaw] = useState({});
  const [studentsRaw, setStudentsRaw] = useState({});
  const [groups, setGroups] = useState([]);
  const [students, setStudents] = useState([]);

  const dispatch = useDispatch();

  const addGroup = () => {
    const updatedGroups = Object.assign({}, groupsRaw);
    const group_ids = Object.keys(updatedGroups).map(Number);
    group_ids.push(0);
    const min_id = Math.min(...group_ids) - 1;

    updatedGroups[min_id] = {
      name: "Team " + min_id,
      id: min_id,
      diversity: 0
    };
    setDirty(true);
    setGroupsRaw(updatedGroups);
    setGroups(Object.values(updatedGroups));
  };

  const removeGroup = (event, group_id) => {
    const groupsUpdated = Object.assign({}, groupsRaw);
    const studentsUpdated = Object.assign({}, studentsRaw);

    const students = Object.values(studentsUpdated);

    delete groupsUpdated[group_id];

    students.forEach(item => {
      if (item.group_id == group_id) {
        item.group_id = null;
        studentsUpdated[item.id].group_id = null;
      }
    });
    sortStudents(sortBy, sortDirection, students);
    setGroupsRaw(groupsUpdated);
    setGroups(Object.values(groupsUpdated));
    setStudentsRaw(studentsUpdated);
    setStudents(students);
  };

  const filter = event => {
    const filter_text = event.target.value;
    const filtered = Object.values(studentsRaw).filter(student =>
      (student.first_name + " " + student.last_name)
        .toUpperCase()
        .includes(filter_text.toUpperCase())
    );
    sortStudents(sortBy, sortDirection, filtered);
    setStudents(filtered);
    setFilterText(event.target.value);
  };

  useEffect(() => {
    getGroups();
  }, []);

  const setGroupName = (event, group_id) => {
    const groupsWS = Object.assign({}, groupsRaw);

    groupsWS[group_id]["name"] = event.target.value;

    setDirty(true);
    setGroups(Object.values(groupsWS));
    setGroupsRaw(groupsWS);
  };

  const setGroup = (student_id, group_id) => {
    const studentsWS = Object.assign({}, studentsRaw);
    studentsWS[student_id]["group_id"] = group_id;

    setDirty(true);
    setStudents(Object.values(studentsWS));
    setStudentsRaw(studentsWS);
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
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
        setGroups(Object.values(data.groups));
        setStudents(Object.values(data.students));
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

    const g_req = {
      group_id: group_id
    };

    const url = props.diversityRescoreGroup + props.projectId + ".json";
    dispatch(startTask());
    axios
      .post(url, {
        group_id: group_id
      })
      .then(response => {
        const data = response.data;
        setWorking(false);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
        setGroups(Object.values(data.groups));
        setStudents(Object.values(data.students));
      })
      .catch(error => {
        const fail_data = new Object();
        fail_data.notice = "The operation failed";
        fail_data.success = false;
        console.log("error", error);
        return fail_data;
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
        setGroups(Object.values(data.groups));
        setStudents(Object.values(data.students));
      })
      .catch(error => {
        const fail_data = new Object();
        fail_data.notice = "The operation failed";
        fail_data.success = false;
        console.log("error", error);
        return fail_data;
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const saveGroups = () => {
    setWorking(true);
    setMessage("Saving...");

    const url = props.groupsUrl + props.projectId + ".json";
    dispatch(startTask());
    axios
      .patch(url, {
        groups: groupsRaw,
        students: studentsRaw
      })
      .then(response => {
        const data = response.data;
        setWorking(false);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
        setGroups(Object.values(data.groups));
        setStudents(Object.values(data.students));
        setMessage(data.message == null ? "" : data.message);
      })
      .catch(error => {
        const fail_data = new Object();
        fail_data.notice = "The operation failed";
        fail_data.success = false;
        console.log("error", error);
        return fail_data;
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const direction = {
    [SortDirection.ASC]: "asc",
    [SortDirection.DESC]: "desc"
  };

  return (
    <Panel>
      <DataTable
        value={students}
        resizableColumns
        reorderableColumns
        tableStyle={{
          width: "100%"
        }}
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
                    onChange={filter}
                    value={filterText}
                  />
                </span>
                <span>
                  Showing{" "}
                  {students.length + " of " + Object.values(studentsRaw).length}
                </span>
                {dirty ? (
                  <Button onClick={saveGroups} icon="pi pi-save">
                    Save
                  </Button>
                ) : null}
                <span>{message}</span>
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
        <Column
          header="Given Name"
          field="first_name"
          sortable
          filter
          key="first_name"
        />
        <Column
          header="Family Name"
          field="last_name"
          sortable
          filter
          key="last_name"
        />
        {groups.map(group => {
          return (
            <Column
              header={() => {
                return (
                  <>
                    <InputText
                      value={group.name}
                      onChange={event => setGroupName(event, group.id)}
                      id={`g_${group.id}`}
                      itemID={`g_${group.id}`}
                    />
                    <span
                      onClick={() => {
                        const wip_students = [...students];
                        wip_students.sort((a, b) => {
                          return group.id === a.group_id ? -1 : 1;
                        });
                        setStudents(wip_students);
                      }}
                    >
                      <i className="pi pi-sort-alt" />
                    </span>
                    {group.id < 0 ? (
                      <Button
                        onClick={() => removeGroup(event, group.id)}
                        icon="pi pi-trash"
                        rounded
                        size="small"
                      />
                    ) : null}
                    <DiversityScore
                      groupId={group.id}
                      parentDirty={dirty}
                      documented={groupsRaw[group.id].diversity || 0}
                      scoreReviewUrl={props.diversityCheckUrl}
                      rescoreGroup={rescoreGroup}
                      students={studentsRaw}
                    />
                  </>
                );
              }}
              field={"id"}
              columnKey={group.id}
              key={group.id}
              body={rowData => {
                return (
                  <RadioButton
                    onChange={event => setGroup(rowData.id, group.id)}
                    id={"user_group_" + rowData.id + "_" + group.id}
                    itemID={"user_group_" + rowData.id + "_" + group.id}
                    inputId={"user_group_" + rowData.id + "_" + group.id}
                    checked={group.id === rowData.group_id}
                  />
                );
              }}
            />
          );
        })}
        <Column
          header="No Group"
          field="id"
          filter
          key="0"
          body={rowData => {
            return (
              <RadioButton
                id={"stu-" + rowData.id}
                onChange={event => setGroup(rowData.id, null)}
                checked={null == rowData.group_id}
              />
            );
          }}
        />
      </DataTable>
    </Panel>
  );
}
