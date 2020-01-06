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

  const handleChange = ( index, id, e, newValue )=>{
    const lContributors = props.contributors.reduce( (arr, newEl) =>{
      arr.push( Object.assign( {}, newEl ) );
      return arr;
    }, [ ] );

    const oldVal = lContributors[ index ].value;
    const distOver = lContributors.length - 1

    const diff = newValue - oldVal;
    const mod = diff % distOver;

    const lNewVal = newValue - mod;
    var split = ( diff - mod ) / distOver;


    //If one decreases, the rest split the gain
    for( var counter = 0; counter < lContributors.length; counter++ ){
      const lContributor = lContributors[ counter ];
      if( lContributor.id != id ) {
        var cVal = lContributor.value - split
        lContributor.value = cVal;
      }else{
        lContributor.value = lNewVal;
      }
    }

    const negVal = lContributors.reduce( (total, item )=>{
      if( item.value < 0 ){
        total+= item.value;
        item.value = 0;
      }
      return total;
    }, 0 );

    if( negVal != 0 ){
      const toDec = lContributors.reduce( (progress, element)=>{
          if( id != element.id && 0 != element.value ){
            progress.push( element );
          }
          return progress;
        }, [ ] );
      const reduceBy = negVal / toDec.length;
      //Apply the reductions and adjustment
      const remainder = toDec.reduce( (unalloc, element)=>{
        element.value += reduceBy;
        unalloc -= reduceBy;
        return unalloc;
      }, 0 );
    }
    props.updateContributors( lContributors );
  }


  return (
    <Paper className={classes.root}>
      <Typography>
        {'' == (props.title || '' ) ? '' : (<b>{props.title}:&nbsp;</b>) }
        {props.description} 
      </Typography>
      {props.contributors.map( (contributor, index)=> {
        return(
          <Grid container key={'fs_' + props.id + '_c_' + contributor.id} spacing={10}>
            <Grid item xs={2}>
          <Typography display='inline'>
            {contributor.name}
          </Typography>
            </Grid>
            <Grid item xs={8}>
          <Slider value={contributor.value}
                  id={'fs_'+ props.id + '_c_' + contributor.id}
                  min={0}
                  defaultValue={contributor.value}
                  max={props.sum}
                  //step={props.contributors.length-1}
                  key={contributor.id}
                  onChange={handleChange.bind(
                    null,
                    index,
                    contributor.id )}
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
