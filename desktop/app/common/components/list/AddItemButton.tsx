import { Icon } from "../icon";

type AddItemButtonProps = {
    addItem: () => void;
};

export function AddItemButton({ addItem }: AddItemButtonProps) {
    return (
        <li
            className="
                align-center
                flex
                cursor-pointer
                gap-3
                border-b-2
                border-solid
                border-gray-700
                p-3
                opacity-50
                hover:bg-gray-700
                hover:opacity-100
            "
            role="button"
            onClick={() => addItem()}
        >
            <Icon icon="circle-plus" />
            New
        </li>
    );
}
