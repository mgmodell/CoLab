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

  return (
    <div>
      <h3>Student progress</h3>
      <p>
        {data.completion_percent}% complete ({data.completed_count} of{" "}
        {data.total_students} students)
      </p>
      <DataTable
        value={data.students}
        dataKey="id"
        emptyMessage="No enrolled students"
      >
        <Column field="name" header="Student" />
        <Column field="status" header="Status" />
        <Column field="progress" header="Progress" />
      </DataTable>
    </div>
  );
}
