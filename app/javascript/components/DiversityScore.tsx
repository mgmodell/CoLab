import React, { useState } from "react";

import PropTypes from "prop-types";
import IconButton from "@mui/material/IconButton";
import TableSortLabel from "@mui/material/TableSortLabel";

import CompareIcon from "@mui/icons-material/Compare";
import SaveIcon from "@mui/icons-material/Save";
import SortIcon from "@mui/icons-material/Sort";

import { SortDirection } from "react-virtualized";
import axios from "axios";

export default function DiversityScore(props) {
  const direction = {
    [SortDirection.ASC]: "asc",
    [SortDirection.DESC]: "desc"
  };
  const [calculated, setCalculated] = useState(null);

  function save() {
    props.rescoreGroup(event, props.groupId);
    setCalculated(null);
  }

  function calcDiversity() {
    const url = props.scoreReviewUrl;
    const gid = props.groupId;
    const student_list = Object.values(props.students).filter(function(
      student
    ) {
      return student["group_id"] == gid;
    });
    const emails = [];
    student_list.forEach((item, index) => {
      emails.push(item["email"]);
    });
    axios
      .post(props.scoreReviewUrl + ".json", {
        emails: emails.join()
      })
      .then(response => {
        const data = response.data;
        setCalculated(data.diversity_score);
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      });
  }

  return (
    <React.Fragment>
      <IconButton size="small" onClick={() => calcDiversity()}>
        {props.documented}
        <CompareIcon />
      </IconButton>
      {null != calculated && calculated != props.documented ? (
        <React.Fragment>
          /{" "}
          {props.parentDirty ? (
            calculated
          ) : (
            <IconButton size="small" onClick={() => save()}>
              {calculated}
              <SaveIcon />
            </IconButton>
          )}
        </React.Fragment>
      ) : calculated == props.documented ? (
        " / " + calculated
      ) : null}

      <TableSortLabel
        active={props.groupId == parseInt(props.sortBy)}
        direction={direction[props.sortBy]}
        onClick={() => props.sortFunc(event, props.groupId)}
      >
        <SortIcon />
      </TableSortLabel>
    </React.Fragment>
  );
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
