import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";

import CloseIcon from "@mui/icons-material/Close";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import AdminListToolbar from "../infrastructure/AdminListToolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";

export default function SchoolList(props) {
  const category = "school";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t } = useTranslation(`${category}s`);

  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const navigate = useNavigate();

  const dispatch = useDispatch();

  const [schools, setSchools] = useState([]);
  const [filterText, setFilterText] = useState( '' );

  const getSchools = () => {
    const url = endpoints.baseUrl + ".json";

    dispatch(startTask());
    axios.get(url, {}).then(response => {
      //Process the data
      setSchools(response.data);
      dispatch(endTask("loading"));
    });
  };

  useEffect(() => {
    if (endpointStatus) {
      getSchools();
      dispatch(endTask("loading"));
    }
  }, [endpointStatus]);

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
  };

  const schoolTable = (
    <DataTable
      value={schools.filter( (school) =>{
        return filterText.length === 0 || school.name.includes( filterText );
      })}
            resizableColumns
            reorderableColumns
            paginator
            rows={5}
            tableStyle={{
              minWidth: '50rem'
            }}
            rowsPerPageOptions={
              [5, 10, 20, rubrics.length]
            }
            header={<AdminListToolbar
              itemType={category}
              filterValue={filterText}
              setFilterFunc={setFilterText}
              />}
            sortField="name"
            sortOrder={1}
            paginatorDropdownAppendTo={'self'}
            paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
            currentPageReportTemplate="{first} to {last} of {totalRecords}"
            dataKey="id"
            onRowClick={(event) => {
              navigate(String(event.data.id));
            }}
          >

        <Column
          header={t('index.name_lbl')}
          field="name"
          sortable
          filter
          key={'name'}
          />
        <Column
          header={t('index.courses_lbl')}
          field="courses"
          sortable
          filter
          key={'courses'}
          />
        <Column
          header={t('index.students_lbl')}
          field="students"
          sortable
          filter
          key={'students'}
          />
        <Column
          header={t('index.instructors_lbl')}
          field="instructors"
          sortable
          filter
          key={'instructors'}
          />
        <Column
          header={t('index.project_lbl')}
          field="project"
          sortable
          filter
          key={'project'}
          />
        <Column
          header={t('index.experience_lbl')}
          field="experience"
          sortable
          filter
          key={'experience'}
          />
        <Column
          header={t('index.terms_list_lbl')}
          field="terms_lists"
          sortable
          filter
          key={'terms_list'}
          />

    </DataTable>

  );

  return (
    <React.Fragment>
      <Collapse in={showErrors}>
        <Alert
          action={
            <IconButton
              aria-label="close"
              color="inherit"
              size="small"
              onClick={() => {
                setShowErrors(false);
              }}
            >
              <CloseIcon fontSize="inherit" />
            </IconButton>
          }
        >
          {messages["main"] || null}
        </Alert>
      </Collapse>
      <div style={{ maxWidth: "100%" }}>{schoolTable}</div>
    </React.Fragment>
  );
}
