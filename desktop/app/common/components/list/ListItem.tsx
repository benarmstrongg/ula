"use client";

import type { UlListItem } from "@/app/types";
import { useSortable } from "@dnd-kit/sortable";
import { Icon } from "../icon";
import { useEffect, useState } from "react";

type ListItemProps = {
    item: UlListItem;
    canFocus: boolean;
    toggleFocused: (focused: boolean) => void;
    toggleCompleted: (item: UlListItem) => void;
    onContentChange: (item: UlListItem, content: string) => void;
    remove: (itemId: string) => void;
};

export function ListItem({
    item,
    canFocus,
    toggleCompleted,
    toggleFocused,
    onContentChange,
    remove,
}: ListItemProps) {
    const [content, setContent] = useState(item.content);

    useEffect(() => {
        setContent(item.content);
    }, [item.content]);

    const { attributes, listeners, setNodeRef, transform, transition } =
        useSortable({ id: item.id });
    const style = transform
        ? {
              transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
              transition,
          }
        : undefined;

    function onFocus() {
        toggleFocused(true);
    }

    function onChange(val: string) {
        setContent(val);
        onContentChange(item, val);
    }

    function onBlur() {
        toggleFocused(false);
        if (content === "") {
            return remove(item.id);
        }
    }

    return (
        <li
            className="
                align-center
                flex
                select-none
                gap-3
                border-b-2
                border-solid
                border-gray-700
                p-3
                hover:bg-gray-900
            "
            ref={setNodeRef}
            style={style}
            {...attributes}
            {...listeners}
        >
            <Icon icon="circle" onClick={() => toggleCompleted(item)} />
            <input
                className="
                    w-full
                    cursor-pointer
                    bg-transparent
                    caret-slate-400
                    outline-none
                "
                value={content}
                autoFocus={canFocus}
                onFocus={onFocus}
                onChange={(e) => onChange(e.target.value)}
                onBlur={onBlur}
            />
        </li>
    );
}
