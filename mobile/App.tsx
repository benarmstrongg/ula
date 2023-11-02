import { StyleSheet, Text, View } from 'react-native';
import { onLog, hello, removeListener } from './modules/list-app-net';
import { useEffect } from 'react';



export default function App() {
  return (
    <View style={styles.container}>
      <Text>{hello()}o</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
