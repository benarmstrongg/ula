export type UlList = {
    id: string;
    name: string;
    items: UlListItem[];
};

export type UlListItem = {
    id: string;
    content: string;
    isCompleted: boolean;
};
