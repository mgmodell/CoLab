import React from "react";
import PropTypes from "prop-types";
import Typography from "@material-ui/core/Typography";
import IconButton from "@material-ui/core/IconButton";
import TableSortLabel from "@material-ui/core/TableSortLabel";

import CompareIcon from "@material-ui/icons/Compare";
import SaveIcon from "@material-ui/icons/Save";
import SortIcon from "@material-ui/icons/Sort";

import { SortDirection } from "react-virtualized";

class DiversityScore extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      calculated: null
    };
    this.calcDiversity = this.calcDiversity.bind(this);
    this.save = this.save.bind(this);
  }

  save() {
    this.props.rescoreGroup(event, this.props.groupId);
    this.setState({
      calculated: null
    });
  }

  render() {
    const direction = {
      [SortDirection.ASC]: "asc",
      [SortDirection.DESC]: "desc"
    };
    const { calculated } = this.state;
    const {
      groupId,
      sortDirection,
      sortBy,
      documented,
      parentDirty,
      sortFunc
    } = this.props;
    return (
      <React.Fragment>
        <IconButton size="small" onClick={() => this.calcDiversity()}>
          {documented}
          <CompareIcon />
        </IconButton>
        {null != calculated && calculated != documented ? (
          <React.Fragment>
            /{" "}
            {parentDirty ? (
              calculated
            ) : (
              <IconButton size="small" onClick={() => this.save()}>
                {calculated}
                <SaveIcon />
              </IconButton>
            )}
          </React.Fragment>
        ) : calculated == documented ? (
          " / " + calculated
        ) : null}

        <TableSortLabel
          active={groupId == parseInt(sortBy)}
          direction={direction[sortBy]}
          onClick={() => sortFunc(event, groupId)}
        >
          <SortIcon />
        </TableSortLabel>
      </React.Fragment>
    );
  }
  calcDiversity() {
    const url = this.props.scoreReviewUrl;
    const gid = this.props.groupId;
    const student_list = Object.values(this.props.students).filter(function(
      student
    ) {
      return student.group_id == gid;
    });
    const emails = [];
    student_list.forEach((item, index) => {
      emails.push(item.email);
    });
    fetch(this.props.scoreReviewUrl + ".json", {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      },
      body: JSON.stringify({
        emails: emails.join()
      })
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
          calculated: data.diversity_score
        });
      });
  }
}

DiversityScore.propTypes = {
  groupId: PropTypes.number.isRequired,
  token: PropTypes.string.isRequired,
  documented: PropTypes.number.isRequired,
  scoreReviewUrl: PropTypes.string.isRequired,
  students: PropTypes.object.isRequired,
  rescoreGroup: PropTypes.func.isRequired,
  parentDirty: PropTypes.bool.isRequired,
  sortDirection: PropTypes.string.isRequired,
  sortFunc: PropTypes.func.isRequired
};
export default DiversityScore;
