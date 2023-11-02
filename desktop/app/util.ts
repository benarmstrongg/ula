export function generateId(): string {
    return String(Math.floor(Math.random() * 10 ** 6));
}
