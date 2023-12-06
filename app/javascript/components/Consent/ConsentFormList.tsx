import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";


import { useTypedSelector } from "../infrastructure/AppReducers";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useTranslation } from "react-i18next";
import AdminListToolbar from "../infrastructure/AdminListToolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Checkbox } from "primereact/checkbox";

export default function ConsentFormList(props) {
  const category = "consent_form";
  const { t } = useTranslation(`${category}s`);
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const dispatch = useDispatch();

  const navigate = useNavigate();

  const user = useTypedSelector(state => state.profile.user);
  enum OPT_COLS {
    NAME = 'name',
    ACTIVE = 'active',
  }
  const [filterText, setFilterText] = useState('');
  const optColumns = [
    OPT_COLS.NAME,
    OPT_COLS.ACTIVE,
  ];
  const [visibleColumns, setVisibleColumns] = useState([]);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [consentForms, setConsentForms] = useState([]);

  const getSchools = () => {
    const url = endpoints.baseUrl + ".json";
    dispatch(startTask("loading"));

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //Process the data
        setConsentForms(data);
        dispatch(endTask("loading"));
      })
      .catch(error => {
        console.log("error", error);
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

  const dataTable = (
      <DataTable
        value={consentForms.filter((course) => {
          return filterText.length === 0 || course.name.includes(filterText);
        })}
        resizableColumns
        tableStyle={{
          minWidth: '50rem'
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={
          [5, 10, 20, consentForms.length]
        }
        header={<AdminListToolbar
          itemType={category}
          filtering={{
            filterValue: filterText,
            setFilterFunc: setFilterText
          }}
          columnToggle={{
            optColumns: optColumns,
            visibleColumns: visibleColumns,
            setVisibleColumnsFunc: setVisibleColumns,
          }}
        />}
        sortField="start_date"
        sortOrder={-1}
        paginatorDropdownAppendTo={'self'}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        dataKey="id"
        onRowClick={(event) => {
          navigate(String(event.data.id));
        }}
      >
        <Column
          header={t('index.name_col')}
          field={'name'}
          sortable
          filter={false}
          key={'name'}
          />
        <Column
          header={t('index.active_col')}
          field={'active'}
          sortable
          filter
          key={'active'}
          body={param =>{
            return <Checkbox checked={param.active} disabled />
          }}
          />
      </DataTable>

  );

  return (
    <React.Fragment>
      <div style={{ maxWidth: "100%" }}>{dataTable}</div>
    </React.Fragment>
  );
}
