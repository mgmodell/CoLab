import React, {useState} from "react"
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/paper'
import Typography from '@material-ui/core/Typography';
import Slider from '@material-ui/core/Slider';
import { makeStyles } from '@material-ui/core/styles';

import PropTypes from "prop-types"

const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1,
  },
  paper: {
    padding: theme.spacing(2),
    textAlign: 'center',
    color: theme.palette.text.secondary,
  },
}));


export default function LinkedSliders(props){
  const classes = useStyles();

  const handleChange = ( id, e, newValue )=>{
    const lContributors = [...props.contributors ];
    lContributors[ id - 1 ].value = newValue;
    props.updateContributors( lContributors );
  }


  return (
    <Paper className={classes.root}>
      <Typography>
        {'' == (props.title || '' ) ? '' : (<b>{props.title}:&nbsp;</b>) }
        {props.description} 
      </Typography>
      {props.contributors.map( (contributor)=> {
        return(
          <Grid container key={'fs_' + props.id + '_c_' + contributor.id} spacing={10}>
            <Grid item xs={2}>
          <Typography display='inline'>
            {contributor.name}
          </Typography>
            </Grid>
            <Grid item xs={8}>
          <Slider value={contributor.value}
                  min={0}
                  defaultValue={contributor.value}
                  max={props.sum}
                  step={props.contributors.length}
                  key={contributor.id}
                  onChange={handleChange.bind( null, contributor.id )}
                  aria-label={contributor.name} />
            </Grid>
          </Grid>
        )
      })}

    </Paper>
  );
}

LinkedSliders.propTypes = {
  id: PropTypes.number.isRequired,
  title: PropTypes.string,
  description: PropTypes.string,
  sum: PropTypes.number.isRequired,
  updateContributors: PropTypes.func.isRequired,
  contributors: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      name: PropTypes.string.isRequired,
      value: PropTypes.number.isRequired
    })
  ).isRequired
};
