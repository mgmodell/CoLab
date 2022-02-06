import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";
import { FormControl, FormControlLabel, Grid, InputLabel, MenuItem, Select, Skeleton, Switch, Typography } from "@mui/material";

export default function ChartContainer(props) {

  const unit_codes ={
    group: 2,
    individual: 1
  };

  const code_units=[
    'individual', 'group'
  ]

  const category = "graphing";
  const endpoints = useTypedSelector(state=>state.context.endpoints[category]);
  const endpointStatus = useTypedSelector(state=>state.context.status.endpointsLoaded );
  const { t, i18n } = useTranslation( category );

  const [anonymize, setAnonymize] = useState( props.anonymize || false );
  const [forResearch, setForResearch] = useState( props.forResearch || false );
  const [projects, setProjects] = useState( props.projects || [] );
  const [selectedProject, setSelectedProject] = useState( -1 );
  const [subjects, setSubjects] = useState( [] );
  const [selectedSubject, setSelectedSubject] = useState( -1 );

  const getSubjectsForProject = (projectId )=>{
    if( 0 < selectedProject ){
      const url = endpoints.subjectsUrl + '.json';
      axios.post( url, {
        project_id: selectedProject,
        unit_of_analysis: unit_codes[ props.unitOfAnalysis ],
        for_research: forResearch,
        anonymous: anonymize
      })
        .then( (resp) =>{
          setSubjects( resp.data );

        })
        .catch( (error) =>{
          console.log( 'subject retrieval error', error );
        })
    }
  }

  const getProjects = ()=>{
    const url = endpoints.projectsUrl + '.json';
    axios.post( url, {
      for_research: forResearch,
      anonymous: anonymize
    })
      .then( (resp) =>{
        setProjects( resp.data );

      })
      .catch( (error) =>{
        console.log( 'project retrieval error', error );
      })
  }

  useEffect( () =>{
    if( endpointStatus ){
      if( null == props.projects){
        getProjects( );
      } else {
        if( 1 === props.projects.length){
          setSelectedProject( props.projects[ 0 ].id );
          getSubjectsForProject( props.projects[ 0 ].id );
        }
      }
    }
  }, [endpointStatus])

  useEffect( () =>{
    if( endpointStatus ){
      getSubjectsForProject( selectedProject );
    }

  }, [selectedProject])

  // If there's only one project
  useEffect( ()=>{
    if( 1 == projects.length ){
      setSelectedProject( projects[ 0 ].id );
    }
  }, [projects])


  const subjectSelect = ()=>{
          if( null == selectedProject ){
            return(
              <React.Fragment>
                Please select a project.
              </React.Fragment>
            )
          } else if( 1 > subjects.length ){
            return(
              <React.Fragment>
                No groups for this project.
              </React.Fragment>
            )
          } else {
            const unit_code = unit_codes[ props.unitOfAnalysis ];
            return(
              <FormControl variant='standard' >
                <InputLabel id={`${props.unitOfAnalysis}_list_label`}>{t(`${props.unitOfAnalysis}_list`)}</InputLabel>
                <Select
                  id={`${unit_code}`}
                  labelId={`${props.unitOfAnalysis}_label`}
                  value={selectedSubject}
                  onChange={(evt)=>{setSelectedSubject( evt.target.value )}}
                  >
                  <MenuItem value={-1}>{t('none')}</MenuItem>
                  { subjects.map( (subject) =>{
                    return(
                      <MenuItem key={`${props.unitOfAnalysis}-${subject.id}`} value={subject.id}>{subject.name}</MenuItem>
                    );
                  })}
                  </Select>
              </FormControl>
                
          ) } 
  }

  const projectSelect = ()=>{
          if( null == projects ){
            return (<Skeleton variant="text" />)
          }
          else if( 1 < projects.length ){
            return(
              <FormControl variant='standard' >
                <InputLabel id='project_list_label'>{t('projects_list')}</InputLabel>
                <Select
                  id='project_list'
                  labelId='project_list_label'
                  value={selectedProject}
                  onChange={(evt)=>{setSelectedProject( evt.target.value )}}
                  >
                  <MenuItem value={-1}>{t('none')}</MenuItem>
                  { projects.map( (project) =>{
                    return(
                      <MenuItem key={`project-${project.id}`} value={project.id}>{project.name}</MenuItem>
                    );
                  })}
                  </Select>
              </FormControl>
                
          )
          } else {
            return(
              <React.Fragment>
                Data for <strong>{projects[ 0 ].name}</strong>
              </React.Fragment>
            )
          }
  }

  const forResearchBlock = null == props.forResearch ?
  (
      <Grid item xs={6}>
        <FormControlLabel label={t('consent_switch') } control={
          <Switch
            value={forResearch}
            onChange={ (evt)=>{setForResearch( evt.target.checked )} }/>
        }/>
      </Grid>

  ) : null;

  const anonymizeBlock = null == props.anonymize ?
  (
      <Grid item xs={6}>
        <FormControlLabel label={t('anon_switch') } control={
          <Switch
            value={anonymize}
            onChange={(evt)=>{setAnonymize( evt.target.checked )}}/>
        }/>
      </Grid>

  ) : null;

  return (
    <Grid container>
      {forResearchBlock}
      {anonymizeBlock}
      <Grid item xs={12} m={3}>
        {projectSelect( )}
      </Grid>
      <Grid item xs={12} m={3}>
        {subjectSelect( )}
      </Grid>
    </Grid>
  );
}

ChartContainer.propTypes = {
  unitOfAnalysis: PropTypes.oneOf([ 'group', 'individual']).isRequired,
  projects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      name: PropTypes.string.isRequired
    })
  ),
  anonymize: PropTypes.bool,
  forResearch: PropTypes.bool
};
