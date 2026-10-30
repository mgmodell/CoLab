import React, { useEffect, useState } from "react";
import { Button, SafeAreaView, Text, View } from "react-native";
import { authClient, signInWithGoogle } from "./src/auth/platform";
import { AuthState } from "./src/auth/authClient";
import LoginScreen from "./src/screens/LoginScreen";

export default function App() {
  const [state, setState] = useState<AuthState>(authClient.getState());

  useEffect(() => {
    const unsubscribe = authClient.subscribe(setState);
    authClient.restore();
    return unsubscribe;
  }, []);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      {state.status === "signedIn" ? (
        <View style={{ flex: 1, justifyContent: "center", padding: 24 }}>
          <Text testID="home">Welcome to CoLab</Text>
          <Button title="Sign out" onPress={() => authClient.signOut()} />
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
