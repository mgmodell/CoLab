import React, { Fragment, useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";

import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";

import FileCopyIcon from "@mui/icons-material/FileCopy";
import DeleteIcon from "@mui/icons-material/Delete";
import {
  GridColDef,
  GridRenderCellParams
} from "@mui/x-data-grid";

import AdminListToolbar from "../infrastructure/AdminListToolbar";


import axios from "axios";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Button } from "primereact/button";

export default function RubricList(props) {
  const category = "rubric";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const user = useTypedSelector(state => state.profile.user);
  const { t } = useTranslation(`${category}s`);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const [filterText, setFilterText] = useState('');
  const navigate = useNavigate();

  const dispatch = useDispatch();
  const columns: GridColDef[] = [
    { field: "name", headerName: t("name") },
    { field: "published", headerName: t("show.published") },
    {
      field: "version",
      type: "number",
      headerName: t("version"),
      getApplyQuickFilterFn: undefined
    },
    { field: "user", headerName: t("show.creator") },
    {
      field: "actions",
      headerName: "",
      type: "actions",
      editable: false,
      sortable: false,
      renderCell: (params: GridRenderCellParams) => (
        <Fragment>
          <Tooltip title={t("rubric.copy")}>
            <IconButton
              id="copy_rubric"
              onClick={event => {
                const rubric = Object.assign(
                  {},
                  rubrics.find(value => {
                    return params.id == value.id;
                  })
                );
                const url = `${endpoints["baseUrl"]}/copy/${rubric.id}.json`;
                axios
                  .get(url)
                  .then(resp => {
                    // check for possible errors
                    getRubrics();
                  })
                  .catch(error => {
                    console.log(error);
                  });
              }}
              aria-label={t("rubric.copy")}
              size="small"
            >
              <FileCopyIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title={t("rubric.delete")}>
            <span>
              <IconButton
                id="delete_rubric"
                aria-label={t("rubric.delete")}
                disabled={params.row.published}
                onClick={event => {
                  const rubric = Object.assign(
                    {},
                    rubrics.find(value => {
                      return params.id == value.id;
                    })
                  );
                  const url = `${endpoints["baseUrl"]}/${rubric.id}.json`;
                  axios.delete(url).then(resp => {
                    // check for possible errors
                    getRubrics();
                  });
                }}
                size="small"
              >
                <DeleteIcon />
              </IconButton>
            </span>
          </Tooltip>
        </Fragment>
      )
    }
  ];

  const [rubrics, setRubrics] = useState([]);

  const getRubrics = () => {
    const url = endpoints.baseUrl + ".json";

    dispatch(startTask());
    axios.get(url, {}).then(response => {
      //Process the data
      setRubrics(response.data);
      dispatch(endTask("loading"));
    });
  };

  useEffect(() => {
    if (endpointStatus) {
      getRubrics();
      dispatch(endTask("loading"));
    }
  }, [endpointStatus]);

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
  };

  return (
    <React.Fragment>
      <div style={{ display: "flex", height: "100%" }}>
        <div style={{ flexGrow: 1 }}>
          <DataTable
            value={rubrics.filter( (rubric) =>{
              return filterText.length === 0 ||  rubric.name.includes( filterText );

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
            //sortField="start_date"
            sortOrder={-1}
            paginatorDropdownAppendTo={'self'}
            paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
            currentPageReportTemplate="{first} to {last} of {totalRecords}"
            //paginatorLeft={paginatorLeft}
            //paginatorRight={paginatorRight}
            dataKey="id"
            onRowClick={(event) => {
              navigate(String(event.data.id));
            }}
          >
            <Column
              header={t('name')}
              field='name'
              sortable
              data-id='name'
              filter
              key={'name'}
            />
            <Column
              header={t('show.published')}
              field='published'
              sortable
              filter
              key={'published'}
            />
            <Column
              header={t('version')}
              field='version'
              sortable
              filter
              key={'version'}
            />
            <Column
              header={t('show.creator')}
              field='user'
              sortable
              filter
              key={'user'}
            />
            <Column
              header={t('index.actions_col')}
              field="id"
              body={(rubric) => {
                const scoresUrl = endpoints.scoresUrl + rubric.id + ".csv";
                const copyUrl = endpoints.courseCopyUrl + rubric.id + ".json";
                return (
                  <>
                    <Button
                      icon='pi pi-copy'
                      tooltip={t('rubric.copy')}
                      tooltipOptions={{
                        position: 'left',
                      }}
                      id={'copy_rubric'}
                      onClick={event => {
                        const url = `${endpoints["baseUrl"]}/copy/${rubric.id}.json`;
                        axios
                          .get(url)
                          .then(resp => {
                            // check for possible errors
                            getRubrics();
                          })
                          .catch(error => {
                            console.log(error);
                          });
                      }}
                      aria-label={t('rubric.copy')}
                      size="large"
                    />
                    <Button
                      icon='pi pi-trash'
                      tooltip={t('rubric.delete')}
                      disabled={rubric.published}
                      tooltipOptions={{
                        position: 'left',
                      }}
                      id={'delete_rubric'}
                      onClick={event => {
                        const rubric = Object.assign(
                          {},
                          rubrics.find(value => {
                            return rubric.id == value.id;
                          })
                        );
                        const url = `${endpoints["baseUrl"]}/${rubric.id}.json`;
                        axios.delete(url).then(resp => {
                          // check for possible errors
                          getRubrics();
                        });
                      }}
                      aria-label={t('rubric.copy')}
                      size="large"
                    />
                  </>

                )

              }
              }
            />

          </DataTable>

        </div>
      </div>
    </React.Fragment>
  );
}

RubricList.propTypes = {};
