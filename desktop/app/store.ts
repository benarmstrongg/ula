"use client";

import React, { useEffect, useState } from "react";

type StoreSubscription<TValue> = (value: TValue) => void;
type StoreUnsubscribeHandler = () => void;

export class Store<T extends object> {
    private store: T;
    private subscriptions: Record<any, Set<StoreSubscription<any>>> = {};

    constructor(initialState: T) {
        this.store = new Proxy<T>(initialState, {
            get: (target: any, prop: any) => {
                return target[prop];
            },
            set: (target: any, prop: any, value: any) => {
                target[prop] = value;
                this.subscriptions[prop]?.forEach((cb) => cb(value));
                return true;
            },
        });
    }

    subscribe<
        TValue extends TProp extends keyof T ? T[TProp] : any,
        TProp extends keyof T = any,
    >(
        prop: TProp | (string & {}),
        onChange: StoreSubscription<TValue>,
    ): StoreUnsubscribeHandler {
        if (!this.subscriptions[prop]) {
            this.subscriptions[prop] = new Set();
        }
        this.subscriptions[prop].add(onChange);
        return () => {
            this.subscriptions[prop].delete(onChange);
        };
    }

    merge(obj: T) {
        for (const key in obj) {
            this.store[key] = obj[key];
        }
    }

    get<
        TValue extends TProp extends keyof T ? T[TProp] : any,
        TProp extends keyof T = any,
    >(prop: TProp | (string & {})): TValue {
        return this.store[prop as keyof T] as TValue;
    }

    set<
        TValue extends TProp extends keyof T ? T[TProp] : any,
        TProp extends keyof T = any,
    >(prop: TProp | (string & {}), value: TValue) {
        this.store[prop as keyof T] = value;
    }
}

export function createStore<T extends object>(initialState: T): Store<T> {
    return new Store(initialState);
}

export function useStoreValue<
    TValue extends TProp extends keyof TStore ? TStore[TProp] : any,
    TStore extends object = any,
    TProp extends keyof TStore = any,
>(
    store: Store<TStore>,
    prop: TProp | (string & {}),
): [TValue, (value: React.SetStateAction<TValue>) => TValue] {
    const [value, setLocalValue] = useState(store.get<TValue>(prop));
    function setValue(val: React.SetStateAction<TValue>): TValue {
        const nextValue =
            typeof val === "function"
                ? (val as (prevValue: TValue) => TValue)(value)
                : val;
        store.set(prop, nextValue);
        setLocalValue(nextValue);
        return nextValue;
    }
    useEffect(
        () => store.subscribe<TValue>(prop, (val) => setLocalValue(val)),
        [],
    );
    return [value, setValue];
}
