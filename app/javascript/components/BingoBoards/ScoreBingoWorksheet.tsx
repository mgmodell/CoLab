import React, { useState, useEffect } from "react";
import {  useNavigate, useParams } from "react-router-dom";
//Redux store stuff
import { useSelector, useDispatch } from 'react-redux';
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  acknowledgeMsg} from '../infrastructure/StatusActions';
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";

import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import { useTranslation } from 'react-i18next';
import Grid from "@material-ui/core/Grid";
import Paper from "@material-ui/core/Paper";
import {useTypedSelector} from '../infrastructure/AppReducers'
import axios from "axios";
import { TableRow, TextField } from "@material-ui/core";

export default function ScoreBingoWorksheet(props) {

  const category = 'bingo_game';
  const dispatch = useDispatch( );
  const endpoints = useTypedSelector((state)=>state.context.endpoints[category]);
  const endpointsLoaded = useTypedSelector(state=>state.context.status.endpointsLoaded );
  const [t, i18n] = useTranslation( category );
  const { worksheetIdParam } = useParams( );

  const [topic, setTopic] = useState( 'loading' );
  const [description, setDescription] = useState( 'loading' );
  const [worksheetAnswers, setWorksheetAnswers] = useState( [ [ ] ] );
  const [resultImgUrl, setResultImgUrl] = useState( null );

  const navigate = useNavigate( );

  const [courseName, setCourseName] = useState( 'loading' );

  useEffect(() =>{
    if( endpointsLoaded ){
      const url = `${endpoints.worksheetResultsUrl}/${worksheetIdParam}.json`;
      dispatch( startTask( ) );
      axios.get( url, { } )
        .then( response =>{
          const data = response.data;
          setTopic( data.bingo_game.topic );
          setDescription( data.bingo_game.description );
          setWorksheetAnswers( data.practice_answers );
          setResultImgUrl( data.bingo_game.result_url );
        })
        .catch( error =>{
          console.log( 'error', error );
        })
        .finally( () =>{
          dispatch( endTask ( ) );
        })
    }
  },[endpointsLoaded])


  const resultImage = null === resultImgUrl ?
    null :
    (
        <Grid item xs={12} sm={12}>
                <img src={resultImgUrl} />
        </Grid>
    );


  return (
    <Paper>
      
      <Grid container>
        <Grid item xs={12} sm={6} >
          <h2>{t('topic')}:</h2>
        </Grid>
        <Grid item xs={12} sm={6} >
          <h2>{topic}</h2>
        </Grid>
        <Grid item xs={12} sm={6}>
          <h2>{t('description')}:</h2>
        </Grid>
        <Grid item xs={12} sm={6}>
          <p dangerouslySetInnerHTML={{
            __html: description}
          }></p>
        </Grid>
        <Grid item xs={12} sm={12}>
        <table>
          <tbody>
          {worksheetAnswers.map( (answerRow, outerIndex )=>{
            return( 
              <tr key={outerIndex} >
                {answerRow.map( (cell, innerIndex ) =>{
                  return( <td key={`${outerIndex}-${innerIndex}`}>{null===cell?'-':cell}</td>);
                })}
              </tr>
            ) 
          } ) }
          </tbody>
        </table>
        </Grid>
        <Grid item xs={12} sm={6} >
          <label htmlFor='upload-photo'>
            <input
              style={{ display: 'none' }}
              id='upload-photo'
              name='upload-photo'
              type="file" />
          <Button
            variant='contained'
            component='span'>Upload Button</Button>
          </label>
        </Grid>
        {resultImage}
      </Grid>
    </Paper>
  );
}
ScoreBingoWorksheet.propTypes = {
}
