import React, { useMemo } from "react";
import { useNavigate } from "react-router";
import parse from 'html-react-parser';


import { DataTable } from "primereact/datatable";

import { Temporal, formatZonedDateTime, DATETIME_MED } from "./infrastructure/TemporalSettings";

import { iconForType } from "./ActivityLib";

import { useTypedSelector } from "./infrastructure/AppReducers";
import Logo from "./svgs/Logo";
import { useTranslation } from "react-i18next";
import TaskListToolbar, { type GroupBy } from "./toolbars/TaskListToolbar";
import { Column } from "primereact/column";
import { Checkbox } from "primereact/checkbox";
import { p } from "react-router/dist/development/index-react-server-client-BBd0A0TL";

enum TaskType {
  experience = 'experience',
  assignment = 'assignment',
  assessment = 'assessment',
  project = 'project',
  bingo = 'bingo_game',
  submission = 'submission'
}

interface IGroupedTaskItem extends ITaskItem {
  groupKey: string;
  groupLabel: string;
  closeDateSort: number;
}

type SortMeta = {
  field: string;
  order: 1 | 0 | -1 | null | undefined;
};

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
  course_name: string | null,
  group_name: string,
  status: string,
  start_date: Temporal.ZonedDateTime,
  end_date: Temporal.ZonedDateTime | null,
  next_date: Temporal.ZonedDateTime,
  link: string,
  consent_link: string,
  active: boolean
}

type Props = {
  tasks: Array<ITaskItem>;
};

export default function TaskList(props: Props) {
  const category = "home";
  const { t } = useTranslation(category);
  const user = useTypedSelector(state => state.profile.user);

  const navigate = useNavigate();
  const [filterText, setFilterText] = React.useState('');
  const normalizedFilter = filterText.trim().toLowerCase();
  const [groupBy, setGroupBy] = React.useState<GroupBy>("course");
  const [collapsedGroupKeys, setCollapsedGroupKeys] = React.useState<Set<string>>(
    () => new Set()
  );
  const [sortMeta, setSortMeta] = React.useState<SortMeta[]>([
    { field: "groupKey", order: 1 as const },
    { field: "closeDateSort", order: 1 as const }
  ]);
  const groupingOptions: Array<{ label: string; value: GroupBy }> = [
    { label: t("list.group_by_type"), value: "type" },
    { label: t("list.group_by_course"), value: "course" },
    { label: t("list.group_by_week"), value: "week" }
  ];
  const optColumns = [
    t(`list.${OPT_COLS.GROUP}`),
    t(`list.${OPT_COLS.INSTRUCTOR_TASK}`),
    t(`list.${OPT_COLS.STATUS}`),
    t(`list.${OPT_COLS.START_DATE}`),
    t(`list.${OPT_COLS.NEXT_DATE}`),
    t(`list.${OPT_COLS.CONSENT_LINK}`)
  ];
  const [visibleColumns, setVisibleColumns] = React.useState([
    t(`list.${OPT_COLS.STATUS}`),
    t(`list.${OPT_COLS.NEXT_DATE}`),
  ]);


  const instructorTasks = useMemo(() => {
    let found = false;
    props.tasks.forEach((task) => {
      found ||= task.instructor_task;
    })
    return found;
  }, [props.tasks])

  const paginatorOpts = Array.from(
    [
    5, 10, 20, props.tasks.length
  ] );

  const groupedTasks = useMemo(
    () => props.tasks.map(task => {
      const closeDate = task.next_date ?? task.end_date;
      const closeDateSort = closeDate?.toInstant().epochMilliseconds ?? Infinity;
      const retVal = {
        ...task,
        groupKey: "",
        closeDateSort,
        groupLabel: ""
      };

      switch (groupBy) {
        case "type":
          retVal.groupKey = `type:${task.type}`;
          retVal.groupLabel = t(`list.task_types.${task.type}`, {
            defaultValue: task.type
              .replace(/_/g, " ")
              .replace(/\b\w/g, letter => letter.toUpperCase())
          });
          break;
        case "course":
          const courseName = task.course_name || t("list.unknown_course");
          retVal.groupKey = `course:${courseName}`;
          retVal.groupLabel = courseName;
          break;
        case "week":
          const closeDatePlain = closeDate?.toPlainDate();
          const weekStart = closeDatePlain?.subtract({
            days: closeDatePlain.dayOfWeek - 1
          });
          retVal.groupKey = `week:${weekStart?.toString() ?? "none"}`;
          retVal.groupLabel = weekStart
            ? t("list.week_of", { date: weekStart.toString() })
            : t("list.no_close_date");
          break;
        default:
          retVal.groupKey = "none";
          retVal.groupLabel = t("list.no_grouping");
      }
      return retVal;

    }),
    [groupBy, props.tasks, t]
  );

  const visibleTasks = useMemo(() => groupedTasks.filter(task =>
    normalizedFilter.length === 0
    || task.name.toLowerCase().includes(normalizedFilter)
    || task.course_name?.toLowerCase().includes(normalizedFilter)
  ), [groupedTasks, normalizedFilter]);

  const expandedRows = useMemo(() => {
    const groupRepresentatives = new Map<string, IGroupedTaskItem>();
    visibleTasks.forEach(task => {
      if (!collapsedGroupKeys.has(task.groupKey)) {
        groupRepresentatives.set(task.groupKey, task);
      }
    });
    return [...groupRepresentatives.values()];
  }, [collapsedGroupKeys, visibleTasks]);

  const onRowToggle = (event: { data: IGroupedTaskItem[] }) => {
    const expandedGroupKeys = new Set(event.data.map(task => task.groupKey));
    const visibleGroupKeys = new Set(visibleTasks.map(task => task.groupKey));

    setCollapsedGroupKeys(current => {
      const next = new Set(
        [...current].filter(groupKey => !visibleGroupKeys.has(groupKey))
      );
      visibleGroupKeys.forEach(groupKey => {
        if (!expandedGroupKeys.has(groupKey)) {
          next.add(groupKey);
        }
      });
      return next;
    });
  };

  const tableOfTasks = null !== user.lastRetrieved ? (
    <>
      <DataTable
        value={visibleTasks}
        resizableColumns
        tableStyle={{
          minWidth: '50rem'
        }}
        reorderableColumns
        rowGroupMode="subheader"
        groupRowsBy="groupKey"
        expandableRowGroups
        expandedRows={expandedRows}
        onRowToggle={onRowToggle}
        rowGroupHeaderTemplate={(task: IGroupedTaskItem) => (
          <span>{task.groupLabel}</span>
        )}
        paginator
        rows={5}
        rowsPerPageOptions={ paginatorOpts }
        header={<TaskListToolbar
          filtering={{
            filterValue: filterText,
            setFilterFunc: setFilterText
          }}
          grouping={{
            label: t("list.group_by"),
            value: groupBy,
            options: groupingOptions,
            setGroupByFunc: setGroupBy
          }}
          columnToggle={{
            optColumns: optColumns,
            visibleColumns: visibleColumns,
            setVisibleColumnsFunc: setVisibleColumns,
          }}
        />}
        sortMode="multiple"
        multiSortMeta={sortMeta}
        onSort={event => {
          const otherSortFields = (event.multiSortMeta || []).filter(
            sort => sort.field !== "groupKey" && sort.field !== "closeDateSort"
          );
          setSortMeta([
            { field: "groupKey", order: 1 },
            ...otherSortFields,
            { field: "closeDateSort", order: 1 }
          ]);
        }}
        paginatorDropdownAppendTo={'self'}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
        onRowClick={(event) => {
          const link = event.data.link;
          navigate(link, {
            relative: 'path'
          });
        }}
      >
        <Column
          header={t("list.type")}
          field={'type'}
          sortable
          key={'type'}
          body={(params) => {
            return iconForType(params.type)
          }}
        />
        <Column
          header={t("list.task_name")}
          field={'title'}
          sortable
          className="content-table-data"
          filter
          key={'name'}
          body={(params) => {
            return parse(params.title);
          }}
        />
        <Column
          header={t("list.course_name")}
          field={'course_name'}
          sortable
          filter
          filterMatchMode="contains"
          key={'course_name'}
        />
        {visibleColumns.includes(t(`list.${OPT_COLS.GROUP}`)) ?
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
        {visibleColumns.includes(t(`list.${OPT_COLS.STATUS}`)) ?
          (
            <Column
              header={t(`list.${(OPT_COLS.STATUS)}`)}
              field={'status'}
              sortable
              key={'status'}
              body={(params) => {
                let output = 'No status'
                switch (params.type) {
                  case 'assessment':
                    if (0 === params.status) {
                      output = t('list.status.incomplete');
                    } else {
                      output = t('list.status.complete');
                    }
                    break;
                  case 'project':
                    output = t('list.status.click_for_info');
                    break;
                  case 'bingo_game':
                    if (params.status < 0) {
                      output = params.status === -1 ? 
                        t('terms_lists.sufficient_msg') :
                        t('terms_lists.insufficient_msg');
                    } else {
                      output = `${params.status}%`;
                    }
                    break;
                  case 'submission':
                  case 'assignment':
                    output = `${params.status} submitted`;
                    break;
                  default:
                    output = `${params.status}%`;
                }
                return output;
              }}
            />
          ) : null
        }
        {visibleColumns.includes(t(`list.${OPT_COLS.START_DATE}`)) ?
          (
            <Column
              header={t(`list.${OPT_COLS.START_DATE}`)}
              field={OPT_COLS.START_DATE}
              sortable
              key={OPT_COLS.START_DATE}
              body={(params) => {
                return <span>{params.start_date ? formatZonedDateTime(params.start_date, DATETIME_MED) : ""}</span>;
              }}

            />
          ) : null
        }
        {visibleColumns.includes(t(`list.${OPT_COLS.NEXT_DATE}`)) ?
          (
            <Column
              header={t(`list.${OPT_COLS.NEXT_DATE}`)}
              field={OPT_COLS.NEXT_DATE}
              sortable
              key={OPT_COLS.NEXT_DATE}
              body={(params) => {
                return <span>{params.next_date ? formatZonedDateTime(params.next_date, DATETIME_MED) : ""}</span>;
              }}
            />
          ) : null
        }
        {visibleColumns.includes(t(`list.${OPT_COLS.CONSENT_LINK}`)) ?
          (
            <Column
              header={t(`list.${OPT_COLS.CONSENT_LINK}`)}
              field={'consent_link'}
              sortable
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
        {visibleColumns.includes(t(`list.${OPT_COLS.INSTRUCTOR_TASK}`)) ?
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