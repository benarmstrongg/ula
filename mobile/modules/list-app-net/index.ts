import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to ListAppNet.web.ts
// and on native platforms to ListAppNet.ts
import ListAppNetModule from './src/ListAppNetModule';

export function hello(): string {
  return ListAppNetModule.hello();
}

const emitter = new EventEmitter(ListAppNetModule ?? NativeModulesProxy.ListAppNet);

export function onLog(listener: (event: { msg: string }) => void): Subscription {
  return emitter.addListener<{ msg: string }>('log', listener);
}

emitter.addListener<{ msg: string }>('log', ({ msg }) => console.log(msg));

export function removeListener(sub: Subscription): void {
  emitter.removeSubscription(sub);
}