import React, { useEffect, useState } from "react";
import axios from "axios";

import { Column } from "primereact/column";
import { DataTable } from "primereact/datatable";
import { Skeleton } from "primereact/skeleton";

import { useTypedSelector } from "./infrastructure/AppReducers";

type Props = {
  activityId: number | string | null | undefined;
  activityType: string;
};

export default function StudentProgress({ activityId, activityType }: Props) {
  const endpoints = useTypedSelector(state => state.context.endpoints.home);
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const [data, setData] = useState<any>();
  const [expandedRows, setExpandedRows] = useState<any>();

  useEffect(() => {
    if (!endpointsLoaded || !activityId || !endpoints?.activityProgressUrl) return;

    setData(undefined);
    axios
      .get(`${endpoints.activityProgressUrl}/${activityType}/${activityId}.json`)
      .then(response => setData(response.data))
      .catch(() => setData({ students: [], error: true }));
  }, [activityId, activityType, endpoints?.activityProgressUrl, endpointsLoaded]);

  if (!activityId) return null;
  if (!data) return <Skeleton className="mb-2" />;
  if (data.error) return <p>Unable to load student progress.</p>;

  const formatAgreement = (value: number | null | undefined) =>
    value == null ? "—" : `${value}%`;
  const formatTrend = (slope: number | null | undefined) =>
    slope == null
      ? "—"
      : `${slope > 0 ? "+" : ""}${slope.toFixed(2)} percentage points/week`;
  const metricBody = (metric: any) => (
    <div>
      <div>Project: {formatAgreement(metric?.agreement)}</div>
      <div>This week: {formatAgreement(metric?.week_agreement)}</div>
      <small>Trend: {formatTrend(metric?.trend)}</small>
    </div>
  );
  const overallMetricBody = (row: any) =>
    metricBody({
      agreement: row.overall_agreement,
      week_agreement: row.week_overall_agreement,
      trend: row.overall_trend
    });

  const groupDetails = (group: any) => {
    const studentProgress = new Map(
      data.students.map((student: any) => [student.id, student])
    );

    return (
      <DataTable value={group.members} dataKey="id" emptyMessage="No group members">
        <Column field="name" header="Student" />
        <Column
          header="Status"
          body={(member: any) => studentProgress.get(member.id)?.status ?? "Incomplete"}
        />
        <Column
          header="Progress"
          body={(member: any) => studentProgress.get(member.id)?.progress ?? "No check-in"}
        />
        <Column header="Overall agreement" body={overallMetricBody} />
        {group.behaviors.map((behavior: any) => (
          <Column
            key={behavior.factor_id}
            header={behavior.name}
            body={(member: any) =>
              metricBody(
                member.behaviors.find(
                  (item: any) => item.factor_id === behavior.factor_id
                )
              )
            }
          />
        ))}
        <Column
          header="Highest contribution this week"
          body={(member: any) => member.week_highest_contribution?.name ?? "—"}
        />
        <Column
          header="Highest contribution over project"
          body={(member: any) => member.highest_contribution?.name ?? "—"}
        />
      </DataTable>
    );
  };

  const hasGroupReports = activityType === "project" && data.groups?.length > 0;

  return (
    <div>
      <h3>Student progress</h3>
      <p>
        {data.completion_percent}% complete ({data.completed_count} of{" "}
        {data.total_students} students)
      </p>
      {hasGroupReports ? (
        <DataTable
          value={data.groups}
          dataKey="id"
          expandedRows={expandedRows}
          onRowToggle={event => setExpandedRows(event.data)}
          rowExpansionTemplate={groupDetails}
          emptyMessage="No project groups"
        >
          <Column expander />
          <Column field="name" header="Group" />
          <Column header="Overall agreement" body={overallMetricBody} />
          {data.groups[0].behaviors.map((behavior: any) => (
            <Column
              key={behavior.factor_id}
              header={behavior.name}
              body={(group: any) =>
                metricBody(
                  group.behaviors.find(
                    (item: any) => item.factor_id === behavior.factor_id
                  )
                )
              }
            />
          ))}
        </DataTable>
      ) : (
        <DataTable
          value={data.students}
          dataKey="id"
          emptyMessage="No enrolled students"
        >
          <Column field="name" header="Student" />
          <Column field="status" header="Status" />
          <Column field="progress" header="Progress" />
        </DataTable>
      )}
    </div>
  );
}
