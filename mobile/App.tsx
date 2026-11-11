import React, { useEffect, useState } from "react";
import { Button, SafeAreaView, Text, View } from "react-native";
import { authClient, signInWithGoogle } from "./src/auth/platform";
import { AuthState } from "./src/auth/authClient";
import { pushClient, registerForPush } from "./src/push/platform";
import LoginScreen from "./src/screens/LoginScreen";

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
        <View style={{ flex: 1, justifyContent: "center", padding: 24 }}>
          <Text testID="home">Welcome to CoLab</Text>
          <Button title="Sign out" onPress={signOut} />
        </View>
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
