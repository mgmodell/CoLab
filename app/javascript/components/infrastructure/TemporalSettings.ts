import { Temporal } from "temporal-polyfill";

// Module-level timezone storage, replaces Luxon's Settings.defaultZone
let _defaultTimeZone: string = Temporal.Now.timeZoneId();

/**
 * Global timezone settings – mirrors the Luxon Settings API used throughout
 * the codebase so that a single import swap is sufficient.
 */
const TemporalSettings = {
  get defaultZone(): string {
    return _defaultTimeZone;
  },
  set defaultZone(zone: string) {
    _defaultTimeZone = zone;
  },
  // Legacy alias used in several files as Settings.timezone
  get timezone(): string {
    return _defaultTimeZone;
  }
};

/**
 * Parse an ISO 8601 string into a Temporal.ZonedDateTime.
 * If the value is already a Temporal.ZonedDateTime, it is returned as-is.
 * If a zone is not supplied, the globally configured default zone is used.
 */
const parseISO = (
  isoString: string | Temporal.ZonedDateTime,
  zone?: string
): Temporal.ZonedDateTime => {
  if (isoString instanceof Temporal.ZonedDateTime) {
    return zone ? isoString.withTimeZone(zone) : isoString;
  }
  const tz = zone || _defaultTimeZone;
  return Temporal.Instant.from(isoString as string).toZonedDateTimeISO(tz);
};

/**
 * Format a Temporal.ZonedDateTime using Intl.DateTimeFormat.
 * Mirrors the most common Luxon toLocaleString() call-sites.
 */
const DATETIME_MED: Intl.DateTimeFormatOptions = {
  year: "numeric",
  month: "short",
  day: "numeric",
  hour: "numeric",
  minute: "2-digit"
};

const DATETIME_SHORT: Intl.DateTimeFormatOptions = {
  year: "numeric",
  month: "numeric",
  day: "numeric",
  hour: "numeric",
  minute: "2-digit"
};

const DATE_SHORT: Intl.DateTimeFormatOptions = {
  year: "numeric",
  month: "numeric",
  day: "numeric"
};

const formatZonedDateTime = (
  zdt: Temporal.ZonedDateTime,
  options: Intl.DateTimeFormatOptions = DATETIME_MED
): string => {
  return new Intl.DateTimeFormat(undefined, {
    ...options,
    timeZone: zdt.timeZoneId
  }).format(new Date(zdt.toInstant().epochMilliseconds));
};

/**
 * Return localised weekday names starting from Monday (index 0) through
 * Sunday (index 6), matching the ordering returned by Luxon's Info.weekdays().
 */
const getWeekdays = (): string[] => {
  const formatter = new Intl.DateTimeFormat(undefined, { weekday: "long" });
  // 2024-01-01 is a Monday
  return Array.from({ length: 7 }, (_, i) =>
    formatter.format(new Date(2024, 0, 1 + i))
  );
};

export {
  Temporal,
  TemporalSettings,
  parseISO,
  formatZonedDateTime,
  getWeekdays,
  DATETIME_MED,
  DATETIME_SHORT,
  DATE_SHORT
};
