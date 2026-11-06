import axios from "axios";
import { SAVED_CREDS_KEY, Storage } from "../src/auth/authClient";
import {
  appendAuthHeaders,
  storeRetrievedCredentials
} from "../src/auth/interceptors";
import { ROUTES } from "../src/auth/routes";
import { fetchTasks, taskUrl } from "../src/tasks/tasks";

const memStorage = (init: { [k: string]: string } = {}): Storage => {
  const m = { ...init };
  return {
    get: async k => m[k] ?? null,
    set: async (k, v) => {
      m[k] = v;
    },
    remove: async k => {
      delete m[k];
    }
  };
};

describe("auth interceptors", () => {
  it("appends saved headers to requests", async () => {
    const s = memStorage({
      [SAVED_CREDS_KEY]: JSON.stringify({ "access-token": "old", uid: "u" })
    });
    const cfg = await appendAuthHeaders(s)({ headers: {} });
    expect(cfg.headers["access-token"]).toBe("old");
    expect(cfg.headers.uid).toBe("u");
  });

  it("stores rotated headers from responses", async () => {
    const s = memStorage();
    await storeRetrievedCredentials(s)({ headers: { "access-token": "new" } });
    expect(JSON.parse((await s.get(SAVED_CREDS_KEY))!)["access-token"]).toBe(
      "new"
    );
  });
});

jest.mock("axios", () => ({ __esModule: true, default: { get: jest.fn() } }));
const mockGet = axios.get as jest.Mock;

describe("tasks", () => {
  it("gets the task list url from the endpoints map", async () => {
    const urls: string[] = [];
    mockGet.mockImplementation(async (url: string) => {
      urls.push(url);
      return {
        data:
          url === ROUTES.endpoints
            ? { endpoints: { home: { taskListUrl: "/api-backend/task_list" } } }
            : { tasks: [{ id: 1, type: "assessment", name: "A", link: "x/1" }] }
      };
    });
    expect(await fetchTasks()).toHaveLength(1);
    expect(urls).toEqual([ROUTES.endpoints, "/api-backend/task_list.json"]);
  });

  it("returns an empty list when no tasks are present", async () => {
    mockGet.mockImplementation(async (url: string) => ({
      data:
        url === ROUTES.endpoints
          ? { endpoints: { home: { taskListUrl: "/t" } } }
          : {}
    }));
    expect(await fetchTasks()).toEqual([]);
  });

  it("builds a deep link to the website", () => {
    const t = { id: 1, type: "assessment", name: "A", course_name: null, link: "/project/checkin/3" };
    expect(taskUrl("https://colab.online/", t)).toBe(
      "https://colab.online/project/checkin/3"
    );
  });
});
