import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { useTranslation } from "react-i18next";
import {
  FormControl,
  FormControlLabel,
  Grid,
  InputLabel,
  MenuItem,
  Select,
  Skeleton,
  Switch,
  Typography } from "@mui/material";
import SubjectChart, {unit_codes, code_units} from "./SubjectChart";
import ConfirmDialog from "./ConfirmDialog";

export default function ChartContainer(props) {


  const category = "graphing";
  const endpoints = useTypedSelector(state=>state.context.endpoints[category]);
  const endpointStatus = useTypedSelector(state=>state.context.status.endpointsLoaded );
  const { t, i18n } = useTranslation( category );

  const [projects, setProjects] = useState( props.projects || [] );
  const [selectedProject, setSelectedProject] = useState( -1 );
  const [subjects, setSubjects] = useState( [] );
  const [selectedSubject, setSelectedSubject] = useState( -1 );
  const [anonymizeOpen, setAnonymizeOpen] = useState( false );
  const [forResearchOpen, setForResearchOpen] = useState( false );
  const [anonymize, setAnonymize] = useState( props.anonymize || false );
  const [forResearch, setForResearch] = useState( props.forResearch || false );

  const [charts, setCharts] = useState( {} );
  const [open, setOpen] = useState( false );

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
        clearCharts( );
      } else {
        if( 1 === props.projects.length){
          setSelectedProject( props.projects[ 0 ].id );
          getSubjectsForProject( props.projects[ 0 ].id );
        }
      }
    }
  }, [endpointStatus, forResearch, anonymize ])

  const clearCharts = ( ) =>{
    if( endpointStatus ){
        setCharts( { } );
        setSelectedSubject( -1 );
        setSelectedProject( -1 );
        getProjects( );
        setSubjects( [] );
    }
  }

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


  const selectSubject = (subjectId : number ) =>{
    if( 0 < subjectId ){

      const chartsCopy = Object.assign( {}, charts );
      const chart = chartsCopy[ subjectId ];
      if( null == chart ){
        chartsCopy[ subjectId ] = {
          index: Object.keys( charts ).length + 1,
          hidden: false,
          subjectId: subjectId
        }
      } else {
        chart.hidden = false;
      }
      setCharts( chartsCopy );
    }
    setSelectedSubject( subjectId );

  }

  const hideChart = (subjectId : number ) =>{
    const chartsCopy = Object.assign( {}, charts );
    chartsCopy[ subjectId ]['hidden'] = true;
    setCharts( chartsCopy );
  }

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
                  onChange={(evt)=>{selectSubject( evt.target.value )}}
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
          if( null == projects || 0 == projects.length ){
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
          )} else {
            return(
              <React.Fragment>
                Data for <strong>{projects[ 0 ].name}</strong>
              </React.Fragment>
            )
          }
  }

  const closeForResearch = (agree) =>{
    if( agree ){
      setForResearch( !forResearch );
    } 
    setForResearchOpen( false );
  }

    
  const forResearchBlock = null == props.forResearch ?
  (
      <Grid item xs={6}>
        <FormControlLabel label={t('consent_switch') } control={
          <Switch
            disabled={2 > projects.length}
            checked={forResearch}
            onChange={ () => setForResearchOpen( true ) }/>
        }/>
        <ConfirmDialog
          isOpen={forResearchOpen}
          closeFunc={closeForResearch}
          />
      </Grid>

  ) : null;


  const closeAnonymize = (agree) =>{
    if( agree ){
      setAnonymize( !anonymize );
    } 
    setAnonymizeOpen( false );
  }

  const anonymizeBlock = null == props.anonymize ?
  (
      <Grid item xs={6}>
        <FormControlLabel label={t('anon_switch') } control={
          <Switch
            disabled={2 > projects.length}
            checked={anonymize}
            onChange={()=>{setAnonymizeOpen( true )}}/>
        }/>
        <ConfirmDialog
          isOpen={anonymizeOpen}
          closeFunc={closeAnonymize}
          />
      </Grid>
  ) : null;

  return (
    <Grid container>
      {forResearchBlock}
      {anonymizeBlock}
      <Grid item xs={12} sm={6}>
        {projectSelect( )}
      </Grid>
      <Grid item xs={12} sm={6}>
        {subjectSelect( )}
      </Grid>
      <Grid item xs={12}>
        {Object.values( charts )
          .sort( (a,b)=>{ a.index - b.index })
          .map( chart =>{
            return (
              <SubjectChart
                key={chart.index}
                subjectId={chart.subjectId}
                projectId={selectedProject}
                unitOfAnalysis={props.unitOfAnalysis}
                forResearch={forResearch}
                anonymize={anonymize}
                hideFunc={()=>hideChart(chart.subjectId)}
                hidden={chart.hidden}
              />
            )
        })}

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
