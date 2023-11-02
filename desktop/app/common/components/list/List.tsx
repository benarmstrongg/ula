"use client";

import type { UlList, UlListItem } from "@/app/types";
import { generateId } from "@/app/util";
import { useStoreValue } from "@/app/store";
import {
    DndContext,
    DragEndEvent,
    PointerSensor,
    TouchSensor,
    useSensor,
    useSensors,
} from "@dnd-kit/core";
import {
    SortableContext,
    arrayMove,
    verticalListSortingStrategy,
} from "@dnd-kit/sortable";
import { invoke } from "@tauri-apps/api";
import { useState } from "react";
import { ListItem } from "./ListItem";
import { AddItemButton } from "./AddItemButton";
import { Icon } from "../icon";
import { LIST_STORE } from "../../stores/list.store";

type ListProps = {
    id: string;
};

export function List({ id }: ListProps) {
    const [list, setList] = useStoreValue(LIST_STORE, id);
    const [isFocusTrapped, setIsFocusTrapped] = useState(false);
    const [isLatestChangeSaved, setIsLatestChangeSaved] = useState(true);

    const sensors = useSensors(
        useSensor(PointerSensor, {
            activationConstraint: { distance: 2 },
        }),
        useSensor(TouchSensor),
        // useSensor(KeyboardSensor, {
        //     coordinateGetter: sortableKeyboardCoordinates,

        // }),
    );

    function updateList(cb: (list: UlList) => UlList) {
        const nextList = setList(cb);
        save(nextList);
        setIsLatestChangeSaved(false);
    }

    function addItem() {
        updateList((list) => ({
            ...list,
            items: list.items.concat({
                id: generateId(),
                content: "",
                isCompleted: false,
            }),
        }));
    }

    function removeItem(itemId: string) {
        updateList((list) => ({
            ...list,
            items: list.items.filter((item) => item.id !== itemId),
        }));
    }

    function toggleCompleted(item: UlListItem) {
        updateList((list) => {
            const index = list.items.indexOf(item);
            item.isCompleted = !item.isCompleted;
            return {
                ...list,
                items: list.items.with(index, item),
            };
        });
    }

    function onItemContentChange(item: UlListItem, content: string) {
        updateList((list) => {
            const index = list.items.indexOf(item);
            item.content = content;
            return {
                ...list,
                items: list.items.with(index, item),
            };
        });
    }

    function onDragEnd(e: DragEndEvent) {
        const { active, over } = e;
        if (over && active.id !== over.id) {
            updateList((list) => {
                const oldIndex = list.items.findIndex(
                    (item) => item.id === active.id,
                );
                const newIndex = list.items.findIndex(
                    (item) => item.id === over.id,
                );
                return {
                    ...list,
                    items: arrayMove(list.items, oldIndex, newIndex),
                };
            });
        }
    }

    async function save(list: UlList) {
        console.log("save");
        console.log(list.items.map((i) => i.content));
        await invoke("save", { list });
        setIsLatestChangeSaved(true);
    }

    return (
        <DndContext onDragEnd={onDragEnd} sensors={sensors}>
            <SortableContext
                items={list.items}
                strategy={verticalListSortingStrategy}
            >
                <div className="w-full p-4">
                    <div className="flex w-full justify-between p-2">
                        <h2 className="text-2xl">{list.name}</h2>
                        <div className="">
                            <Icon
                                icon={
                                    isLatestChangeSaved ? "file-check" : "file"
                                }
                                color={
                                    isLatestChangeSaved ? "limegreen" : "gold"
                                }
                            />
                        </div>
                    </div>
                    <ul className="w-full p-4">
                        {list.items
                            .filter((item) => !item.isCompleted)
                            .map((item) => (
                                <ListItem
                                    key={item.id}
                                    item={item}
                                    canFocus={!isFocusTrapped}
                                    toggleFocused={setIsFocusTrapped}
                                    toggleCompleted={toggleCompleted}
                                    remove={removeItem}
                                    onContentChange={onItemContentChange}
                                />
                            ))}
                        <AddItemButton addItem={addItem} />
                    </ul>
                </div>
            </SortableContext>
        </DndContext>
    );
}
