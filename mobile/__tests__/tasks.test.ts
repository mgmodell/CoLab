import { AuthClient, Http, SAVED_CREDS_KEY, Storage } from "../src/auth/authClient";
import { ROUTES } from "../src/auth/routes";
import { fetchTasks, taskUrl } from "../src/tasks/tasks";

const storage: Storage = {
  get: async k =>
    k === SAVED_CREDS_KEY ? JSON.stringify({ "access-token": "old" }) : null,
  set: async () => {},
  remove: async () => {}
};

describe("tasks", () => {
  it("fetches tasks with saved auth headers", async () => {
    const seen: any[] = [];
    const http: Http = {
      request: async o => {
        seen.push(o);
        return {
          status: 200,
          headers: {},
          data: { tasks: [{ id: 1, type: "assessment", name: "A", link: "x/1" }] }
        };
      }
    };
    const tasks = await fetchTasks(new AuthClient(http, storage));
    expect(tasks).toHaveLength(1);
    expect(seen[0].url).toBe(ROUTES.taskList);
    expect(seen[0].headers["access-token"]).toBe("old");
  });

  it("returns an empty list when no tasks are present", async () => {
    const http: Http = {
      request: async () => ({ status: 200, headers: {}, data: {} })
    };
    expect(await fetchTasks(new AuthClient(http, storage))).toEqual([]);
  });

  it("builds a deep link to the website", () => {
    const t = { id: 1, type: "assessment", name: "A", course_name: null, link: "/project/checkin/3" };
    expect(taskUrl("https://colab.online/", t)).toBe(
      "https://colab.online/project/checkin/3"
    );
  });
});
