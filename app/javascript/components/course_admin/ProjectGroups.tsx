import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Fab from "@mui/material/Fab";
import Paper from "@mui/material/Paper";
import InputBase from "@mui/material/InputBase";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import Table from "@mui/material/Table";
import Radio from "@mui/material/Radio";
import TableHead from "@mui/material/TableHead";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableRow from "@mui/material/TableRow";
import TableSortLabel from "@mui/material/TableSortLabel";
import TextField from "@mui/material/TextField";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useDispatch } from "react-redux";

import DeleteIcon from "@mui/icons-material/Delete";
import SearchIcon from "@mui/icons-material/Search";
import GroupAddIcon from "@mui/icons-material/GroupAdd";

const DiversityScore = React.lazy(() => import("../DiversityScore"));

import { SortDirection } from "react-virtualized";
import axios from "axios";

type Props = {
  projectId: number;
  groupsUrl: string;
  diversityCheckUrl: string;
  diversityRescoreGroup: string;
  diversityRescoreGroups: string;
};

export default function ProjectGroups(props : Props) {
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

  const sortEvent = (event, key) => {
    const studentsWS = [...students];

    let direction = SortDirection.DESC;
    if (key == sortBy && direction == sortDirection) {
      direction = SortDirection.ASC;
    }
    sortStudents(key, direction, studentsWS);

    setStudents(studentsWS);
    setSortDirection(direction);
    setSortBy(key);
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

  const sortStudents = (key, direction, students) => {
    const mod = direction == SortDirection.ASC ? -1 : 1;
    if ("first_name" == key || "last_name" == key) {
      students.sort((a, b) => {
        return mod * a[key].localeCompare(b[key]);
      });
    } else {
      const g_id = Number(key);
      students.sort((a, b) => {
        var resp = a.group_id - b.group_id;
        if (a.group_id == g_id) {
          resp = +1;
        }
        return mod * resp;
      });
    }
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
      }).finally(() => {
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
      }).finally(() => {  
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
      }).finally(() => {
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
      }).finally(() => {
        dispatch(endTask());
      });
  };

  const direction = {
    [SortDirection.ASC]: "asc",
    [SortDirection.DESC]: "desc"
  };

  return (
    <Paper>
      <Toolbar>
        <InputBase
          placeholder="Search Students"
          onChange={filter}
          value={filterText}
        />
        <SearchIcon />
        <Typography color="inherit">
          Showing {students.length + " of " + Object.values(studentsRaw).length}
        </Typography>
        {dirty ? (
          <Fab variant="extended" onClick={saveGroups}>
            Save
          </Fab>
        ) : null}
        <Typography color="inherit">{message}</Typography>
        <Fab variant="extended" onClick={recalcDiversity}>
          Recalculate Diversity
        </Fab>
        <Fab variant="extended" onClick={() => addGroup()}>
          <GroupAddIcon />
          Add Group
        </Fab>
      </Toolbar>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>
              <TableSortLabel
                active={"first_name" == sortBy}
                direction={direction[sortDirection]}
                onClick={() => sortEvent(event, "first_name")}
              >
                Given Name
              </TableSortLabel>
            </TableCell>
            <TableCell>
              <TableSortLabel
                active={"last_name" == sortBy}
                direction={direction[sortDirection]}
                onClick={() => sortEvent(event, "last_name")}
              >
                Family Name
              </TableSortLabel>
            </TableCell>
            {groups.map(group => {
              return (
                <TableCell align="center" key={group.id}>
                  <TextField
                    onChange={() => setGroupName(event, group.id)}
                    value={group.name}
                    id={"g_" + group.id}
                  />
                  {group.id < 0 ? (
                    <Fab
                      variant="extended"
                      size="small"
                      onClick={() => removeGroup(event, group.id)}
                    >
                      <DeleteIcon />
                    </Fab>
                  ) : null}
                  <DiversityScore
                    groupId={group.id}
                    parentDirty={dirty}
                    documented={groupsRaw[group.id].diversity || 0}
                    scoreReviewUrl={props.diversityCheckUrl}
                    rescoreGroup={rescoreGroup}
                    students={studentsRaw}
                    sortBy={sortBy}
                    sortDirection={sortDirection}
                    sortFunc={sortEvent}
                  />
                </TableCell>
              );
            })}
            <TableCell align="center">
              <TableSortLabel
                active={0 == sortBy}
                direction={direction[sortDirection]}
                onClick={() => sortEvent(event, 0)}
              >
                No Group
              </TableSortLabel>
            </TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {students.map(student => {
            return (
              <TableRow key={"stuRow-" + student.id}>
                <TableCell>{student.first_name}</TableCell>
                <TableCell>{student.last_name}</TableCell>
                {groups.map(group => {
                  return (
                    <TableCell align="center" key={student.id + "-" + group.id}>
                      <Radio
                        onClick={() => setGroup(student.id, group.id)}
                        id={"user_group_" + student.id + "_" + group.id}
                        checked={group.id == student.group_id}
                      />
                    </TableCell>
                  );
                })}
                <TableCell>
                  <Radio
                    id={"stu-" + student.id}
                    onClick={() => setGroup(student.id, null)}
                    checked={null == student.group_id}
                  />
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </Paper>
  );
}

