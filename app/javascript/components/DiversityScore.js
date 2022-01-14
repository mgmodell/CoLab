import React from "react";
import PropTypes from "prop-types";
import Typography from "@mui/material/Typography";
import IconButton from "@mui/material/IconButton";
import TableSortLabel from "@mui/material/TableSortLabel";

import CompareIcon from "@mui/icons-material/Compare";
import SaveIcon from "@mui/icons-material/Save";
import SortIcon from "@mui/icons-material/Sort";

import { SortDirection } from "react-virtualized";
import axios from "axios";

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
    axios.post( this.props.scoreReviewUrl + '.json',
    {
        emails: emails.join()
    })
      .then(response => {
        const data = response.data;
        this.setState({
          calculated: data.diversity_score
        });
      })
      .catch( error =>{
          console.log("error", error);
          return [{ id: -1, name: "no data" }];

      });
  }
}

DiversityScore.propTypes = {
  groupId: PropTypes.number.isRequired,
  documented: PropTypes.number.isRequired,
  scoreReviewUrl: PropTypes.string.isRequired,
  students: PropTypes.object.isRequired,
  rescoreGroup: PropTypes.func.isRequired,
  parentDirty: PropTypes.bool.isRequired,
  sortDirection: PropTypes.string.isRequired,
  sortFunc: PropTypes.func.isRequired
};
export default DiversityScore;
