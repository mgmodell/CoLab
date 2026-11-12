import { StyleSheet } from "react-native";

/** Shared styles for the app's screens. */
export const styles = StyleSheet.create({
  container: { flex: 1, padding: 24 },
  title: { fontSize: 22, fontWeight: "600", marginBottom: 12 },
  note: { marginVertical: 12 },
  error: { color: "#b00020" },
  row: { paddingVertical: 12, borderBottomWidth: StyleSheet.hairlineWidth },
  name: { fontWeight: "600" }
});
