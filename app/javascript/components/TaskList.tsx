import React, { useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import Paper from "@mui/material/Paper";
import Link from "@mui/material/Link";
import { DateTime, Settings } from "luxon";

import { iconForType } from "./ActivityLib";

import { useTypedSelector } from "./infrastructure/AppReducers";
import Logo from "./Logo";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import { Checkbox } from "@mui/material";
import TaskListToolbar from "./TaskListToolbar";
import { renderDateCellExpand, renderTextCellExpand } from "./infrastructure/GridCellExpand";

enum TaskType {
  experience = 'experience',
  assignment = 'assignment',
  assessment = 'assessment',
  bingo = 'bingo_game'
  
}
interface ITaskItem {
  id: number,
  type: TaskType,
  instructor_task: boolean,
  name: string,
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

  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );
  const navigate = useNavigate();

  const newColumns: GridColDef[] = [
    {
      headerName: t( 'list.type' ),
      field: 'type',
      width: 50,
      renderCell: (params) => {
        return iconForType( params.value )

      }
    },
    {
      headerName: t('list.task_name'),
      flex: 0.20,
      field: 'name',
      renderCell: renderTextCellExpand
    },
    {
      headerName: t( 'list.course_name' ),
      flex: 0.15,
      field: 'course_name',
      renderCell: renderTextCellExpand
    },
    {
      headerName: t( 'list.group_name' ),
      field: 'group_name',
      renderCell: renderTextCellExpand
    },
    {
      headerName: t( 'list.status.label' ),
      field: 'status',
      renderCell: (params) => {
        let output = `${params.value}%`;
        if( params.row.type === 'assessment' ){
          if( 0 == params.value ){
            output = t('list.status.incomplete');
          } else {
            output = t('list.status.complete');
          }
        }
        return output;
      }
    },
    {
      headerName: t( 'list.start_date' ),
      field: 'start_date',
      width: 170,
      renderCell: renderDateCellExpand
    },
    {
      headerName: t( 'list.next_date' ),
      field: 'next_date',
      width: 170,
      renderCell: renderDateCellExpand
    },
    {
      headerName: t( 'list.consent_form.label' ),
      field: 'consent_link',
      renderCell: (params) => {
        const consent = null === params.value ? (
          <span>{t('list.consent_form.absent')}</span>
        ) : (
          <Link href={params.value}>{t('list.consent_form.present')}</Link>
        );
        return consent;
      }
    },
    {
      headerName: t( 'list.instructor_task' ),
      field: 'instructor_task',
      renderCell: (params) => {
        return <Checkbox value={params.value} disabled={true} />;
      }
    }
  ];

  const instructorTasks = useMemo( ()=>{
    let found = false;
    console.log( props.tasks );
    props.tasks.forEach( (task)=>{
      found ||= task.instructor_task;
    })
    return found;
  }, [props.tasks])

  const tableOfTasks =
    null !== user.lastRetrieved && null !== tz_hash ? (
      <DataGrid
        isCellEditable={() => false}
        columns={newColumns}
        getRowId={(row ) =>{
          const uid =`${row.type}-${row.id}`;
          return uid;
        }}
        rows={props.tasks}
        onCellClick={(params, event, details ) =>{
          const link = params.row.link;
          navigate( link );
        }}
        components={{
          Toolbar: TaskListToolbar
        } }
        initialState={{
          columns: {
            columnVisibilityModel: {
              type: true,
              instructor_task: instructorTasks,
              consent_link: false,
              status: false,
              start_date: false
            }
          },
          pagination: {
            paginationModel: { page: 0, pageSize: 5}
          }

        }}
        pageSizeOptions={[5, 10 ]}
      />
    ) : (
      <Logo height={100} width={100} spinning />
    );
  return (
    <Paper>
      <div style={{ maxWidth: "100%" }}>{tableOfTasks}</div>
    </Paper>
  );
}

export { ITaskItem }