import React, { useEffect, useState } from "react";
import { SafeAreaView } from "react-native";
import { apiUrl, authClient, signInWithGoogle } from "./src/auth/platform";
import { AuthState } from "./src/auth/authClient";
import { pushClient, registerForPush } from "./src/push/platform";
import LoginScreen from "./src/screens/LoginScreen";
import TasksScreen from "./src/screens/TasksScreen";
import { fetchTasks } from "./src/tasks/tasks";

export default function App() {
  const [state, setState] = useState<AuthState>(authClient.getState());

  useEffect(() => {
    const unsubscribe = authClient.subscribe(setState);
    authClient.restore();
    return unsubscribe;
  }, []);

  useEffect(() => {
    if (state.status === "signedIn") {
      registerForPush().catch(e => console.warn("[push] registration failed", e));
    }
  }, [state.status]);

  const signOut = async () => {
    await pushClient.unregister();
    await authClient.signOut();
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      {state.status === "signedIn" ? (
        <TasksScreen
          baseUrl={apiUrl}
          loadTasks={() => fetchTasks()}
          onSignOut={() => authClient.signOut()}
        />
      ) : (
        <LoginScreen
          state={state}
          onSignIn={(e, p) => authClient.signIn(e, p)}
          onGoogleSignIn={signInWithGoogle}
        />
      )}
    </SafeAreaView>
  );
}
