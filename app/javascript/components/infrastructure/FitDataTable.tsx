import React, { useCallback, useEffect, useLayoutEffect, useRef, useState } from "react";
import { DataTable, type DataTableProps, type DataTableValueArray } from "primereact/datatable";

const BOTTOM_MARGIN = 16;
const MIN_HEIGHT = 200;

// Props that only make sense for a paginated table; the table scrolls instead.
type PaginationProps =
  | "paginator"
  | "rows"
  | "first"
  | "rowsPerPageOptions"
  | "paginatorTemplate"
  | "paginatorDropdownAppendTo"
  | "paginatorLeft"
  | "paginatorRight"
  | "paginatorPosition"
  | "paginatorClassName"
  | "currentPageReportTemplate"
  | "alwaysShowPaginator";

type Props = Omit<DataTableProps<DataTableValueArray>, PaginationProps | "scrollable" | "scrollHeight"> & {
  [key: string]: any;
};

/**
 * A DataTable that fills the vertical space remaining in the window (below
 * its own top edge) and scrolls internally instead of paginating. The
 * rendered table's bottom edge is measured and the scrolling body's height
 * is corrected so the whole table (toolbar, headings, filters, footer) fits.
 */
export default function FitDataTable(props: Props) {
  const {
    paginator,
    rows,
    first,
    rowsPerPageOptions,
    paginatorTemplate,
    paginatorDropdownAppendTo,
    paginatorLeft,
    paginatorRight,
    paginatorPosition,
    paginatorClassName,
    currentPageReportTemplate,
    alwaysShowPaginator,
    scrollable,
    scrollHeight,
    ...tableProps
  } = props as any;

  const wrapperRef = useRef<HTMLDivElement>(null);
  const [height, setHeight] = useState<number>(MIN_HEIGHT * 2);

  const recalc = useCallback(() => {
    const el = wrapperRef.current;
    if (!el) return;
    const limit = window.innerHeight - BOTTOM_MARGIN;
    const available = Math.max(MIN_HEIGHT, Math.floor(limit - el.getBoundingClientRect().top));
    // Measure how far the rendered table (toolbar, headings, filters and
    // footer included) overshoots or undershoots the limit and correct the
    // scroll height by that amount. This avoids depending on PrimeReact's
    // internal layout. Growth is capped so short tables converge.
    const root = el.firstElementChild as HTMLElement | null;
    const delta = root ? Math.round(limit - root.getBoundingClientRect().bottom) : 0;
    setHeight(current => {
      if (Math.abs(delta) <= 1) return Math.min(available, current);
      return Math.min(available, Math.max(MIN_HEIGHT, current + delta));
    });
  }, []);

  useLayoutEffect(recalc);

  useEffect(() => {
    window.addEventListener("resize", recalc);
    let observer: ResizeObserver | undefined;
    if (typeof ResizeObserver !== "undefined") {
      observer = new ResizeObserver(recalc);
      observer.observe(document.body);
      const root = wrapperRef.current?.firstElementChild;
      if (root) {
        observer.observe(root);
      }
    }
    return () => {
      window.removeEventListener("resize", recalc);
      observer?.disconnect();
    };
  }, [recalc]);

  return (
    <div ref={wrapperRef} className="fit-data-table">
      <DataTable {...tableProps} scrollable scrollHeight={`${height}px`} />
    </div>
  );
}
