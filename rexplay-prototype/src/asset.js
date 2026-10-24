// Images exported from Figma live in public/assets/ (Figma names them by content,
// so one file is shared across screens). Run `npm run assets` to fetch them.
export const asset = (file) => `${import.meta.env.BASE_URL}assets/${file}`;
