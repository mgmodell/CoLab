import React, { useState, useEffect } from "react";
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

import {
  DataGrid,
  GridCellEditStopParams,
  GridCellParams,
  GridColDef,
  GridPreProcessEditCellProps,
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

  const editableValueSetter = (params: GridValueSetterParams, field)=>{
    const row = rubricCriteria.find( (criterium)=>{ return criterium.id === params.row.id} )
    row[field] = params.value
    setRubricCriteria( rubricCriteria );
    return row;
  }

  const columns: GridColDef[] = [
    { field: 'id', hide: true, sortable: false },
    { field: 'sequence', headerName: t( 'criteria.sequence' ),
      hide: true, sortable: true },
    { field: 'description', headerName: t( 'criteria.description' ),
      valueSetter: (params, field) => editableValueSetter( params, 'description'),
      editable: true, sortable: false },
    { field: 'weight', headerName: t( 'criteria.weight' ), type: 'number',
      valueSetter: (params, field) => editableValueSetter( params, 'weight'),
      editable: true, sortable: false },
    { field: 'l1_description', headerName: t( 'criteria.l1_description' ),
      valueSetter: (params, field) => editableValueSetter( params, 'l1_description'),
      editable: true, sortable: false },
    { field: 'l2_description', headerName: t( 'criteria.l2_description' ),
      valueSetter: (params, field) => editableValueSetter( params, 'l2_description'),
      editable: true, sortable: false },
    { field: 'l3_description', headerName: t( 'criteria.l3_description' ),
      valueSetter: (params, field) => editableValueSetter( params, 'l3_description'),
      editable: true, sortable: false },
    { field: 'l4_description', headerName: t( 'criteria.l4_description' ),
      valueSetter: (params, field) => editableValueSetter( params, 'l4_description'),
      editable: true, sortable: false },
    { field: 'l5_description', headerName: t( 'criteria.l5_description' ),
      valueSetter: (params, field) => editableValueSetter( params, 'l5_description'),
      editable: true, sortable: false },
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
    Object.assign( { id: -1, sequence: 1 }, freshCriteria)
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

    const saveableCriteria = rubricCriteria.map( (value, index, array)=>{
      value.id = value.id < 1 ? null : value.id;
      return value;
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
    <Button variant="contained" onClick={saveRubric} disabled={!dirty}>
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
            experimentalFeatures={{ newEditingApi: true }}
            autoHeight
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
                      onClick={event =>{
                        const newList = [...rubricCriteria];
                        const newCriteria = Object.assign(
                          {
                            id: -1 * (rubricCriteria.length + 1 ),
                            sequence: rubricCriteria.length + 1,
                          }, freshCriteria );
                        newList.push( newCriteria );
                        setRubricCriteria( newList);
                      }}
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
