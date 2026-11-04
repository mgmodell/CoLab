import React, { useEffect, useState } from "react";
import {
  ActivityIndicator,
  Button,
  FlatList,
  Linking,
  StyleSheet,
  Text,
  TouchableOpacity,
  View
} from "react-native";
import { Task, taskKey, taskUrl } from "../tasks/tasks";

interface Props {
  baseUrl: string;
  loadTasks: () => Promise<Task[]>;
  onSignOut: () => void;
}

export default function TasksScreen({ baseUrl, loadTasks, onSignOut }: Props) {
  const [tasks, setTasks] = useState<Task[] | null>(null);
  const [failed, setFailed] = useState(false);
  const [selected, setSelected] = useState<Task | null>(null);

  const load = () => {
    setFailed(false);
    setTasks(null);
    loadTasks().then(setTasks, () => setFailed(true));
  };
  useEffect(load, []);

  if (selected) {
    const url = taskUrl(baseUrl, selected);
    return (
      <View style={styles.container} testID="task-detail">
        <Text style={styles.title}>{selected.name}</Text>
        {selected.course_name && <Text>{selected.course_name}</Text>}
        <Text style={styles.note}>
          Open this activity on the CoLab website to complete it.
        </Text>
        <Button
          title="Open in CoLab"
          testID="open-task"
          onPress={() => Linking.openURL(url)}
        />
        <Button title="Back" testID="task-back" onPress={() => setSelected(null)} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text testID="home" style={styles.title}>
        Welcome to CoLab
      </Text>
      {failed ? (
        <>
          <Text testID="tasks-error" style={styles.error}>
            Unable to load your tasks.
          </Text>
          <Button title="Retry" onPress={load} />
        </>
      ) : tasks === null ? (
        <ActivityIndicator testID="tasks-loading" />
      ) : (
        <FlatList
          testID="task-list"
          data={tasks}
          keyExtractor={taskKey}
          ListEmptyComponent={<Text testID="no-tasks">No tasks available.</Text>}
          renderItem={({ item }) => (
            <TouchableOpacity
              testID={`task-${taskKey(item)}`}
              style={styles.row}
              onPress={() => setSelected(item)}
            >
              <Text style={styles.name}>{item.name}</Text>
              {item.course_name && <Text>{item.course_name}</Text>}
            </TouchableOpacity>
          )}
        />
      )}
      <Button title="Sign out" onPress={onSignOut} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24 },
  title: { fontSize: 22, fontWeight: "600", marginBottom: 12 },
  note: { marginVertical: 12 },
  error: { color: "#b00020" },
  row: { paddingVertical: 12, borderBottomWidth: StyleSheet.hairlineWidth },
  name: { fontWeight: "600" }
});
