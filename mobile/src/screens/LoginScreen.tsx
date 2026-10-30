import React, { useState } from "react";
import {
  ActivityIndicator,
  Button,
  StyleSheet,
  Text,
  TextInput,
  View
} from "react-native";
import { AuthState } from "../auth/authClient";

interface Props {
  state: AuthState;
  onSignIn: (email: string, password: string) => void;
  onGoogleSignIn: () => void;
}

const messages: { [key: string]: string } = {
  invalid_credentials: "Invalid email or password.",
  missing_credentials: "Enter your email and password.",
  google_failed: "Google sign-in failed. Try again.",
  network: "Unable to reach the server. Try again."
};

export default function LoginScreen({ state, onSignIn, onGoogleSignIn }: Props) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const loading = state.status === "loading";

  return (
    <View style={styles.container}>
      <Text style={styles.title}>CoLab</Text>
      {state.status === "expired" && (
        <Text testID="session-expired">
          Your session has expired. Please sign in again.
        </Text>
      )}
      {state.status === "error" && (
        <Text testID="login-error" style={styles.error}>
          {messages[state.message ?? "network"] ?? messages.network}
        </Text>
      )}
      <TextInput
        testID="email"
        style={styles.input}
        placeholder="Email"
        autoCapitalize="none"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        testID="password"
        style={styles.input}
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      {loading ? (
        <ActivityIndicator testID="loading" />
      ) : (
        <Button
          testID="sign-in"
          title="Sign in"
          onPress={() => onSignIn(email, password)}
        />
      )}
      {!loading && (
        <Button
          testID="google-sign-in"
          title="Continue with Google"
          onPress={onGoogleSignIn}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", padding: 24, gap: 12 },
  title: { fontSize: 28, fontWeight: "bold", textAlign: "center" },
  input: { borderWidth: 1, borderColor: "#999", borderRadius: 4, padding: 10 },
  error: { color: "#b00020" }
});
