import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";

import AdminListToolbar from "../infrastructure/AdminListToolbar";


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
  const [filterText, setFilterText] = useState('');
  const navigate = useNavigate();

  const dispatch = useDispatch();
  enum OPT_COLS {
    PUBLISHED = 'published',
    VERSION = 'version',
    CREATOR = 'creator',
  }
  const optColumns = [
    OPT_COLS.PUBLISHED,
    OPT_COLS.VERSION,
    OPT_COLS.CREATOR,
  ];
  const [visibleColumns, setVisibleColumns] = useState([]);

  const [rubrics, setRubrics] = useState([]);

  const getRubrics = () => {
    const url = endpoints.baseUrl + ".json";

    dispatch(startTask());
    axios.get(url, {}).then(response => {
      //Process the data
      setRubrics(response.data);
      dispatch(endTask("loading"));
    }).catch(error => {
      console.log(error);
    })
      .finally(() => {
        dispatch(endTask("loading"));
      })
  };

  useEffect(() => {
    if (endpointStatus) {
      getRubrics();
      dispatch(endTask("loading"));
    }
  }, [endpointStatus]);

  const postNewMessage = msgs => {
    Object.keys(msgs).forEach(key => {
      if ('main' === key) {
        dispatch(addMessage(msgs[key], new Date(), Priorities.INFO));
      } else {
        dispatch(addMessage(msgs[key], new Date(), Priorities.WARNING));
      }
    });
  };

  return (
    <React.Fragment>
      <div style={{ display: "flex", height: "100%" }}>
        <div style={{ flexGrow: 1 }}>
          <DataTable
            value={rubrics.filter((rubric) => {
              return filterText.length === 0 || rubric.name.includes(filterText);

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
              filtering={{
                filterValue: filterText,
                setFilterFunc: setFilterText,
              }}
              columnToggle={{
                optColumns: optColumns,
                visibleColumns: visibleColumns,
                setVisibleColumnsFunc: setVisibleColumns,

              }}
            />}
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
              header={t('name')}
              field='name'
              sortable
              data-id='name'
              filter
              key={'name'}
            />
            {visibleColumns.includes(OPT_COLS.PUBLISHED) ? (
              <Column
                header={t('show.published')}
                field='published'
                sortable
                filter
                key={'published'}
              />
            ) : null}
            {visibleColumns.includes(OPT_COLS.VERSION) ? (
              <Column
                header={t('version')}
                field='version'
                sortable
                filter
                key={'version'}
              />
            ) : null}
            {visibleColumns.includes(OPT_COLS.CREATOR) ? (
              <Column
                header={t('show.creator')}
                field='user'
                sortable
                filter
                key={'user'}
              />
            ) : null}
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
                        dispatch(startTask());
                        axios
                          .get(url)
                          .then(resp => {
                            // check for possible errors
                            postNewMessage(resp.data.messages);
                            getRubrics();
                          })
                          .catch(error => {
                            console.log(error);
                          })
                          .finally(() => {
                            dispatch(endTask());
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
