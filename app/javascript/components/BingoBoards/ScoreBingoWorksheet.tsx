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
import Button from "@mui/material/Button";
import PropTypes from "prop-types";

import Settings from "luxon/src/settings.js";

import AdapterLuxon from '@mui/lab/AdapterLuxon';
import { useTranslation } from 'react-i18next';
import Grid from "@mui/material/Grid";
import Paper from "@mui/material/Paper";
import {useTypedSelector} from '../infrastructure/AppReducers'
import axios, {post} from "axios";
import { TableRow, TextField } from "@mui/material";

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
  const [performance, setPerformance] = useState( 0 );
  const [resultImgUrl, setResultImgUrl] = useState( null );
  const [newImg, setNewImg] = useState( null );
  const [newImgExt, setNewImgExt] = useState( null );

  const imgFileDataId = 'result_photo';

  const navigate = useNavigate( );

  const [courseName, setCourseName] = useState( 'loading' );

  useEffect(() =>{
    if( endpointsLoaded ){
      getWorksheetData( );
    }
  },[endpointsLoaded])

  const getWorksheetData = ()=>{
      const url = `${endpoints.worksheetResultsUrl}/${worksheetIdParam}.json`;
      dispatch( startTask( ) );
      axios.get( url, { } )
        .then( response =>{
          console.log( response.data );
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

  const handleFileSelect = (evt)=>{
    const file = evt.target.files[0];

    if (file) {
        setNewImgExt( file.name.split(".").pop( ) );
        setNewImg( file );
    }
  }
  const submitScore = ()=>{
    const formData = new FormData( );
    if( newImg ){
      formData.append( 'result_img', newImg );
    }

    formData.append( 'performance', performance );
    formData.append( 'img_ext', newImgExt );

    const url = `${endpoints.worksheetScoreUrl}${worksheetIdParam}.json`;


    post( url, formData, {
      headers:{ 
        'content-type': 'multipart/form-data'
      }
    })
        .then( response =>{
          const data = response.data;
          setResultImgUrl( data.bingo_game.result_url );
        })
        .catch( error =>{
          console.log( 'error', error );
        })
        .finally( () =>{
          dispatch( endTask ( ) );
        })
  }


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
          <TextField id='score'
                    label={t('score')}
                    value={performance}
                    type='number'
                    onChange={event=>{setPerformance(event.target.value)}} />
        </Grid>
        <Grid item xs={12} sm={6} >
          <label htmlFor={imgFileDataId}>
            <input
              style={{ display: 'none' }}
              id={imgFileDataId}
              name={imgFileDataId}
              onChange={handleFileSelect}
              type="file" />
          <Button
            variant='contained'
            component='span'
            >{t('file_select')}</Button>
          </label>
        </Grid>
        <Grid item xs={12} sm={12} >
          <Button
            variant='contained'
            component='span'
            onClick={submitScore}
            >{t('submit_scores')}</Button>
        </Grid>
        {resultImage}
      </Grid>
    </Paper>
  );
}
ScoreBingoWorksheet.propTypes = {
}
