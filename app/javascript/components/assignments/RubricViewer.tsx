import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";

//Redux store stuff

import { useTypedSelector } from "../infrastructure/AppReducers";
import parse from 'html-react-parser';

import { useTranslation } from "react-i18next";
import { Grid, Typography } from "@mui/material";

interface ICriteria{
 id: number;
 description: string;
 weight: number;
 sequence: number;
 l1_description: string;
 l2_description: string | null;
 l3_description: string | null;
 l4_description: string | null;
 l5_description: string | null;
};

interface IRubricData {
 name: string;
 description: string;
 version: number;
 criteria: Array<ICriteria>
};

type Props = {
  rubric: IRubricData;
};

const CLEAN_RUBRIC: IRubricData = {
  name: '',
  description: '',
  version: 0,
  criteria: []
}

export default function RubricViewer(props: Props) {
  const endpointSet = "assignment";
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const { assignmentId } = useParams();

  const [t, i18n] = useTranslation( `${endpointSet}s` );

  const evaluation = props.rubric !== undefined ? (
    <React.Fragment>
            <Grid item xs={10}>
              <Typography variant="h6">{t('status.rubric_name' )}:</Typography>
            </Grid>
            <Grid item xs={20}>
              <Typography>
                {props.rubric.name}
              </Typography>
            </Grid>
            <Grid item xs={10}>
              <Typography variant="h6">{t('status.rubric_version' )}:</Typography>
            </Grid>
            <Grid item xs={20}>
              <Typography>
                {props.rubric.version}
              </Typography>
            </Grid>
            {props.rubric.criteria.sort( (a:ICriteria, b:ICriteria) => a.sequence - b.sequence ).map( (criterium) =>{
              const levels = [ 
                criterium.l1_description,
                criterium.l2_description,
                criterium.l3_description,
                criterium.l4_description,
                criterium.l5_description
              ];
              for( let index = levels.length - 1; index > 0; index-- ){
                if( levels[ index ] !== null && levels[index].length > 0 ){
                  index = -1;
                } else {
                  levels.pop( );
                }
              }
              const span = 60 / ( levels.length + 1 );
              const renderedLevels = [];
              let index = 0;
              levels.forEach( (levelText) => {
                index++;
                renderedLevels.push( 
                    <Grid item key={`${criterium.id}-${index}`} xs={span}>
                      {parse( levelText) }
                    </Grid>
                );
              })
              
              return(
                <React.Fragment key={criterium.id}>
                  <Grid item xs={70}><hr></hr></Grid>
                  <Grid item xs={10}>
                    { criterium.description}
                  </Grid>
                  <Grid item xs={span}>
                    {t('status.rubric_minimum')}
                  </Grid>
                  { renderedLevels }
                </React.Fragment>
              )
            })}

      <Grid item xs={70}><hr></hr></Grid>
    </React.Fragment>
  ) : null;

  return evaluation;
}

export { IRubricData, CLEAN_RUBRIC };