import React, { useState } from "react";

import axios from "axios";
import { Button } from "primereact/button";

type Props = {
  groupId: number;
  documented: number;
  scoreReviewUrl: string;
  students: any;
  rescoreGroup: Function;
  parentDirty: boolean;
};

export default function DiversityScore(props: Props) {
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
      <Button
        className="pi pi-calculator"
        onClick={() => calcDiversity()}
        size="small"
        >
          {props.documented}
        </Button>
      {null != calculated && calculated != props.documented ? (
        <React.Fragment>
          /{" "}
          {props.parentDirty ? (
            calculated
          ) : (
            <Button
              className="pi pi-save"
              onClick={() => save()}
              size="small"
              >
                {calculated}
            </Button>
          )}
        </React.Fragment>
      ) : calculated == props.documented ? (
        " / " + calculated
      ) : null}

    </React.Fragment>
  );
}
