import React, { useState, useEffect, useMemo } from "react";
import axios from "axios";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import { IUser } from '../infrastructure/ProfileSlice';
import { useDispatch } from "react-redux";
import { useTranslation } from "react-i18next";

import DiversityScore from "../DiversityScore";

import { SortDirection } from "react-virtualized";

import { RadioButton } from "primereact/radiobutton";
import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { Panel } from "primereact/panel";
import { Toolbar } from "primereact/toolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Tooltip } from "primereact/tooltip";
import { Dialog } from "primereact/dialog";
import { ConfirmDialog } from "primereact/confirmdialog";
import { InputNumber } from "primereact/inputnumber";
import { Dropdown } from "primereact/dropdown";

type Props = {
  projectId: number;
  groupsUrl: string;
  suggestGroupsUrl: string;
  diversityCheckUrl: string;
  diversityRescoreGroup: string;
  diversityRescoreGroups: string;
};

export default function ProjectGroups(props: Props) {
  const category = "projects";
  const { t } = useTranslation(category);

  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [message, setMessage] = useState("");
  const [filterText, setFilterText] = useState("");
  const [targetGroupType, setTargetGroupType] = useState<'count' | 'size'>('size');
  const [targetGroupTypeValue, setTargetGroupTypeValue] = useState(4);
  const [sortBy, setSortBy] = useState("last_name");
  const [sortDirection, setSortDirection] = useState(SortDirection.DESC);
  const [groupsRaw, setGroupsRaw] = useState({});
  const [studentsRaw, setStudentsRaw] = useState<Record<number, IUser>>({});
  const [suggestedGroupsRaw, setSuggestedGroupsRaw] = useState(null);
  const [suggestedStudentsRaw, setSuggestedStudentsRaw] = useState(null);
  const [suggestedGroups, setSuggestedGroups] = useState([]);
  const [suggestionSummary, setSuggestionSummary] = useState(null);

  // Modal Dialog UI States
  const [showConfigDialog, setShowConfigDialog] = useState(false);
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);

  const dispatch = useDispatch();

  // Derived state: groups array directly from dict
  const groups = Object.values(groupsRaw);

  // Derived state: students array computed with filtering & sorting
  const students = useMemo(() => {
    let list = Object.values(studentsRaw);

    if (filterText) {
      list = list.filter(student =>
        (student.first_name + " " + student.last_name)
          .toUpperCase()
          .includes(filterText.toUpperCase())
      );
    }

    const directionMultiplier = sortDirection === SortDirection.ASC ? 1 : -1;
    return [...list].sort((studentOne, studentTwo) => {
      const valueOne = studentOne[sortBy] || "";
      const valueTwo = studentTwo[sortBy] || "";
      if (valueOne < valueTwo) return -1 * directionMultiplier;
      if (valueOne > valueTwo) return 1 * directionMultiplier;
      return 0;
    });
  }, [studentsRaw, filterText, sortBy, sortDirection]);

  useEffect(() => {
    getGroups();
  }, []);

  const setGroup = (student_id: number, group_id: number) => {
    setDirty(true);
    setStudentsRaw(prev => ({
      ...prev,
      [student_id]: {
        ...prev[student_id],
        group_id: group_id
      }
    }));
  };

  const setGroupName = (event: React.ChangeEvent<HTMLInputElement>, group_id: number) => {
    const newName = event.target.value;
    setDirty(true);
    setGroupsRaw(prev => ({
      ...prev,
      [group_id]: {
        ...prev[group_id],
        name: newName
      }
    }));
  };

  const addGroup = () => {
    setGroupsRaw(prev => {
      const group_ids = Object.keys(prev).map(Number);
      group_ids.push(0);
      const min_id = Math.min(...group_ids) - 1;

      return {
        ...prev,
        [min_id]: {
          name: "Team " + min_id,
          id: min_id,
          diversity: 0
        }
      };
    });
    setDirty(true);
  };

  const removeGroup = (event, group_id: number) => {
    setDirty(true);
    setStudentsRaw(prev => {
      const updated = { ...prev };
      Object.values(updated).forEach(student => {
        if (student.group_id === group_id) {
          updated[student.id] = { ...student, group_id: null };
        }
      });
      return updated;
    });

    setGroupsRaw(prev => {
      const updated = { ...prev };
      delete updated[group_id];
      return updated;
    });
  };

  const getGroups = () => {
    const url = props.groupsUrl + props.projectId + ".json";
    setWorking(true);
    dispatch(startTask());
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setWorking(false);
        setSuggestedGroupsRaw(null);
        setSuggestedStudentsRaw(null);
        setSuggestedGroups([]);
        setSuggestionSummary(null);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const rescoreGroup = (event, group_id) => {
    setWorking(true);
    const url = props.diversityRescoreGroup + props.projectId + ".json";
    dispatch(startTask());
    axios
      .post(url, { group_id: group_id })
      .then(response => {
        const data = response.data;
        setWorking(false);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const recalcDiversity = () => {
    setWorking(true);
    const url = props.diversityRescoreGroups + props.projectId + ".json";
    dispatch(startTask());
    axios
      .post(url, {})
      .then(response => {
        const data = response.data;
        setWorking(false);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const saveGroups = (nextGroups = groupsRaw, nextStudents = studentsRaw) => {
    setWorking(true);
    setMessage("Saving...");

    const url = props.groupsUrl + props.projectId + ".json";
    dispatch(startTask());
    axios
      .patch(url, {
        groups: nextGroups,
        students: nextStudents
      })
      .then(response => {
        const data = response.data;
        setWorking(false);
        setDirty(false);
        setSuggestedGroupsRaw(null);
        setSuggestedStudentsRaw(null);
        setSuggestedGroups([]);
        setSuggestionSummary(null);
        setGroupsRaw(data.groups);
        setStudentsRaw(data.students);
        setMessage(data.message == null ? "" : data.message);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const suggestGroups = () => {
    if (working) return;

    setWorking(true);
    setMessage( t( 'groups.generating_recommendations') );
    setShowConfigDialog(false); // Close setup dialog

    const url = props.suggestGroupsUrl + props.projectId + ".json";
    dispatch(startTask());
    const payload = { };
    payload[ targetGroupType === 'size' ? 'target_group_size' : 'target_group_count' ] = targetGroupTypeValue;
    axios
      .post(url, payload)
      .then(response => {
        const data = response.data;
        setWorking(false);
        setSuggestedGroupsRaw(data.groups);
        setSuggestedStudentsRaw(data.students);
        setSuggestedGroups(Object.values(data.groups));
        setSuggestionSummary(data.summary);
        setMessage("");
        setShowConfirmDialog(true); // Open scrollable preview dialog
      })
      .catch(error => {
        console.log("error", error);
        setWorking(false);
        setMessage("Unable to generate recommendations");
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const rejectSuggestedGroups = () => {
    setSuggestedGroupsRaw(null);
    setSuggestedStudentsRaw(null);
    setSuggestedGroups([]);
    setSuggestionSummary(null);
    setMessage("");
    setShowConfirmDialog(false);
  };

  const acceptSuggestedGroups = () => {
    if (null == suggestedGroupsRaw || null == suggestedStudentsRaw) return;
    setShowConfirmDialog(false);
    saveGroups(suggestedGroupsRaw, suggestedStudentsRaw);
  };

  const suggestedMembers = groupId => {
    if (null == suggestedStudentsRaw) return [];
    return Object.values(suggestedStudentsRaw).filter(student => student.group_id == groupId);
  };

  // Config Dialog Footer Actions
  const configDialogFooter = (
    <div>
      <Button label="Cancel" icon="pi pi-times" onClick={() => setShowConfigDialog(false)} className="p-button-text" />
      <Button label="Generate" icon="pi pi-sparkles" onClick={suggestGroups} autoFocus />
    </div>
  );

  // Recommendations preview content injection for ConfirmDialog
  const recommendationsPreviewTemplate = () => (
    <div style={{ maxHeight: "60vh", overflowY: "auto", paddingRight: "10px" }}>
      {0 < groups.length ? (
        <p id="recommended-groups-warning" className="p-error mb-3">
          {t( 'groups.replace_groups_warning' )}
        </p>
      ) : null}
      <dl id="recommended-groups-summary" className="mb-4" style={{ display: 'grid', gridTemplateColumns: 'max-content 1fr', gap: '0.5rem 1rem' }}>
        <dt><strong>{t( 'groups.number_of_groups' )}</strong></dt>
        <dd>{suggestedGroups.length ?? 0}</dd>
        <dt><strong>{t( 'groups.diversity_score_stdev' )}</strong></dt>
        <dd>{suggestionSummary?.diversity_score_standard_deviation ?? 0}</dd>
        <dt><strong>{t( 'groups.average_diversity_score' )}</strong></dt>
        <dd>{suggestionSummary?.average_diversity_score ?? 0}</dd>
        <dt><strong>{t( 'groups.average_faultline_strength' )}</strong></dt>
        <dd>{suggestionSummary?.average_faultline_strength ?? 0}</dd>
        <dt><strong>{t( 'groups.max_faultline_strength' )}</strong></dt>
        <dd>{suggestionSummary?.max_faultline_strength ?? 0}</dd>
      </dl>
      {suggestedGroups.map(group => (
        <Panel
          key={`suggested-${group.id}`}
          id={`recommended-group-${group.id}`}
          header={group.name}
          className="mb-3 recommended-group-card"
        >
          <div>{t( 'groups.proposed_members' )}: {group.member_count}</div>
          <div>{t( 'groups.proposed_diversity_score' )}: {group.diversity}</div>
          <div>{t( 'groups.proposed_faultline_strength' )}: {group.faultline}</div>
          <ul className="mt-2">
            {suggestedMembers(group.id).map(student => (
              <li key={`suggested-member-${group.id}-${student.id}`}>
                {student.first_name} {student.last_name}
              </li>
            ))}
          </ul>
        </Panel>
      ))}
    </div>
  );

  return (
    <Panel>
      {/* 1. Configuration Dialog to ask for size/count */}
      <Dialog 
        header={t('groups.recommend_groups')} 
        visible={showConfigDialog} 
        style={{ width: '350px' }} 
        footer={configDialogFooter} 
        onHide={() => setShowConfigDialog(false)}
      >
        <div className="flex flex-column gap-2 mt-2">
          <label htmlFor="target_group_type">{t('groups.target_type_lbl')}</label>
          <Dropdown
            id='target_group_type'
            value={targetGroupType}
            onChange={event => setTargetGroupType(event.value)}
            options={[
              { label: t('groups.target_group_size_lbl'), value: 'size' },
              { label: t('groups.target_group_count_lbl'), value: 'count' },
            ]}
          />:
          <span className="p-input-icon-left w-full">
            <i className="pi pi-users" />
            <InputNumber
              id="target_group_count"
              className="w-full"
              placeholder={t('groups.target_group_count_plchldr')}
              onChange={event => setTargetGroupTypeValue(event.value || 0)}
              value={targetGroupTypeValue}
              disabled={working}
            />
          </span>
        </div>
      </Dialog>

      {/* 2. Scrollable Preview ConfirmDialog */}
      <ConfirmDialog
        visible={showConfirmDialog}
        onHide={() => rejectSuggestedGroups()}
        message={recommendationsPreviewTemplate}
        header={t('groups.recommended_groups')}
        icon="pi pi-exclamation-triangle"
        acceptLabel={t('groups.accept_suggested_groups')}
        rejectLabel={t('groups.reject_suggested_groups')}
        accept={acceptSuggestedGroups}
        reject={rejectSuggestedGroups}
        style={{ width: '50vw' }}
        breakpoints={{ '960px': '75vw', '641px': '95vw' }}
      />

      <DataTable
        value={students}
        resizableColumns
        reorderableColumns
        tableStyle={{ width: "100%" }}
        dataKey="id"
        scrollable
        className="p-datatable-striped p-datatable-gridlines"
        header={
          <Toolbar
            end={
              <div className="flex align-items-center gap-3 flex-wrap">
                <span className="p-input-icon-left">
                  <i className="pi pi-search" />
                  <InputText
                    placeholder={t( 'groups.search_students' )}
                    onChange={e => setFilterText(e.target.value)}
                    value={filterText}
                  />
                </span>
                <span>
                  {t( 'groups.students_shown', { count: students.length, total: Object.values(studentsRaw).length } )}
                </span>
                {dirty ? (
                  <Button onClick={() => saveGroups()} icon="pi pi-save">
                    {t( 'groups.save_groups')}
                  </Button>
                ) : null}
                <span>{message}</span>
                <Button onClick={() => setShowConfigDialog(true)} icon="pi pi-sparkles" disabled={working}>
                  {t( 'groups.recommend_groups')}
                </Button>
                <Button onClick={recalcDiversity} icon="pi pi-calculator">
                  {t( 'groups.recalculate_diversity')}
                </Button>
                <Button onClick={addGroup} icon="pi pi-users">
                  {t( 'groups.add_group')}
                </Button>
              </div>
            }
          />
        }
      >
        <Column header="Given Name" field="first_name" sortable filter key="first_name" />
        <Column header="Family Name" field="last_name" sortable filter key="last_name" />
        {groups.map(group => (
          <Column
            header={() => (
              <>
                <InputText
                  value={group.name}
                  onChange={event => setGroupName(event, group.id)}
                  id={`g_${group.id}`}
                  itemID={`g_${group.id}`}
                />
                <span
                  onClick={() => {
                    setSortBy("group_id");
                    setSortDirection(prev =>
                      prev === SortDirection.ASC ? SortDirection.DESC : SortDirection.ASC
                    );
                  }}
                >
                  <i className="pi pi-sort-alt" />
                </span>
                {group.id < 0 ? (
                  <Button
                    onClick={event => removeGroup(event, group.id)}
                    icon="pi pi-trash"
                    rounded
                    size="small"
                  />
                ) : null}
                <DiversityScore
                  groupId={group.id}
                  parentDirty={dirty}
                  documented={groupsRaw[group.id]?.diversity || 0}
                  scoreReviewUrl={props.diversityCheckUrl}
                  rescoreGroup={rescoreGroup}
                  students={studentsRaw}
                />
                <Tooltip target='faultline-strength' content={t( 'faultline_strength_explained' )} />
                <div className="faultline-strength" id='faultline-strength'>
                  {t( 'faultline_strength' )}: {groupsRaw[group.id]?.faultline || 0}
                </div>
              </>
            )}
            field={"id"}
            columnKey={group.id}
            key={group.id}
            body={rowData => (
              <RadioButton
                onChange={() => setGroup(rowData.id, group.id)}
                id={"user_group_" + rowData.id + "_" + group.id}
                itemID={"user_group_" + rowData.id + "_" + group.id}
                inputId={"user_group_" + rowData.id + "_" + group.id}
                checked={group.id === rowData.group_id}
              />
            )}
          />
        ))}
        <Column
          header="No Group"
          field="id"
          filter
          key="0"
          body={rowData => (
            <RadioButton
              id={"stu-" + rowData.id}
              onChange={() => setGroup(rowData.id, null)}
              checked={null == rowData.group_id}
            />
          )}
        />
      </DataTable>
    </Panel>
  );
}
