import React, { useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";


import { DataTable } from "primereact/datatable";

import { DateTime, Settings } from "luxon";

import { iconForType } from "./ActivityLib";

import { useTypedSelector } from "./infrastructure/AppReducers";
import Logo from "./Logo";
import { useTranslation } from "react-i18next";
import TaskListToolbar from "./TaskListToolbar";
import { Column } from "primereact/column";
import { Checkbox } from "primereact/checkbox";

enum TaskType {
  experience = 'experience',
  assignment = 'assignment',
  assessment = 'assessment',
  bingo = 'bingo_game'
  
}

enum OPT_COLS {
  GROUP = 'group_name',
  INSTRUCTOR_TASK = 'instructor_task',
  STATUS = 'status.label',
  START_DATE = 'start_date',
  NEXT_DATE = 'next_date',
  CONSENT_LINK = 'consent_form.label',

}
interface ITaskItem {
  id: number,
  type: TaskType,
  instructor_task: boolean,
  name: string,
  course_name: string,
  group_name: string,
  status: string,
  start_date: DateTime,
  end_date: DateTime,
  next_date: DateTime,
  link: string,
  consent_link: string,
  active: boolean
}

type Props = {
  tasks: Array< ITaskItem >;
};

export default function TaskList(props: Props) {
  const category = "home";
  //const endpoints = useTypedSelector(state=>state['context'].endpoints[endpointSet])
  //const endpointStatus = useTypedSelector(state=>state['context'].endpointsLoaded)
  const { t } = useTranslation( category );
  const user = useTypedSelector(state => state.profile.user);

  const navigate = useNavigate();
  const [filterText, setFilterText] = React.useState('');
  const optColumns = [
    t( `list.${OPT_COLS.GROUP}`),
    t(`list.${OPT_COLS.INSTRUCTOR_TASK}`),
    t(`list.${OPT_COLS.STATUS}`),
    t(`list.${OPT_COLS.START_DATE}`),
    t(`list.${OPT_COLS.NEXT_DATE}`),
    t(`list.${OPT_COLS.CONSENT_LINK}`)
  ];
  const [visibleColumns, setVisibleColumns] = React.useState([
    t( `list.${OPT_COLS.GROUP}`),
    t(`list.${OPT_COLS.STATUS}`),

  ]);


  const instructorTasks = useMemo( ()=>{
    let found = false;
    props.tasks.forEach( (task)=>{
      found ||= task.instructor_task;
    })
    return found;
  }, [props.tasks])

  const tableOfTasks = null !== user.lastRetrieved? (
    <>
      <DataTable
        value={props.tasks.filter((task) => {
          return filterText.length === 0
            || task.name.includes(filterText)
            || task.course_name.includes(filterText) ;
        })}
        resizableColumns
        tableStyle={{
          minWidth: '50rem'
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={
          [5, 10, 20, props.tasks.length]
        }
        header={<TaskListToolbar
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
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
        onRowClick={(event) => {
          const link = event.data.link;
          navigate( link, {
            relative: 'path'
          } );
        }}
        >
          <Column
            header={t("list.type")}
            field={'type'}
            sortable
            filter
            key={'type'}
            body={(params) => {
              return iconForType( params.type )
            }}
            />
          <Column
            header={t("list.task_name")}
            field={'name'}
            sortable
            filter
            key={'name'}
            />
          <Column
            header={t("list.course_name")}
            field={'course_name'}
            sortable
            filter
            key={'course_name'}
            />
          { visibleColumns.includes(t(`list.${OPT_COLS.GROUP}`)) ?
          (
          <Column
            header={t(`list.${OPT_COLS.GROUP}`)}
            field={OPT_COLS.GROUP}
            sortable
            filter
            key={OPT_COLS.GROUP}
            />
          ) : null
          }
          { visibleColumns.includes(t(`list.${OPT_COLS.STATUS}`)) ?
          (
          <Column
            header={t(`list.${(OPT_COLS.STATUS)}`)}
            field={'status'}
            sortable
            filter
            key={'status'}
            body={(params) => {
              let output = `${params.status}%`;
              if( params.type === 'assessment' ){
                if( 0 == params.value ){
                  output = t('list.status.incomplete');
                } else {
                  output = t('list.status.complete');
                }
              }
              return output;
            }}
            />
          ) : null
          }
          { visibleColumns.includes(t(`list.${OPT_COLS.START_DATE}`)) ?
          (
          <Column
            header={t(`list.${OPT_COLS.START_DATE}`)}
            field={OPT_COLS.START_DATE}
            sortable
            filter
            key={OPT_COLS.START_DATE}
            body={(params) => {
              return <span>{params.start_date.toLocaleString( DateTime.DATETIME_MED )}</span>;
            }}

            />
          ) : null
          }
          { visibleColumns.includes(t(`list.${OPT_COLS.NEXT_DATE}`)) ?
          (
          <Column 
            header={t(`list.${OPT_COLS.NEXT_DATE}`)}
            field={OPT_COLS.NEXT_DATE}
            sortable
            filter
            key={OPT_COLS.NEXT_DATE}
            body={(params) => {
              return <span>{params.next_date.toLocaleString( DateTime.DATETIME_MED )}</span>;
            }}
            />
          ) : null
          }
          { visibleColumns.includes(t(`list.${OPT_COLS.CONSENT_LINK}`)) ?
          (
          <Column
            header={t(`list.${OPT_COLS.CONSENT_LINK}`)}
            field={'consent_link'}
            sortable
            filter
            key={'consent_link'}
            body={(params) => {
              const consent = null === params.consent_link ? (
                <span>{t('list.consent_form.absent')}</span>
              ) : (
                <a href={params.consent_link}>{t('list.consent_form.present')}</a>
              );
              return consent;
            }}
            />
          ) : null
          }
          { visibleColumns.includes(t(`list.${OPT_COLS.INSTRUCTOR_TASK}`)) ?
          (
          <Column
            header={t(`list.${OPT_COLS.INSTRUCTOR_TASK}`)}
            field={OPT_COLS.INSTRUCTOR_TASK}
            sortable
            filter
            key={OPT_COLS.INSTRUCTOR_TASK}
            body={(params) => {
              return <Checkbox checked={params.instructor_task} disabled={true} />;
            }}
            />
          ) : null
          }

        </DataTable>
    </>
    ) : (
      <Logo height={100} width={100} spinning />
    );
  return (
      <div style={{ maxWidth: "100%" }}>{tableOfTasks}</div>
  );
}

export { ITaskItem }