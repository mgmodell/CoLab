import { useEffect, useRef } from "react";
import { createConsumer, Consumer, Subscription } from "@rails/actioncable";
import { Cookies } from "react-cookie-consent";

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

export interface InstallmentChannelMessage {
  event: "installment_saved";
  user_id: number;
  user_name: string;
  assessment_id: number;
  group_id: number;
}

/**
 * Subscribe to InstallmentChannel for the given assessment+group.
 * Calls `onMessage` whenever a group member saves their installment.
 * The subscription is torn down when the component unmounts or when
 * assessmentId/groupId change.
 */
export default function useInstallmentChannel(
  assessmentId: number | null | undefined,
  groupId: number | null | undefined,
  onMessage: (msg: InstallmentChannelMessage) => void
): void {
  const consumerRef = useRef<Consumer | null>(null);
  const subscriptionRef = useRef<Subscription | null>(null);
  // Keep a stable ref to onMessage so the effect doesn't need to re-subscribe
  // when the caller's inline callback changes identity on every render.
  const onMessageRef = useRef(onMessage);
  onMessageRef.current = onMessage;

  useEffect(() => {
    if (!assessmentId || !groupId) return;

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
      {
        channel: "InstallmentChannel",
        assessment_id: assessmentId,
        group_id: groupId
      },
      {
        received(data: InstallmentChannelMessage) {
          onMessageRef.current(data);
        }
      }
    );

    return () => {
      subscriptionRef.current?.unsubscribe();
      consumer.disconnect();
      consumerRef.current = null;
      subscriptionRef.current = null;
    };
  }, [assessmentId, groupId]);
}
