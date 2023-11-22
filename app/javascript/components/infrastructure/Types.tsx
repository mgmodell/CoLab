
interface ColumnMeta {
  field: string;
  header: string;
  sortable: boolean;
  filterable?: boolean;
  hidden?: boolean;
  body?: (param) => ReactNode;
  key?: string;
}

export { ColumnMeta };