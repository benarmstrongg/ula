import { createStore } from "@/app/store";
import { UlList } from "@/app/types";

export const LIST_STORE = createStore<{ [id: string]: UlList }>({});
