import { DateTime } from 'luxon';
export const formatDateToISODate = (input: Date) =>
  DateTime.fromJSDate(input).toISODate();

export const formatDate = (input: Date, format: string) =>
  DateTime.fromJSDate(input).toFormat(format);
