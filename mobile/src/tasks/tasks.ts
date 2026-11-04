import { AuthClient } from "../auth/authClient";
import { ROUTES } from "../auth/routes";

/*
 * Mirrors the task shape built by home#task_list and rendered by the web
 * TaskList component (app/javascript/components/TaskList.tsx).
 */
export interface Task {
  id: number;
  type: string;
  name: string;
  course_name: string | null;
  group_name?: string | null;
  status?: number | string | null;
  next_date?: string | null;
  end_date?: string | null;
  link: string;
  instructor_task?: boolean;
}

export async function fetchTasks(client: AuthClient): Promise<Task[]> {
  const data = await client.authedGet(ROUTES.taskList);
  return Array.isArray(data?.tasks) ? data.tasks : [];
}

/** Deep link to the activity on the CoLab website. */
export function taskUrl(baseUrl: string, task: Task): string {
  const base = baseUrl.replace(/\/+$/, "");
  const link = (task.link ?? "").replace(/^\/+/, "");
  return `${base}/${link}`;
}

export const taskKey = (t: Task) => `${t.type}-${t.id}`;
