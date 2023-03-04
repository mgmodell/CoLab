import React, { useState, useEffect, Fragment } from "react";
//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  addMessage,
  Priorities,
  setDirty,
  setClean
} from "../infrastructure/StatusSlice";
import { useParams } from "react-router-dom";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import InputLabel from "@mui/material/InputLabel";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import Paper from "@mui/material/Paper";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";

import AddIcon from '@mui/icons-material/Add';
import FileCopyIcon from '@mui/icons-material/FileCopy';
import DeleteIcon from '@mui/icons-material/Delete';
import KeyboardArrowUpIcon from '@mui/icons-material/KeyboardArrowUp';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';

import {
  DataGrid,
  GridActionsCellItem,
  GridCellEditStopParams,
  GridCellParams,
  GridColDef,
  GridPreProcessEditCellProps,
  GridRenderCellParams,
  GridRowModel,
  GridRowModes,
  GridToolbarContainer,
  GridToolbarDensitySelector,
  GridValueSetterParams,
  MuiEvent
} from '@mui/x-data-grid';

import { Settings } from "luxon";

//import i18n from './i18n';
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { number } from "prop-types";
import { IconButton, Tooltip } from "@mui/material";

export default function RubricDataAdmin(props) {
  const category = "rubric";
  const endpoints = useTypedSelector(state => {
    return state.context.endpoints[category];
  });
  const { t } = useTranslation(`${category}s`);
  const endpointStatus = useTypedSelector(state => {
    return state.context.status.endpointsLoaded;
  });
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );
  const userLoaded = useTypedSelector(state => {
    return null != state.profile.lastRetrieved;
  });

  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });

  const dispatch = useDispatch();
  const freshCriteria = {
                            description: 'New Criteria',
                            weight: 1,
                            l1_description: "The bare minimum to register a score."
                          };

  const addCriteria = () =>{
    const newList = [...rubricCriteria];
    const newCriteria = Object.assign(
      {
        id: -1 * (rubricCriteria.length + 1 ),
        sequence: rubricCriteria.length + 1,
      }, freshCriteria );
    newList.push( newCriteria );
    setRubricCriteria( newList);
  }

  const editableTextValueSetter = (params: GridValueSetterParams, field)=>{
    const row = rubricCriteria.find( (criterium)=>{ return criterium.id === params.row.id} )
    row[field] = params.value;
    row.id = params.row.id;
    
    // setRubricCriteria( rubricCriteria );
    return row;
  }

  const renumCriteria = (criteriaArray) =>{
    const tmpCriteria = [...criteriaArray]
    tmpCriteria.sort( (a,b) =>{ return a.sequence - b.sequence })
    for( let index = 0; index < tmpCriteria.length; index++ ){
      tmpCriteria[ index ].sequence = index * 2;
    }
    return tmpCriteria;
  }

  const columns: GridColDef[] = [
    { field: 'sequence', headerName: t( 'criteria.sequence' ),
      hide: true, sortable: true },
    { field: 'description', headerName: t( 'criteria.description' ),
      valueSetter: (params, field) => editableTextValueSetter( params, 'description'),
      editable: true, sortable: false },
    { field: 'weight', headerName: t( 'criteria.weight' ), type: 'number',
      valueSetter: (params, field) => editableTextValueSetter( params, 'weight'),
      editable: true, sortable: false },
    { field: 'l1_description', headerName: t( 'criteria.l1_description' ),
      valueSetter: (params, field) => editableTextValueSetter( params, 'l1_description'),
      editable: true, sortable: false },
    { field: 'l2_description', headerName: t( 'criteria.l2_description' ),
      valueSetter: (params, field) => editableTextValueSetter( params, 'l2_description'),
      editable: true, sortable: false },
    { field: 'l3_description', headerName: t( 'criteria.l3_description' ),
      valueSetter: (params, field) => editableTextValueSetter( params, 'l3_description'),
      editable: true, sortable: false },
    { field: 'l4_description', headerName: t( 'criteria.l4_description' ),
      valueSetter: (params, field) => editableTextValueSetter( params, 'l4_description'),
      editable: true, sortable: false },
    { field: 'l5_description', headerName: t( 'criteria.l5_description' ),
      valueSetter: (params, field) => editableTextValueSetter( params, 'l5_description'),
      editable: true, sortable: false },
    { field: 'actions', headerName: '', type: 'actions', editable: false, sortable: false,
      renderCell: (params: GridRenderCellParams)=>(
        <Fragment>
                  <Tooltip title={t('criteria.up')}>
                    <IconButton
                      id='up_criteria'
                      onClick={(event) => {
                        const tmpCriteria = [...rubricCriteria];
                        const criterium = tmpCriteria.find( (value)=> {return params.id == value.id} );
                        criterium.sequence-=3
                        setRubricCriteria( renumCriteria( tmpCriteria ) );

                      }}
                      aria-label={t('criteria.up')}
                      size='small'
                      >
                        <KeyboardArrowUpIcon />
                      </IconButton>
                  </Tooltip>
                  <Tooltip title={t('criteria.down')}>
                    <IconButton
                      id='down_criteria'
                      onClick={(event) => {
                        const tmpCriteria = [...rubricCriteria];
                        const criterium = tmpCriteria.find( (value)=> {return params.id == value.id} );
                        criterium.sequence+=3
                        setRubricCriteria( renumCriteria( tmpCriteria ) );

                      }}
                      aria-label={t('criteria.down')}
                      size='small'
                      >
                        <KeyboardArrowDownIcon />
                      </IconButton>
                  </Tooltip>
                  <Tooltip title={t('criteria.copy')}>
                    <IconButton
                      id='copy_criteria'
                      onClick={(event) => {
                        const tmpCriteria = [...rubricCriteria];
                        console.log( 'start', tmpCriteria.length );
                        const criterium = Object.assign( {}, tmpCriteria.find( (value)=> {return params.id == value.id} ) );
                        criterium.id = 0 - (tmpCriteria.length + 1 );
                        criterium.name += ' (copy)';
                        tmpCriteria.push( criterium );
                        console.log( 'end', tmpCriteria.length );
                        console.log( renumCriteria( tmpCriteria ).length );

                        setRubricCriteria( renumCriteria( tmpCriteria ) );

                      }}
                      aria-label={t('criteria.copy')}
                      size='small'
                      >
                        <FileCopyIcon />
                      </IconButton>
                  </Tooltip>
                  <Tooltip title={t('criteria.delete')}>
                    <IconButton
                      id='delete_criteria'
                      aria-label={t('criteria.delete')}
                      onClick={(event) => {
                        const tmpCriteria = [...rubricCriteria];
                        tmpCriteria = tmpCriteria.filter( (value)=> {return params.id != value.id} );

                        setRubricCriteria( renumCriteria( tmpCriteria ) );

                      }}
                      size='small'
                      >
                        <DeleteIcon />
                      </IconButton>
                  </Tooltip>

        </Fragment>
      )
    }
  ];

  let { rubricIdParam } = useParams();
  const [rubricId, setRubricId] = useState(rubricIdParam);
  const [rubricName, setRubricName] = useState("");
  const [rubricDescription, setRubricDescription] = useState("");
  const [rubricPublished, setRubricPublished] = useState(false);
  const [rubricVersion, setRubricVersion] = useState(1);
  const [rubricCreator, setRubricCreator] = useState('');
  const [rubricSchoolId, setRubricSchoolId] = useState( 0 );

  const [rubricCriteria, setRubricCriteria] = useState( [
    Object.assign( {
      id: -1,
      sequence: 1
    }, freshCriteria)
  ] );

  const [messages, setMessages] = useState({});

  const timezones = useTypedSelector(state => {
    return state.context.lookups["timezones"];
  });

  const getRubric = () => {
    dispatch(startTask());
    var url = endpoints.baseUrl + "/";
    if (null == rubricId) {
      url = url + "new.json";
    } else {
      url = url + rubricId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const rubric = response.data.rubric;

        setRubricName(rubric.name || "");
        setRubricDescription(rubric.description || "");
        setRubricPublished( rubric.published || false );
        setRubricVersion( rubric.version || 1 );
        setRubricCreator( rubric.creator );
        setRubricSchoolId( rubric.school_id );

        rubric.criteria = renumCriteria( rubric.criteria );
        setRubricCriteria( rubric.criteria || [] );

        dispatch(setClean(category));
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
        dispatch(setClean(category));
      });
  };
  const saveRubric = () => {
    const method = null == rubricId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints["baseUrl"] +
      "/" +
      (null == rubricId ? props.rubricId : rubricId) +
      ".json";

    const saveableCriteria = [...rubricCriteria].map( (value, index, array)=>{
      const tmpCriteria = Object.assign( { }, value );
      tmpCriteria.id = value.id < 1 ? null : value.id;
      return tmpCriteria;
    })
    axios({
      method: method,
      url: url,
      data: {
        rubric: {
          name: rubricName,
          description: rubricDescription,
          criteria_attributes: saveableCriteria
        }
      }
    })
      .then(resp => {
        const data = resp["data"];
        const messages = data['messages'];

        if (messages != null && Object.keys(messages).length < 2) {
          const rubric = data.rubric;
          setRubricId(rubric.id);
          setRubricName(rubric.name);
          setRubricDescription(rubric.description);
          setRubricVersion( rubric.version );
          setRubricPublished( rubric.published );
          setRubricCreator( rubric.creator );

          rubric.criteria = renumCriteria( rubric.criteria );
          setRubricCriteria( rubric.criteria || []);

          dispatch(setClean(category));
          dispatch(addMessage(messages.main, new Date(), Priorities.INFO));
          //setMessages(data.messages);
          dispatch(endTask("saving"));
        } else {
          dispatch(
            addMessage(messages.main, new Date(), Priorities.ERROR)
          );
          setMessages(messages);
          dispatch(endTask("saving"));
        }
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getRubric();
    }
  }, [endpointStatus]);


  useEffect(() => {
    dispatch(setDirty(category));
  }, [rubricName, rubricDescription, rubricCriteria ]);

  const saveButton = dirty ? (
    <Button variant="contained"
            aria-label="save-rubric"
            onClick={saveRubric}
            disabled={!dirty}>
      {rubricId > 0 ? "Save" : "Create"} Rubric
    </Button>
  ) : null;

  const detailsComponent = endpointStatus ? (
    <Paper>
      <TextField
        label={t('name')}
        id="rubric-name"
        value={rubricName}
        fullWidth={false}
        onChange={event => setRubricName(event.target.value)}
        error={null != messages["name"]}
        helperText={messages["name"]}
      />
      &nbsp;
      <br />
      <TextField
        id="rubric-description"
        placeholder="Enter a description of the rubric"
        multiline={true}
        minRows={2}
        maxRows={4}
        label={t('description')}
        value={rubricDescription}
        onChange={event => setRubricDescription(event.target.value)}
        InputLabelProps={{
          shrink: true
        }}
        margin="normal"
      />
      <br />
        <div style={{ display: 'flex', height: '100%'}} >
          <div style={ { flexGrow: 1 }} >
          <DataGrid
            getRowHeight={()=> 'auto'}
            experimentalFeatures={{ newEditingApi: true }}
            autoHeight
            getRowId={(model:GridRowModel) =>{
              return model.id;
            }}
            rows={rubricCriteria}
            columns={columns}
            sortModel={[{
              field: 'sequence',
              sort: 'asc'
            }]}
            components={{
              Toolbar: (() =>

                <GridToolbarContainer>
                  <GridToolbarDensitySelector />
                  <Tooltip title={t('criteria.new')}>
                    <IconButton
                      id='new_criteria'
                      onClick={(event) => addCriteria(event)}
                      aria-label={t('criteria.new')}
                      size='small'
                      >
                        <AddIcon />
                        {t('criteria.new')}
                      </IconButton>
                  </Tooltip>
                </GridToolbarContainer>
              ),
            }}
          />
        </div>
      </div>
      {saveButton}
    </Paper>
  ) : null;

  return <Paper>{detailsComponent}</Paper>;
}
