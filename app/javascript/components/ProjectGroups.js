import React from "react";
import PropTypes from "prop-types";
import Fab from "@material-ui/core/Fab";
import Paper from "@material-ui/core/Paper";
import InputBase from "@material-ui/core/InputBase";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";
import Table from "@material-ui/core/Table";
import Radio from "@material-ui/core/Radio";
import TableHead from "@material-ui/core/TableHead";
import TableBody from "@material-ui/core/TableBody";
import TableCell from "@material-ui/core/TableCell";
import TableRow from "@material-ui/core/TableRow";
import TableSortLabel from "@material-ui/core/TableSortLabel";
import TextField from "@material-ui/core/TextField";

import DeleteIcon from "@material-ui/icons/Delete";
import SearchIcon from "@material-ui/icons/Search";
import CompareIcon from "@material-ui/icons/Compare";
import SortIcon from "@material-ui/icons/Sort";
import GroupAddIcon from "@material-ui/icons/GroupAdd";

import DiversityScore from "../components/DiversityScore";

import { SortDirection } from "react-virtualized";

class ProjectGroups extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dirty: false,
      working: true,
      message: "",
      filter_text: "",
      sortBy: "last_name",
      sortDirection: SortDirection.DESC,
      groups_raw: {},
      students_raw: {},
      groups: [],
      students: []
    };
    this.addGroup = this.addGroup.bind(this);
    this.removeGroup = this.removeGroup.bind(this);
    this.setGroup = this.setGroup.bind(this);
    this.setGroupName = this.setGroupName.bind(this);
    this.filter = this.filter.bind(this);
    this.sortEvent = this.sortEvent.bind(this);
    this.saveGroups = this.saveGroups.bind(this);
    this.recalcDiversity = this.recalcDiversity.bind(this);
    this.rescoreGroup = this.rescoreGroup.bind(this);
  }

  addGroup() {
    const { groups_raw } = this.state;
    const group_ids = Object.keys(groups_raw).map(Number);
    group_ids.push(0);
    const min_id = Math.min(...group_ids) - 1;

    groups_raw[min_id] = {
      name: "Team " + min_id,
      id: min_id,
      diversity: 0
    };
    this.setState({
      dirty: true,
      groups_raw: groups_raw,
      groups: Object.values(groups_raw)
    });
  }

  removeGroup(event, group_id) {
    const { groups_raw, students_raw, sortBy, sortDirection } = this.state;
    const students = Object.values(students_raw);

    console.log(groups_raw);
    delete groups_raw[group_id];

    students.forEach(item => {
      if (item.group_id == group_id) {
        item.group_id = null;
        students_raw[item.id].group_id = null;
      }
    });
    this.sortStudents(sortBy, sortDirection, students);
    this.setState({
      groups_raw: groups_raw,
      groups: Object.values(groups_raw),
      students_raw: students_raw,
      students: students
    });
  }

  sortEvent(event, key) {
    const { students, groups_raw, sortBy, sortDirection } = this.state;
    let direction = SortDirection.DESC;
    if (key == sortBy && direction == sortDirection) {
      direction = SortDirection.ASC;
    }
    this.sortStudents(key, direction, students);
    this.setState({
      students: students,
      sortDirection: direction,
      sortBy: key
    });
  }
  filter(event) {
    const { sortBy, sortDirection, students_raw } = this.state;
    const filter_text = event.target.value;
    const filtered = Object.values(students_raw).filter(student =>
      (student.first_name + " " + student.last_name)
        .toUpperCase()
        .includes(filter_text.toUpperCase())
    );
    this.sortStudents(sortBy, sortDirection, filtered);
    this.setState({
      students: filtered,
      filter_text: event.target.value
    });
  }

  sortStudents(key, direction, students) {
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
  }

  componentDidMount() {
    this.getGroups();
  }

  setGroupName(event, group_id) {
    const { sortBy, sortDirection } = this.state;
    const groups = this.state.groups_raw;
    groups[group_id]["name"] = event.target.value;
    //this.sortStudents(sortBy, sortDirection, students);
    this.setState({
      dirty: true,
      groups: Object.values(groups),
      groups_raw: groups
    });
  }

  setGroup(student_id, group_id) {
    const students = this.state.students_raw;
    students[student_id]["group_id"] = group_id;
    this.setState({
      dirty: true,
      students: Object.values(students),
      students_raw: students
    });
  }

  getGroups() {
    const url = this.props.groupsUrl + this.props.projectId + ".json";
    this.setState({
      working: true
    });
    fetch(url, {
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
          working: false,
          groups_raw: data.groups,
          students_raw: data.students,
          groups: Object.values(data.groups),
          students: Object.values(data.students)
        });
      });
  }

  rescoreGroup(event, group_id) {
    this.setState({
      working: true
    });
    const g_req = {
      group_id: group_id
    };
    fetch(this.props.diversityRescoreGroup + this.props.projectId + ".json", {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      },
      body: JSON.stringify({
        group_id: group_id
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          const fail_data = new Object();
          fail_data.notice = "The operation failed";
          fail_data.success = false;
          console.log("error");
          return fail_data;
        }
      })
      .then(data => {
        this.setState({
          working: false,
          groups_raw: data.groups,
          students_raw: data.students,
          groups: Object.values(data.groups),
          students: Object.values(data.students)
        });
      });
  }

  recalcDiversity() {
    this.setState({
      working: true
    });
    fetch(this.props.diversityRescoreGroups + this.props.projectId + ".json", {
      method: "POST",
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
          const fail_data = new Object();
          fail_data.notice = "The operation failed";
          fail_data.success = false;
          console.log("error");
          return fail_data;
        }
      })
      .then(data => {
        this.setState({
          working: false,
          groups_raw: data.groups,
          students_raw: data.students,
          groups: Object.values(data.groups),
          students: Object.values(data.students)
        });
      });
  }

  saveGroups() {
    this.setState({
      working: true,
      message: "Saving..."
    });
    fetch(this.props.groupsUrl + this.props.projectId + ".json", {
      method: "PATCH",
      credentials: "include",
      body: JSON.stringify({
        groups: this.state.groups_raw,
        students: this.state.students_raw
      }),
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
          const fail_data = new Object();
          fail_data.notice = "The operation failed";
          fail_data.success = false;
          console.log("error");
          return fail_data;
        }
      })
      .then(data => {
        this.setState({
          working: false,
          groups_raw: data.groups,
          students_raw: data.students,
          groups: Object.values(data.groups),
          students: Object.values(data.students),
          message: data.message == null ? "" : data.message
        });
      });
  }

  render() {
    const direction = {
      [SortDirection.ASC]: "asc",
      [SortDirection.DESC]: "desc"
    };
    return (
      <Paper>
        <Toolbar>
          <InputBase placeholder="Search Students" onChange={this.filter} />
          <SearchIcon />
          <Typography color="inherit">
            Showing{" "}
            {this.state.students.length +
              " of " +
              this.state.students_raw.length}
          </Typography>
          {this.state.dirty ? (
            <Fab variant="extended" onClick={this.saveGroups}>
              Save
            </Fab>
          ) : null}
          <Typography color="inherit">{this.state.message}</Typography>
          <Fab variant="extended" onClick={this.recalcDiversity}>
            Recalculate Diversity
          </Fab>
          <Fab variant="extended" onClick={() => this.addGroup()}>
            <GroupAddIcon />
            Add Group
          </Fab>
        </Toolbar>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>
                <TableSortLabel
                  active={"first_name" == this.state.sortBy}
                  direction={direction[this.state.sortDirection]}
                  onClick={() => this.sortEvent(event, "first_name")}
                >
                  Given Name
                </TableSortLabel>
              </TableCell>
              <TableCell>
                <TableSortLabel
                  active={"last_name" == this.state.sortBy}
                  direction={direction[this.state.sortDirection]}
                  onClick={() => this.sortEvent(event, "last_name")}
                >
                  Family Name
                </TableSortLabel>
              </TableCell>
              {this.state.groups.map(group => {
                return (
                  <TableCell align="center" key={group.id}>
                    <TextField
                      onChange={() => this.setGroupName(event, group.id)}
                      value={group.name}
                      id={"g_" + group.id}
                    />
                    {group.id < 0 ? (
                      <Fab
                        variant="extended"
                        size="small"
                        onClick={() => this.removeGroup(event, group.id)}
                      >
                        <DeleteIcon />
                      </Fab>
                    ) : null}
                    <DiversityScore
                      groupId={group.id}
                      token={this.props.token}
                      parentDirty={this.state.dirty}
                      documented={
                        this.state.groups_raw[group.id].diversity || 0
                      }
                      scoreReviewUrl={this.props.diversityCheckUrl}
                      rescoreGroup={this.rescoreGroup}
                      students={this.state.students_raw}
                      sortBy={this.state.sortBy}
                      sortDirection={this.state.sortDirection}
                      sortFunc={this.sortEvent}
                    />
                  </TableCell>
                );
              })}
              <TableCell align="center">
                <TableSortLabel
                  active={0 == this.state.sortBy}
                  direction={direction[this.state.sortDirection]}
                  onClick={() => this.sortEvent(event, 0)}
                >
                  No Group
                </TableSortLabel>
              </TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {this.state.students.map(student => {
              return (
                <TableRow key={"stuRow-" + student.id}>
                  <TableCell>{student.first_name}</TableCell>
                  <TableCell>{student.last_name}</TableCell>
                  {this.state.groups.map(group => {
                    return (
                      <TableCell
                        align="center"
                        key={student.id + "-" + group.id}
                      >
                        <Radio
                          onClick={() => this.setGroup(student.id, group.id)}
                          id={"user_group_" + student.id + "_" + group.id}
                          checked={group.id == student.group_id}
                        />
                      </TableCell>
                    );
                  })}
                  <TableCell>
                    <Radio
                      id={"stu-" + student.id}
                      onClick={() => this.setGroup(student.id, null)}
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
}

ProjectGroups.propTypes = {
  token: PropTypes.string.isRequired,
  projectId: PropTypes.number.isRequired,
  groupsUrl: PropTypes.string.isRequired,
  diversityCheckUrl: PropTypes.string.isRequired,
  diversityRescoreGroup: PropTypes.string.isRequired,
  diversityRescoreGroups: PropTypes.string.isRequired
};
export default ProjectGroups;
