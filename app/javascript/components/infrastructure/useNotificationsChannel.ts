import { useEffect, useRef } from "react";
import { createConsumer, Consumer, Subscription } from "@rails/actioncable";
import { Cookies } from "react-cookie-consent";
import { useDispatch } from "react-redux";
import { addMessage, Priorities } from "./StatusSlice";

const SAVED_CREDS_KEY = "colab_authHeaders";

function getAuthHeaders(): Record<string, string> | null {
  let raw: string | null = null;
  if (navigator.cookieEnabled) {
    raw = Cookies.get(SAVED_CREDS_KEY) ?? null;
  } else {
    raw = localStorage.getItem(SAVED_CREDS_KEY);
  }
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

interface NotificationMessage {
  message: string;
  priority: string;
}

function toPriority(priority: string): Priorities {
  switch (priority) {
    case "error":
      return Priorities.ERROR;
    case "warning":
      return Priorities.WARNING;
    default:
      return Priorities.INFO;
  }
}

/**
 * Opens a NotificationsChannel WebSocket subscription for the current user.
 * Any server-broadcast notification is dispatched to the Redux store and
 * displayed by AppStatusBar's Toast.
 *
 * Pass a truthy `userId` only when the user is authenticated; the hook
 * skips setup when userId is absent.
 */
export default function useNotificationsChannel(
  userId: number | null | undefined
): void {
  const dispatch = useDispatch();
  const consumerRef = useRef<Consumer | null>(null);
  const subscriptionRef = useRef<Subscription | null>(null);

  useEffect(() => {
    if (!userId || userId < 0) return;

    const headers = getAuthHeaders();
    if (!headers) return;

    const uid = headers["uid"];
    const accessToken = headers["access-token"];
    const client = headers["client"];
    if (!uid || !accessToken || !client) return;

    const url =
      `/cable?uid=${encodeURIComponent(uid)}` +
      `&access-token=${encodeURIComponent(accessToken)}` +
      `&client=${encodeURIComponent(client)}`;

    const consumer: Consumer = createConsumer(url);
    consumerRef.current = consumer;

    subscriptionRef.current = consumer.subscriptions.create(
      { channel: "NotificationsChannel" },
      {
        received(data: NotificationMessage) {
          dispatch(
            addMessage(data.message, new Date(), toPriority(data.priority))
          );
        }
      }
    );

    return () => {
      subscriptionRef.current?.unsubscribe();
      consumer.disconnect();
      consumerRef.current = null;
      subscriptionRef.current = null;
    };
  }, [userId]);
}
