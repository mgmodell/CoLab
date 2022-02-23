import React, { useState } from "react";
import Grid from "@mui/material/Grid";
import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import Slider from "@mui/material/Slider";
//For debug purposes
import Input from "@mui/material/Input";

import makeStyles from "@mui/styles/makeStyles";

import PropTypes from "prop-types";

const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1
  },
  paper: {
    padding: theme.spacing(2),
    textAlign: "center",
    color: theme.palette.text.secondary
  }
}));

export default function LinkedSliders(props) {
  const classes = useStyles();

  const handleDebugChange = (index, id, e) => {
    console.log("debug");
    console.log(e);
    handleChange(index, id, null, e.target.value);
  };
  const handleChange = (index, id, e, newValue) => {
    const lContributions = props.contributions.reduce((arr, newEl) => {
      arr.push(Object.assign({}, newEl));
      return arr;
    }, []);

    if (newValue >= props.sum) {
      newValue = props.sum;
      lContributions.forEach(contribution => {
        if (contribution.userId != id) {
          contribution.value = 0;
        } else {
          contribution.value = newValue;
        }
      });
    } else {
      const oldVal = lContributions[index].value;
      const distOver = lContributions.length - 1;

      const diff = newValue - oldVal;
      const mod = diff % distOver;

      const lNewVal = newValue - mod;
      var split = (diff - mod) / distOver;

      //If one decreases, the rest split the gain
      for (var counter = 0; counter < lContributions.length; counter++) {
        const lContribution = lContributions[counter];
        if (lContribution.userId != id) {
          var cVal = lContribution.value - split;
          lContribution.value = cVal;
        } else {
          lContribution.value = lNewVal;
        }
      }
    }

    var remainder = lContributions.reduce((total, item) => {
      if (item.value < 0) {
        total += item.value;
        item.value = 0;
      }
      return total;
    }, 0);

    //Reallocate from those that have gone negative
    while (remainder != 0) {
      const toDec = lContributions.reduce((progress, element) => {
        if (id != element.id && 0 != element.value) {
          progress.push(element);
        }
        return progress;
      }, []);
      const modulo = remainder % toDec.length;
      //Apply the remainder to the largest element
      toDec.sort((a, b) => {
        b.value - a.value;
      });
      toDec[0].value += modulo;
      var reduceBy = Math.ceil((remainder - modulo) / toDec.length);
      //Apply the reductions and adjustment
      remainder = toDec.reduce((negVal, element) => {
        element.value += reduceBy;
        if (element.value < 0) {
          negVal += element.value;
          element.value = 0;
        }
        return negVal;
      }, 0);
    }

    props.updateContributions(lContributions);
  };

  return (
    <Paper className={classes.root}>
      <Typography>
        {"" == (props.title || "") ? "" : <b>{props.title}:&nbsp;</b>}
        {props.description}
      </Typography>
      {props.contributions.map((contribution, index) => {
        return (
          <Grid
            container
            key={"fs_" + props.id + "_c_" + contribution.userId}
            spacing={10}
          >
            <Grid item xs={2}>
              <Typography display="inline">{contribution.name}</Typography>
            </Grid>
            <Grid item xs={8}>
              <Slider
                value={contribution.value}
                id={"fs_" + props.id + "_c_" + contribution.userId}
                name={"slider_fs_" + props.id + "_c_" + contribution.userId}
                min={0}
                defaultValue={props.sum / props.contributions.length}
                max={props.sum}
                factor={props.id}
                key={contribution.userId}
                onChange={handleChange.bind(null, index, contribution.userId)}
                aria-label={contribution.name}
              />
              {props.debug || false ? (
                <input
                  value={contribution.value}
                  min={0}
                  max={props.sum}
                  type="number"
                  factor={props.id}
                  contributor={contribution.userId}
                  id={"debug_fs_" + props.id + "_c_" + contribution.userId}
                  onChange={handleDebugChange.bind(
                    null,
                    index,
                    contribution.userId
                  )}
                />
              ) : null}
            </Grid>
          </Grid>
        );
      })}
    </Paper>
  );
}

LinkedSliders.propTypes = {
  id: PropTypes.number.isRequired,
  title: PropTypes.string,
  description: PropTypes.string,
  sum: PropTypes.number.isRequired,
  updateContributions: PropTypes.func.isRequired,
  debug: PropTypes.bool,
  contributions: PropTypes.arrayOf(
    PropTypes.shape({
      userId: PropTypes.number.isRequired,
      name: PropTypes.string.isRequired,
      value: PropTypes.number.isRequired
    })
  ).isRequired
};
