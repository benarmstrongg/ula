"use client";

import { invoke } from "@tauri-apps/api";
import { UlList } from "../types";
import { useEffect, useState } from "react";
import { List } from "../common/components/list";
import { Spinner } from "../common/components/spinner";
import { LIST_STORE } from "../common/stores";

export default function ListsPage() {
    const [lists, setLists] = useState<UlList[]>();

    useEffect(() => {
        invoke<UlList[]>("load").then((lists) => {
            LIST_STORE.merge(
                lists.reduce(
                    (dict, list) => ({ ...dict, [list.id]: list }),
                    {},
                ),
            );
            setLists(lists);
        });
    }, []);

    if (!lists) {
        return <Spinner />;
    }

    return (
        <>
            {lists.map((list) => (
                <List key={list.id} id={list.id} />
            ))}
        </>
    );
}
