import type { IconType } from "./types";
import { ICON_PATHS } from "./const";

export type IconProps = {
    icon: IconType;
    color?: string;
    className?: string;

    onClick?: () => void;
};

export function Icon({ icon, color, className, onClick }: IconProps) {
    const path = ICON_PATHS[icon];
    return (
        <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth={1.5}
            stroke={color || "currentColor"}
            className={`h-6 w-6 ${className}`}
            onClick={onClick}
        >
            {path}
        </svg>
    );
}
